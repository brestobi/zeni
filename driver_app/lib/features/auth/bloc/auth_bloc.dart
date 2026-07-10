import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';
import '../repository/auth_repository.dart';

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

  Future<void> _onOtpCodeSubmitted(
    OtpCodeSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOTP(
        token: event.code,
        phone: (state as AuthOtpSent).phoneNumber,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        
        // 1. Fetch Profile
        final profile = await authRepository.getProfile(userId);

        // 2. Fetch Driver record
        final driver = await authRepository.getDriver(userId);

        if (driver != null) {
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
    Emitter<AuthBlocState> emit,
  ) {
    emit(AuthInitial());
  }
}
