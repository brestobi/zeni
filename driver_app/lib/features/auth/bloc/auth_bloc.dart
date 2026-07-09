import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class AuthEvent {}

final class PhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  PhoneNumberSubmitted(this.phoneNumber);
}

final class OtpCodeSubmitted extends AuthEvent {
  final String code;
  OtpCodeSubmitted(this.code);
}

final class AuthSignOutRequested extends AuthEvent {}

// --- States ---
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthOtpSent extends AuthState {
  final String phoneNumber;
  AuthOtpSent(this.phoneNumber);
}

final class AuthAuthenticated extends AuthState {
  final Profile profile;
  final Driver? driver;
  AuthAuthenticated(this.profile, {this.driver});
}

final class AuthNewUser extends AuthState {
  final String phoneNumber;
  const AuthNewUser(this.phoneNumber);
}

final class AuthRegistrationPending extends AuthState {
  final Profile profile;
  AuthRegistrationPending(this.profile);
}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<OtpCodeSubmitted>(_onOtpCodeSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onPhoneNumberSubmitted(
    PhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: event.phoneNumber,
      );
      emit(AuthOtpSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpCodeSubmitted(
    OtpCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        token: event.code,
        phone: (state as AuthOtpSent).phoneNumber,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        
        // 1. Fetch Profile
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
        final profile = Profile.fromJson(profileData);

        // 2. Fetch Driver record
        final driverData = await Supabase.instance.client
            .from('drivers')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (driverData != null) {
          final driver = Driver.fromJson(driverData);
          emit(AuthAuthenticated(profile, driver: driver));
        } else {
          // Profile exists, but not a driver yet
          emit(AuthNewUser(response.user!.phone!));
        }
      } else {
        emit(AuthError('Verification failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}
