/// GPS coordinate record for a ride.
class RideLocation {
  final String id;
  final String rideId;
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final DateTime recordedAt;

  const RideLocation({
    required this.id,
    required this.rideId,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.recordedAt,
  });

  factory RideLocation.fromJson(Map<String, dynamic> json) => RideLocation(
        id: json['id'] as String,
        rideId: json['ride_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        heading: (json['heading'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(json['recorded_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ride_id': rideId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'accuracy': accuracy,
        'recorded_at': recordedAt.toIso8601String(),
      };
}
