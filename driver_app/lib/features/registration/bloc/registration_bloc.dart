import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Events ---
sealed class RegistrationEvent {}

final class StepChanged extends RegistrationEvent {
  final int step;
  StepChanged(this.step);
}

final class RegistrationSubmitted extends RegistrationEvent {
  /// Collected data keys expected:
  ///   'license_number' (String)
  ///   'make' (String), 'model' (String), 'year' (int), 'plate_number' (String)
  ///   'vehicle_type' (String) — one of standard/comfort/premium/motorcycle
  final Map<String, dynamic> data;
  RegistrationSubmitted(this.data);
}

// --- States ---
sealed class RegistrationState {}

final class RegistrationInitial extends RegistrationState {
  final int currentStep = 0;
}

final class RegistrationInProgress extends RegistrationState {
  final int currentStep;
  RegistrationInProgress(this.currentStep);
}

final class RegistrationSuccess extends RegistrationState {}

final class RegistrationError extends RegistrationState {
  final String message;
  RegistrationError(this.message);
}

// --- BLoC ---
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final SupabaseClient _supabase;

  RegistrationBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(RegistrationInitial()) {
    on<StepChanged>(_onStepChanged);
    on<RegistrationSubmitted>(_onRegistrationSubmitted);
  }

  void _onStepChanged(StepChanged event, Emitter<RegistrationState> emit) {
    emit(RegistrationInProgress(event.step));
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationInProgress(-1)); // Use -1 to indicate submitting state.
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(RegistrationError('Not authenticated. Please sign in again.'));
        return;
      }

      final data = event.data;

      // 1. Create the driver record (linked to the existing profile).
      await _supabase.from('drivers').upsert({
        'id': userId,
        'profile_id': userId,
        'license_number': data['license_number'] as String?,
        'is_verified': false, // Admin must approve before driver can go online.
        'status': 'pendingApproval',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      // 2. Create the vehicle record associated with this driver.
      await _supabase.from('vehicles').insert({
        'driver_id': userId,
        'make': data['make'] as String,
        'model': data['model'] as String,
        'year': data['year'] as int,
        'plate_number': data['plate_number'] as String,
        'vehicle_type': data['vehicle_type'] as String? ?? 'standard',
        'updated_at': DateTime.now().toIso8601String(),
      });

      emit(RegistrationSuccess());
    } catch (e) {
      emit(RegistrationError('Registration failed: $e'));
    }
  }
}
