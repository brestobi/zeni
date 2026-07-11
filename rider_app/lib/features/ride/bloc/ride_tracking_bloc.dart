import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class RideTrackingEvent {}

final class StartTrackingRide extends RideTrackingEvent {
  final String rideRequestId;
  StartTrackingRide(this.rideRequestId);
}

final class UpdateRideStatusEvent extends RideTrackingEvent {
  final String status;
  final Map<String, dynamic>? rideJson;
  UpdateRideStatusEvent(this.status, {this.rideJson});
}

final class UpdateDriverLocationEvent extends RideTrackingEvent {
  final double latitude;
  final double longitude;
  final double? heading;
  UpdateDriverLocationEvent({required this.latitude, required this.longitude, this.heading});
}

final class RideErrorEvent extends RideTrackingEvent {
  final String message;
  RideErrorEvent(this.message);
}

// --- States ---
sealed class RideTrackingState {}

final class RideTrackingInitial extends RideTrackingState {}

final class RideTrackingLoading extends RideTrackingState {}

final class RideTrackingWaitingForDriver extends RideTrackingState {
  final String rideRequestId;
  RideTrackingWaitingForDriver(this.rideRequestId);
}

final class RideTrackingActive extends RideTrackingState {
  final Ride ride;
  final Profile driverProfile;
  final Driver driverInfo;
  final String vehicleMake;
  final String vehicleModel;
  final String vehiclePlate;
  final double driverLatitude;
  final double driverLongitude;
  final double? driverHeading;

  RideTrackingActive({
    required this.ride,
    required this.driverProfile,
    required this.driverInfo,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.driverLatitude,
    required this.driverLongitude,
    this.driverHeading,
  });

  RideTrackingActive copyWith({
    Ride? ride,
    Profile? driverProfile,
    Driver? driverInfo,
    String? vehicleMake,
    String? vehicleModel,
    String? vehiclePlate,
    double? driverLatitude,
    double? driverLongitude,
    double? driverHeading,
  }) {
    return RideTrackingActive(
      ride: ride ?? this.ride,
      driverProfile: driverProfile ?? this.driverProfile,
      driverInfo: driverInfo ?? this.driverInfo,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
      driverHeading: driverHeading ?? this.driverHeading,
    );
  }
}

final class RideTrackingCompleted extends RideTrackingState {
  final Ride ride;
  RideTrackingCompleted(this.ride);
}

final class RideTrackingCancelled extends RideTrackingState {
  final String reason;
  RideTrackingCancelled(this.reason);
}

final class RideTrackingError extends RideTrackingState {
  final String message;
  RideTrackingError(this.message);
}

// --- BLoC ---
class RideTrackingBloc extends Bloc<RideTrackingEvent, RideTrackingState> {
  final SupabaseClient _supabase;
  StreamSubscription? _rideRequestSubscription;
  StreamSubscription? _ridesSubscription;
  StreamSubscription? _driverLocationSubscription;
  
  String? _rideRequestId;
  String? _driverId;

  RideTrackingBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(RideTrackingInitial()) {
    on<StartTrackingRide>(_onStartTrackingRide);
    on<UpdateRideStatusEvent>(_onUpdateRideStatus);
    on<UpdateDriverLocationEvent>(_onUpdateDriverLocation);
    on<RideErrorEvent>(_onRideError);
  }

  Future<void> _onStartTrackingRide(
    StartTrackingRide event,
    Emitter<RideTrackingState> emit,
  ) async {
    _rideRequestId = event.rideRequestId;
    emit(RideTrackingLoading());

    try {
      // 1. Subscribe to ride_requests changes
      _rideRequestSubscription?.cancel();
      _rideRequestSubscription = _supabase
          .from('ride_requests')
          .stream(primaryKey: ['id'])
          .eq('id', event.rideRequestId)
          .listen((data) {
            if (data.isEmpty) return;
            final requestStatus = data.first['status'] as String;

            if (requestStatus == 'pending') {
              if (!isClosed) add(UpdateRideStatusEvent('pending'));
            } else if (requestStatus == 'cancelled') {
              if (!isClosed) add(UpdateRideStatusEvent('cancelled'));
            } else if (requestStatus == 'accepted') {
              // Once accepted, monitor the matching ride record
              _subscribeToRideRecord(event.rideRequestId);
            }
          }, onError: (e) {
            if (!isClosed) add(RideErrorEvent('Ride request sync error: $e'));
          });
    } catch (e) {
      emit(RideTrackingError('Failed to start tracking ride: $e'));
    }
  }

  void _subscribeToRideRecord(String rideRequestId) {
    _ridesSubscription?.cancel();
    _ridesSubscription = _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('ride_request_id', rideRequestId)
        .listen((data) async {
          if (data.isEmpty) return;
          final rideJson = data.first;
          final rideStatus = rideJson['status'] as String;

          if (!isClosed) {
            add(UpdateRideStatusEvent(rideStatus, rideJson: rideJson));
          }
        }, onError: (e) {
          if (!isClosed) add(RideErrorEvent('Rides sync error: $e'));
        });
  }

  Future<void> _onUpdateRideStatus(
    UpdateRideStatusEvent event,
    Emitter<RideTrackingState> emit,
  ) async {
    if (event.status == 'pending') {
      emit(RideTrackingWaitingForDriver(_rideRequestId!));
      return;
    }

    if (event.status == 'cancelled') {
      emit(RideTrackingCancelled('Ride was cancelled.'));
      _cleanupSubscriptions();
      return;
    }

    if (event.rideJson == null) return;

    try {
      final ride = Ride.fromJson(event.rideJson!);

      if (ride.status == RideStatus.completed) {
        emit(RideTrackingCompleted(ride));
        _cleanupSubscriptions();
        return;
      }

      // Check if driver has changed or needs to be loaded
      if (_driverId != ride.driverId) {
        _driverId = ride.driverId;
        
        // Fetch Driver profile & vehicle info
        final profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', ride.driverId)
            .single();
        final profile = Profile.fromJson(profileData);

        final driverData = await _supabase
            .from('drivers')
            .select()
            .eq('id', ride.driverId)
            .single();
        final driver = Driver.fromJson(driverData);

        // Fetch initial driver location
        double initialLat = 0.0;
        double initialLng = 0.0;
        double? initialHeading;

        final locData = await _supabase
            .from('ride_locations')
            .select()
            .eq('driver_id', ride.driverId)
            .maybeSingle();

        if (locData != null) {
          initialLat = (locData['latitude'] as num).toDouble();
          initialLng = (locData['longitude'] as num).toDouble();
          initialHeading = (locData['heading'] as num?)?.toDouble();
        }

        // Fetch active vehicle for this driver
        String vehicleMake = 'Unknown';
        String vehicleModel = 'Vehicle';
        String vehiclePlate = '---';

        final vehicleData = await _supabase
            .from('vehicles')
            .select()
            .eq('driver_id', ride.driverId)
            .maybeSingle();

        if (vehicleData != null) {
          vehicleMake = vehicleData['make'] as String? ?? vehicleMake;
          vehicleModel = vehicleData['model'] as String? ?? vehicleModel;
          vehiclePlate = vehicleData['plate_number'] as String? ?? vehiclePlate;
        }

        // Subscribe to driver location changes
        _subscribeToDriverLocation(ride.driverId);

        emit(RideTrackingActive(
          ride: ride,
          driverProfile: profile,
          driverInfo: driver,
          vehicleMake: vehicleMake,
          vehicleModel: vehicleModel,
          vehiclePlate: vehiclePlate,
          driverLatitude: initialLat,
          driverLongitude: initialLng,
          driverHeading: initialHeading,
        ));
      } else {
        // Driver already loaded, update status only
        final currentState = state;
        if (currentState is RideTrackingActive) {
          emit(currentState.copyWith(ride: ride));
        }
      }
    } catch (e) {
      emit(RideTrackingError('Failed to process ride update: $e'));
    }
  }

  void _subscribeToDriverLocation(String driverId) {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = _supabase
        .from('ride_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .listen((data) {
          if (data.isEmpty) return;
          final json = data.first;
          final lat = (json['latitude'] as num).toDouble();
          final lng = (json['longitude'] as num).toDouble();
          final heading = (json['heading'] as num?)?.toDouble();

          if (!isClosed) {
            add(UpdateDriverLocationEvent(latitude: lat, longitude: lng, heading: heading));
          }
        });
  }

  void _onUpdateDriverLocation(
    UpdateDriverLocationEvent event,
    Emitter<RideTrackingState> emit,
  ) {
    final currentState = state;
    if (currentState is RideTrackingActive) {
      emit(currentState.copyWith(
        driverLatitude: event.latitude,
        driverLongitude: event.longitude,
        driverHeading: event.heading,
      ));
    }
  }

  void _onRideError(RideErrorEvent event, Emitter<RideTrackingState> emit) {
    emit(RideTrackingError(event.message));
  }

  void _cleanupSubscriptions() {
    _rideRequestSubscription?.cancel();
    _ridesSubscription?.cancel();
    _driverLocationSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cleanupSubscriptions();
    return super.close();
  }
}
