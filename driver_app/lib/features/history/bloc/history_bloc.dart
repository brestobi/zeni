import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';
import '../repository/history_repository.dart';

// --- Events ---
sealed class HistoryEvent {}

final class LoadHistory extends HistoryEvent {}

// --- States ---
sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  final List<Ride> rides;
  HistoryLoaded(this.rides);
}

final class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

// --- BLoC ---
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _repository;
  final String _userId;

  HistoryBloc({
    required HistoryRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final rides = await _repository.getRideHistory(_userId);
      emit(HistoryLoaded(rides));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
