/// Passenger-specific metadata.
class Passenger {
  final String id;
  final double? averageRating;
  final int? totalRides;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final List<String>? favoriteAddresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Passenger({
    required this.id,
    this.averageRating,
    this.totalRides,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.favoriteAddresses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        id: json['id'] as String,
        averageRating: (json['average_rating'] as num?)?.toDouble(),
        totalRides: json['total_rides'] as int?,
        emergencyContactName: json['emergency_contact_name'] as String?,
        emergencyContactPhone: json['emergency_contact_phone'] as String?,
        favoriteAddresses: (json['favorite_addresses'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'average_rating': averageRating,
        'total_rides': totalRides,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'favorite_addresses': favoriteAddresses,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
