import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Events ---
sealed class TripEvent {}

final class UpdateTripStatus extends TripEvent {
  final String rideId;
  final String status; // 'arrived', 'started', 'completed'
  UpdateTripStatus(this.rideId, this.status);
}

// --- States ---
sealed class TripState {}

final class TripInitial extends TripState {}

final class TripLoading extends TripState {}

final class TripStatusUpdated extends TripState {
  final String status;
  TripStatusUpdated(this.status);
}

final class TripError extends TripState {
  final String message;
  TripError(this.message);
}

// --- BLoC ---
class TripManagementBloc extends Bloc<TripEvent, TripState> {
  final SupabaseClient _supabase;

  TripManagementBloc({required SupabaseClient supabase})
      : _supabase = supabase,
        super(TripInitial()) {
    on<UpdateTripStatus>(_onUpdateTripStatus);
  }

  Future<void> _onUpdateTripStatus(
    UpdateTripStatus event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    try {
      await _supabase
          .from('rides')
          .update({
            'status': event.status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.rideId);
      
      emit(TripStatusUpdated(event.status));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}
