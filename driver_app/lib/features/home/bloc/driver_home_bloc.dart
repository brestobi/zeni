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

// --- BLoC ---
class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  final SupabaseClient _supabase;
  final LocationService _locationService;
  StreamSubscription? _rideRequestSubscription;

  // Exposed for dependent widgets/blocs that need the same client.
  SupabaseClient get supabase => _supabase;

  /// Dependencies are injected for testability and to avoid coupling
  /// the bloc to global singletons.
  DriverHomeBloc({
    required SupabaseClient supabase,
    LocationService? locationService,
  })  : _supabase = supabase,
        _locationService = locationService ?? LocationService(),
        super(DriverHomeInitial()) {
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
    final driverId = _supabase.auth.currentUser?.id;
    if (driverId == null) {
      emit(DriverHomeError('Not authenticated'));
      return;
    }

    if (event.isOnline) {
      emit(DriverOnlineWaiting());
      _subscribeToRideRequests();
      await _locationService.startTracking(driverId);
    } else {
      await _rideRequestSubscription?.cancel();
      _rideRequestSubscription = null;
      _locationService.stopTracking();
      emit(DriverOffline());
    }
  }

  void _subscribeToRideRequests() {
    _rideRequestSubscription = _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen((data) {
      if (data.isNotEmpty && !isClosed) {
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
      final driverId = _supabase.auth.currentUser?.id;
      if (driverId == null) {
        emit(DriverHomeError('Not authenticated'));
        return;
      }

      // Call the atomic RPC function that handles the race condition
      // This function:
      // 1. Locks the ride_request row
      // 2. Checks if it's still pending
      // 3. Creates the ride record (unique constraint on ride_request_id)
      // 4. Updates both ride_request and driver status in one transaction
      // If another driver wins the race, the function returns success:false
      final result = await _supabase.rpc(
        'accept_ride_request_atomic',
        params: {
          'p_request_id': event.requestId,
          'p_driver_id': driverId,
        },
      );

      if (result['success'] == false) {
        emit(DriverHomeError(result['error'] ?? 'Failed to accept ride'));
        return;
      }

      // Fetch the complete ride data to populate the state
      final rideData = await _supabase
          .from('rides')
          .select()
          .eq('id', result['ride_id'])
          .single();

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
      final updateMap = <String, dynamic>{'status': event.newStatus.name};

      if (event.newStatus == RideStatus.driverArrived) {
        updateMap['driver_arrived_at'] = now;
      } else if (event.newStatus == RideStatus.started) {
        updateMap['started_at'] = now;
      } else if (event.newStatus == RideStatus.completed) {
        updateMap['completed_at'] = now;
      }

      final updatedRideData = await _supabase
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
