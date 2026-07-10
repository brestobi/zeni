import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';
import '../../../core/services/location_service.dart';

// --- Events ---
sealed class DriverHomeEvent {}

final class DriverToggleOnline extends DriverHomeEvent {
  final bool isOnline;
  DriverToggleOnline(this.isOnline);
}

final class DriverNewRideRequest extends DriverHomeEvent {
  final RideRequest request;
  DriverNewRideRequest(this.request);
}

final class DriverAcceptRide extends DriverHomeEvent {
  final String requestId;
  DriverAcceptRide(this.requestId);
}

final class DriverDeclineRide extends DriverHomeEvent {
  final String requestId;
  DriverDeclineRide(this.requestId);
}

final class DriverUpdateRideStatus extends DriverHomeEvent {
  final String rideId;
  final RideStatus newStatus;
  DriverUpdateRideStatus(this.rideId, this.newStatus);
}

// --- States ---
sealed class DriverHomeState {}

final class DriverHomeInitial extends DriverHomeState {}

final class DriverHomeLoading extends DriverHomeState {}

final class DriverOffline extends DriverHomeState {}

final class DriverOnlineWaiting extends DriverHomeState {}

final class DriverIncomingRequest extends DriverHomeState {
  final RideRequest request;
  DriverIncomingRequest(this.request);
}

final class DriverOnRide extends DriverHomeState {
  final Ride ride;
  DriverOnRide(this.ride);
}

final class DriverHomeError extends DriverHomeState {
  final String message;
  DriverHomeError(this.message);
}

// ... BLoC class implementation below ...
class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  StreamSubscription? _rideRequestSubscription;
  final LocationService _locationService = LocationService();

  DriverHomeBloc() : super(DriverHomeInitial()) {
    on<DriverToggleOnline>(_onToggleOnline);
    on<DriverNewRideRequest>(_onNewRideRequest);
    on<DriverAcceptRide>(_onAcceptRide);
    on<DriverDeclineRide>(_onDeclineRide);
    on<DriverUpdateRideStatus>(_onUpdateRideStatus);
  }

  @override
  Future<void> close() {
    _rideRequestSubscription?.cancel();
    _locationService.stopTracking();
    return super.close();
  }

  Future<void> _onToggleOnline(
    DriverToggleOnline event,
    Emitter<DriverHomeState> emit,
  ) async {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) {
      emit(DriverHomeError('Not authenticated'));
      return;
    }

    if (event.isOnline) {
      emit(DriverOnlineWaiting());
      _subscribeToRideRequests();
      await _locationService.startTracking(driverId);
    } else {
      _rideRequestSubscription?.cancel();
      _locationService.stopTracking();
      emit(DriverOffline());
    }
  }

  void _subscribeToRideRequests() {
    _rideRequestSubscription = Supabase.instance.client
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen((data) {
      if (data.isNotEmpty) {
        final request = RideRequest.fromJson(data.first);
        add(DriverNewRideRequest(request));
      }
    });
  }

  void _onNewRideRequest(
    DriverNewRideRequest event,
    Emitter<DriverHomeState> emit,
  ) {
    emit(DriverIncomingRequest(event.request));
  }

  Future<void> _onAcceptRide(
    DriverAcceptRide event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(DriverHomeLoading());
    try {
      final driverId = Supabase.instance.client.auth.currentUser?.id;
      if (driverId == null) {
        emit(DriverHomeError('Not authenticated'));
        return;
      }

      // 1. Create a ride record
      final rideData = await Supabase.instance.client.from('rides').insert({
        'ride_request_id': event.requestId,
        'driver_id': driverId,
        'status': 'accepted',
      }).select().single();

      // 2. Update ride request status
      await Supabase.instance.client
          .from('ride_requests')
          .update({'status': 'accepted'})
          .eq('id', event.requestId);

      final ride = Ride.fromJson(rideData);
      emit(DriverOnRide(ride));
    } catch (e) {
      emit(DriverHomeError('Failed to accept ride: $e'));
    }
  }

  Future<void> _onUpdateRideStatus(
    DriverUpdateRideStatus event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(DriverHomeLoading());
    try {
      final now = DateTime.now().toIso8601String();
      final updateMap = {'status': event.newStatus.name};
      
      if (event.newStatus == RideStatus.driverArrived) {
        updateMap['driver_arrived_at'] = now;
      } else if (event.newStatus == RideStatus.started) {
        updateMap['started_at'] = now;
      } else if (event.newStatus == RideStatus.completed) {
        updateMap['completed_at'] = now;
      }

      final updatedRideData = await Supabase.instance.client
          .from('rides')
          .update(updateMap)
          .eq('id', event.rideId)
          .select()
          .single();
      
      final updatedRide = Ride.fromJson(updatedRideData);
      emit(DriverOnRide(updatedRide));
    } catch (e) {
      emit(DriverHomeError('Failed to update ride status: $e'));
    }
  }

  void _onDeclineRide(
    DriverDeclineRide event,
    Emitter<DriverHomeState> emit,
  ) {
    emit(DriverOnlineWaiting());
  }
}
