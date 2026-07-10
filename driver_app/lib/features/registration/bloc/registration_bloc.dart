import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
sealed class RegistrationEvent {}

final class StepChanged extends RegistrationEvent {
  final int step;
  StepChanged(this.step);
}

final class RegistrationSubmitted extends RegistrationEvent {
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
  RegistrationBloc() : super(RegistrationInitial()) {
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
    // TODO: Implement registration submission logic (API calls)
    emit(RegistrationSuccess());
  }
}
