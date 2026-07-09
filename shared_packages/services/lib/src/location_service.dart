/// Abstract interface for location services.
///
/// Implementations may use geolocator or mock providers.
abstract class LocationService {
  Future<LocationData> getCurrentLocation();
  Stream<LocationData> get locationStream;
  Future<bool> isLocationServiceEnabled();
  Future<bool> requestPermission();
}

class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final DateTime? timestamp;
}
