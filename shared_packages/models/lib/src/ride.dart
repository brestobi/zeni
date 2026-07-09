import 'enums.dart';

/// An active or completed ride.
class Ride {
  final String id;
  final String rideRequestId;
  final String driverId;
  final String passengerId;
  final RideStatus status;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final PaymentMethod paymentMethod;
  final PaymentStatus? paymentStatus;
  final double? fare;
  final double? distance;
  final int? duration;
  final DateTime? driverAcceptedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? routePolyline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ride({
    required this.id,
    required this.rideRequestId,
    required this.driverId,
    required this.passengerId,
    required this.status,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.paymentMethod,
    this.paymentStatus,
    this.fare,
    this.distance,
    this.duration,
    this.driverAcceptedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.routePolyline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['id'] as String,
        rideRequestId: json['ride_request_id'] as String,
        driverId: json['driver_id'] as String,
        passengerId: json['passenger_id'] as String,
        status: RideStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RideStatus.pending,
        ),
        pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
        pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
        pickupAddress: json['pickup_address'] as String,
        dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
        dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
        dropoffAddress: json['dropoff_address'] as String,
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == json['payment_method'],
          orElse: () => PaymentMethod.cash,
        ),
        paymentStatus: json['payment_status'] != null
            ? PaymentStatus.values.firstWhere(
                (e) => e.name == json['payment_status'],
              )
            : null,
        fare: (json['fare'] as num?)?.toDouble(),
        distance: (json['distance'] as num?)?.toDouble(),
        duration: json['duration'] as int?,
        driverAcceptedAt: json['driver_accepted_at'] != null
            ? DateTime.parse(json['driver_accepted_at'] as String)
            : null,
        driverArrivedAt: json['driver_arrived_at'] != null
            ? DateTime.parse(json['driver_arrived_at'] as String)
            : null,
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        cancelledAt: json['cancelled_at'] != null
            ? DateTime.parse(json['cancelled_at'] as String)
            : null,
        cancellationReason: json['cancellation_reason'] as String?,
        routePolyline: json['route_polyline'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ride_request_id': rideRequestId,
        'driver_id': driverId,
        'passenger_id': passengerId,
        'status': status.name,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'pickup_address': pickupAddress,
        'dropoff_latitude': dropoffLatitude,
        'dropoff_longitude': dropoffLongitude,
        'dropoff_address': dropoffAddress,
        'payment_method': paymentMethod.name,
        'payment_status': paymentStatus?.name,
        'fare': fare,
        'distance': distance,
        'duration': duration,
        'driver_accepted_at': driverAcceptedAt?.toIso8601String(),
        'driver_arrived_at': driverArrivedAt?.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'cancellation_reason': cancellationReason,
        'route_polyline': routePolyline,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
