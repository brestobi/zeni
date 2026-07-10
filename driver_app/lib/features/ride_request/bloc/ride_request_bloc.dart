import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class RideRequestEvent {}

final class ListenForRideRequests extends RideRequestEvent {}

final class NewRideRequestReceived extends RideRequestEvent {
  final RideRequest rideRequest;
  NewRideRequestReceived(this.rideRequest);
}

// --- States ---
sealed class RideRequestState {}

final class RideRequestInitial extends RideRequestState {}

final class RideRequestLoading extends RideRequestState {}

final class RideRequestAvailable extends RideRequestState {
  final RideRequest rideRequest;
  RideRequestAvailable(this.rideRequest);
}

// --- BLoC ---
class DriverRideRequestBloc extends Bloc<RideRequestEvent, RideRequestState> {
  final SupabaseClient _supabase;
  StreamSubscription? _subscription;

  DriverRideRequestBloc({required SupabaseClient supabase})
      : _supabase = supabase,
        super(RideRequestInitial()) {
    on<ListenForRideRequests>(_onListenForRideRequests);
    on<NewRideRequestReceived>(_onNewRideRequestReceived);
  }

  Future<void> _onListenForRideRequests(
    ListenForRideRequests event,
    Emitter<RideRequestState> emit,
  ) async {
    emit(RideRequestLoading());

    _subscription = _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen((data) {
      if (data.isNotEmpty) {
        // Just take the latest for now
        final request = RideRequest.fromJson(data.first);
        add(NewRideRequestReceived(request));
      }
    });
  }

  void _onNewRideRequestReceived(
    NewRideRequestReceived event,
    Emitter<RideRequestState> emit,
  ) {
    emit(RideRequestAvailable(event.rideRequest));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
