import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeni_services/zeni_services.dart';

// --- Events ---
sealed class LocationEvent {}

final class StartTracking extends LocationEvent {
  final String driverId;
  StartTracking(this.driverId);
}

final class StopTracking extends LocationEvent {}

final class LocationUpdated extends LocationEvent {
  final LocationData location;
  LocationUpdated(this.location);
}

final class LocationFailed extends LocationEvent {
  final String message;
  LocationFailed(this.message);
}

// --- States ---
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationTracking extends LocationState {
  final LocationData lastLocation;
  LocationTracking(this.lastLocation);
}

final class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}

// --- BLoC ---
class LocationTrackingBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final SupabaseClientWrapper _supabase;
  StreamSubscription? _locationSubscription;
  String? _driverId;

  LocationTrackingBloc({
    required LocationService locationService,
    required SupabaseClientWrapper supabase,
  })  : _locationService = locationService,
        _supabase = supabase,
        super(LocationInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<LocationUpdated>(_onLocationUpdated);
    on<LocationFailed>(_onLocationFailed);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LocationState> emit,
  ) async {
    _driverId = event.driverId;
    _locationSubscription = _locationService.locationStream.listen(
      (location) {
        if (!isClosed) add(LocationUpdated(location));
      },
      onError: (e) {
        if (!isClosed) add(LocationFailed(e.toString()));
      },
    );
  }

  void _onLocationFailed(
    LocationFailed event,
    Emitter<LocationState> emit,
  ) {
    _locationSubscription?.cancel();
    emit(LocationError(event.message));
  }

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) async {
    if (_driverId == null) return;

    try {
      // Upsert using driver_id as the conflict target so we always update
      // the single row for this driver rather than inserting duplicates.
      await _supabase.client.from('ride_locations').upsert(
        {
          'driver_id': _driverId,
          'latitude': event.location.latitude,
          'longitude': event.location.longitude,
          'heading': event.location.heading,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'driver_id',
      );
      emit(LocationTracking(event.location));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LocationState> emit,
  ) async {
    await _locationSubscription?.cancel();
    emit(LocationInitial());
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
