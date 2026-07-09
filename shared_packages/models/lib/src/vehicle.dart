import 'enums.dart';

/// Vehicle registered by a driver.
class Vehicle {
  final String id;
  final String driverId;
  final VehicleType type;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final int? capacity;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.driverId,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    this.capacity,
    this.photoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        driverId: json['driver_id'] as String,
        type: VehicleType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => VehicleType.standard,
        ),
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        licensePlate: json['license_plate'] as String,
        color: json['color'] as String,
        capacity: json['capacity'] as int?,
        photoUrl: json['photo_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'driver_id': driverId,
        'type': type.name,
        'make': make,
        'model': model,
        'year': year,
        'license_plate': licensePlate,
        'color': color,
        'capacity': capacity,
        'photo_url': photoUrl,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
