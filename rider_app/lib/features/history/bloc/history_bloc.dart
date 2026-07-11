import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

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
  final SupabaseClient _supabase;

  HistoryBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(HistoryError('User is not authenticated.'));
        return;
      }

      final data = await _supabase
          .from('rides')
          .select()
          .eq('passenger_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      final List<Ride> rides = (data as List).map((json) => Ride.fromJson(json)).toList();
      emit(HistoryLoaded(rides));
    } catch (e) {
      emit(HistoryError('Failed to load ride history: $e'));
    }
  }
}
