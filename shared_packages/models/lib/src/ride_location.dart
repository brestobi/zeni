/// Live driver location (singleton per driver - updated continuously).
/// This is the current location of a driver, not a history of GPS pings.
class RideLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final double? heading;
  final DateTime updatedAt;

  const RideLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.heading,
    required this.updatedAt,
  });

  factory RideLocation.fromJson(Map<String, dynamic> json) => RideLocation(
        driverId: json['driver_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        heading: (json['heading'] as num?)?.toDouble(),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'updated_at': updatedAt.toIso8601String(),
      };
}
