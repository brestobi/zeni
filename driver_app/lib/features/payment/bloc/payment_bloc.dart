import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class PaymentEvent {}

final class ConfirmCashPayment extends PaymentEvent {
  final String rideId;
  ConfirmCashPayment(this.rideId);
}

// --- States ---
sealed class PaymentState {}

final class PaymentInitial extends PaymentState {}

final class PaymentProcessing extends PaymentState {}

final class PaymentSuccess extends PaymentState {}

final class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

// --- BLoC ---
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final SupabaseClient _supabase;

  PaymentBloc({required SupabaseClient supabase})
      : _supabase = supabase,
        super(PaymentInitial()) {
    on<ConfirmCashPayment>(_onConfirmCashPayment);
  }

  Future<void> _onConfirmCashPayment(
    ConfirmCashPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentProcessing());
    try {
      // Guard: verify the ride is actually completed before accepting payment.
      // This prevents a driver from confirming cash while the trip is still active.
      final rideData = await _supabase
          .from('rides')
          .select('status')
          .eq('id', event.rideId)
          .single();

      final currentStatus = rideData['status'] as String?;
      if (currentStatus != RideStatus.completed.name) {
        emit(PaymentError(
          'Cannot confirm payment: ride is not yet completed (status: $currentStatus).',
        ));
        return;
      }

      await _supabase.from('rides').update({
        'payment_status': PaymentStatus.captured.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', event.rideId);

      emit(PaymentSuccess());
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
