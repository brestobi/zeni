import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _errorController = StreamController<String>.broadcast();

  /// Stream of location errors. Callers can listen to surface GPS issues in UI.
  Stream<String> get errorStream => _errorController.stream;

  Future<void> startTracking(String driverId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorController.add('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorController.add('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorController.add(
        'Location permission permanently denied. Please enable it in Settings.',
      );
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 metres.
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) => _updateDriverLocation(driverId, position),
      onError: (e) {
        _errorController.add('GPS error: $e');
      },
    );
  }

  Future<void> _updateDriverLocation(String driverId, Position position) async {
    try {
      // Upsert with onConflict so we update the existing row, not insert duplicates.
      await Supabase.instance.client.from('ride_locations').upsert(
        {
          'driver_id': driverId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'heading': position.heading,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'driver_id',
      );
    } catch (e) {
      _errorController.add('Failed to update location: $e');
    }
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stopTracking();
    _errorController.close();
  }
}
