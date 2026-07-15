import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';
import '../repository/auth_repository.dart';

// --- Events ---
sealed class AuthEvent {}

final class PhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  PhoneNumberSubmitted(this.phoneNumber);
}

final class EmailPasswordSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  EmailPasswordSignUpRequested({required this.email, required this.password});
}

final class EmailPasswordSignInRequested extends AuthEvent {
  final String email;
  final String password;
  EmailPasswordSignInRequested({required this.email, required this.password});
}

final class GoogleSignInRequested extends AuthEvent {}

final class OtpCodeSubmitted extends AuthEvent {
  final String code;
  OtpCodeSubmitted(this.code);
}

final class AuthSignOutRequested extends AuthEvent {}

// --- States ---
sealed class AuthBlocState {}

final class AuthInitial extends AuthBlocState {}

final class AuthLoading extends AuthBlocState {}

final class AuthOtpSent extends AuthBlocState {
  final String phoneNumber;
  AuthOtpSent(this.phoneNumber);
}

final class AuthAuthenticated extends AuthBlocState {
  final Profile profile;
  final Driver? driver;
  AuthAuthenticated(this.profile, {this.driver});
}

final class AuthNewUser extends AuthBlocState {
  final String phoneNumber;
  AuthNewUser(this.phoneNumber);
}

final class AuthRegistrationPending extends AuthBlocState {
  final Profile profile;
  AuthRegistrationPending(this.profile);
}

final class AuthError extends AuthBlocState {
  final String message;
  AuthError(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<EmailPasswordSignUpRequested>(_onEmailPasswordSignUpRequested);
    on<EmailPasswordSignInRequested>(_onEmailPasswordSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<OtpCodeSubmitted>(_onOtpCodeSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onPhoneNumberSubmitted(
    PhoneNumberSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signInWithOtp(
        phone: event.phoneNumber,
      );
      emit(AuthOtpSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailPasswordSignUpRequested(
    EmailPasswordSignUpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.signUpWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final profile = await authRepository.getOrCreateProfile(
          userId,
          response.user!.email ?? event.email,
        );
        emit(AuthNewUser(response.user!.email ?? event.email));
      } else {
        emit(AuthError('Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailPasswordSignInRequested(
    EmailPasswordSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final profile = await authRepository.getOrCreateProfile(
          userId,
          response.user!.email ?? event.email,
        );
        final driver = await authRepository.getDriver(userId);

        if (driver == null) {
          emit(AuthNewUser(response.user!.email ?? event.email));
        } else if (!driver.isVerified) {
          emit(AuthRegistrationPending(profile));
        } else {
          emit(AuthAuthenticated(profile, driver: driver));
        }
      } else {
        emit(AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Use native Google Sign-In (no browser)
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken != null) {
        final response = await authRepository.signInWithGoogle(
          idToken: idToken,
          accessToken: accessToken,
        );

        if (response.user != null) {
          final userId = response.user!.id;
          final profile = await authRepository.getOrCreateProfile(
            userId,
            response.user!.email ?? googleUser.email,
          );
          final driver = await authRepository.getDriver(userId);

          if (driver == null) {
            emit(AuthNewUser(response.user!.email ?? googleUser.email));
          } else if (!driver.isVerified) {
            emit(AuthRegistrationPending(profile));
          } else {
            emit(AuthAuthenticated(profile, driver: driver));
          }
        } else {
          emit(AuthError('Google sign-in failed'));
        }
      } else {
        emit(AuthError('Failed to get Google ID token'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpCodeSubmitted(
    OtpCodeSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    // Capture current state BEFORE emitting loading, to avoid an unsafe cast
    // if the state was changed between event dispatch and handler execution.
    final currentState = state;
    if (currentState is! AuthOtpSent) {
      emit(AuthError('Unexpected state: OTP submitted without sending OTP first.'));
      return;
    }

    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOTP(
        token: event.code,
        phone: currentState.phoneNumber,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final phoneNumber = response.user!.phone ?? currentState.phoneNumber;

        // 1. Get or create Profile (auto-creates if doesn't exist)
        final profile = await authRepository.getOrCreateProfile(userId, phoneNumber);

        // 2. Fetch Driver record
        final driver = await authRepository.getDriver(userId);

        if (driver == null) {
          // Profile exists but has never started driver registration.
          emit(AuthNewUser(response.user!.phone ?? currentState.phoneNumber));
        } else if (!driver.isVerified) {
          // Driver registered but not yet approved by admin.
          emit(AuthRegistrationPending(profile));
        } else {
          emit(AuthAuthenticated(profile, driver: driver));
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
    Emitter<AuthBlocState> emit,
  ) async {
    try {
      // Invalidate the Supabase session on the server, not just locally.
      await authRepository.signOut();
    } catch (_) {
      // Ignore sign-out errors — still reset local state.
    }
    emit(AuthInitial());
  }
}
