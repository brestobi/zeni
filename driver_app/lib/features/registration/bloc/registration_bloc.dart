import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class RegistrationEvent {}

final class StepChanged extends RegistrationEvent {
  final int step;
  StepChanged(this.step);
}

final class RegistrationSubmitted extends RegistrationEvent {
  /// Collected data keys expected:
  ///   'full_name' (String)
  ///   'email' (String, optional)
  ///   'license_number' (String)
  ///   'make' (String), 'model' (String), 'year' (int), 'plate_number' (String)
  ///   'vehicle_type' (VehicleType) — one of standard/comfort/premium/motorcycle
  ///   'license_image_url' (String, optional)
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

      // Validate vehicle_type is a valid enum value
      final vehicleType = data['vehicle_type'];
      if (vehicleType is! VehicleType) {
        emit(RegistrationError('Invalid vehicle type selected.'));
        return;
      }

      final now = DateTime.now().toIso8601String();

      // 1. Update the profile with full_name and email if provided
      await _supabase.from('profiles').update({
        'full_name': data['full_name'] as String?,
        if (data['email'] != null && (data['email'] as String).isNotEmpty)
          'email': data['email'] as String,
        'updated_at': now,
      }).eq('id', userId);

      // 2. Create the driver record (linked to the existing profile).
      await _supabase.from('drivers').upsert({
        'id': userId,
        'profile_id': userId,
        'license_number': data['license_number'] as String?,
        'license_image_url': data['license_image_url'] as String?,
        'is_verified': false, // Admin must approve before driver can go online.
        'status': DriverStatus.pendingApproval.name,
        'updated_at': now,
      }, onConflict: 'id');

      // 3. Create the vehicle record associated with this driver.
      await _supabase.from('vehicles').insert({
        'driver_id': userId,
        'make': data['make'] as String,
        'model': data['model'] as String,
        'year': data['year'] as int,
        'plate_number': data['plate_number'] as String,
        'vehicle_type': vehicleType.name,
        'is_active': true,
        'updated_at': now,
      });

      emit(RegistrationSuccess());
    } catch (e) {
      emit(RegistrationError('Registration failed: $e'));
    }
  }
}
