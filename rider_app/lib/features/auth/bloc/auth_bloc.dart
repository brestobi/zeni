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
  AuthAuthenticated(this.profile);
}

final class AuthNewUser extends AuthState {
  final String phoneNumber;
  const AuthNewUser(this.phoneNumber);
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
        
        // Fetch Profile
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (profileData != null) {
          final profile = Profile.fromJson(profileData);
          emit(AuthAuthenticated(profile));
        } else {
          // New user, need to complete registration
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
