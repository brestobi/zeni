import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';


// --- Events ---
sealed class AuthEvent {}

final class PhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  PhoneNumberSubmitted(this.phoneNumber);
}

final class EmailSubmitted extends AuthEvent {
  final String email;
  EmailSubmitted(this.email);
}

final class OtpCodeSubmitted extends AuthEvent {
  final String code;
  OtpCodeSubmitted(this.code);
}

final class GoogleSignInRequested extends AuthEvent {}

final class AuthSignOutRequested extends AuthEvent {}

// --- States ---
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthOtpSent extends AuthState {
  final String identifier; // Can be phone or email
  final bool isEmail;
  AuthOtpSent(this.identifier, {this.isEmail = false});
}

final class AuthAuthenticated extends AuthState {
  final Profile profile;
  AuthAuthenticated(this.profile);
}

final class AuthNewUser extends AuthState {
  final String identifier; // Can be phone or email
  AuthNewUser(this.identifier);
}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<EmailSubmitted>(_onEmailSubmitted);
    on<OtpCodeSubmitted>(_onOtpCodeSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken != null) {
        final response = await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
        );

        if (response.user != null) {
          final userId = response.user!.id;
          final profileData = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

          if (profileData != null) {
            emit(AuthAuthenticated(Profile.fromJson(profileData)));
          } else {
            emit(AuthNewUser(response.user!.email ?? ''));
          }
        } else {
          emit(AuthError('Google sign-in failed'));
        }
      } else {
        emit(AuthError('Google sign-in failed: ID Token was null'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
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
      emit(AuthOtpSent(event.phoneNumber, isEmail: false));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailSubmitted(
    EmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: event.email,
      );
      emit(AuthOtpSent(event.email, isEmail: true));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpCodeSubmitted(
    OtpCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthOtpSent) return;

    emit(AuthLoading());
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: currentState.isEmail ? OtpType.email : OtpType.sms,
        token: event.code,
        email: currentState.isEmail ? currentState.identifier : null,
        phone: !currentState.isEmail ? currentState.identifier : null,
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
          emit(AuthNewUser(currentState.identifier));
        }
      } else {
        emit(AuthError('Verification failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Invalidate the Supabase session on the server, not just locally.
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore sign-out errors — still reset local state.
    }
    emit(AuthInitial());
  }
}

