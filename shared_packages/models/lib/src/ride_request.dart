import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'ride_request.freezed.dart';
part 'ride_request.g.dart';

@freezed
class RideRequest with _$RideRequest {
  const factory RideRequest({
    required String id,
    @JsonKey(name: 'passenger_id') required String passengerId,
    @JsonKey(name: 'pickup_latitude') required double pickupLatitude,
    @JsonKey(name: 'pickup_longitude') required double pickupLongitude,
    @JsonKey(name: 'pickup_address') required String pickupAddress,
    @JsonKey(name: 'dropoff_latitude') required double dropoffLatitude,
    @JsonKey(name: 'dropoff_longitude') required double dropoffLongitude,
    @JsonKey(name: 'dropoff_address') required String dropoffAddress,
    @JsonKey(name: 'payment_method') required PaymentMethod paymentMethod,
    @JsonKey(name: 'requested_vehicle_type') VehicleType? requestedVehicleType,
    @JsonKey(name: 'estimated_fare') double? estimatedFare,
    @JsonKey(name: 'estimated_distance') double? estimatedDistance,
    @JsonKey(name: 'estimated_duration') int? estimatedDuration,
    String? status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _RideRequest;

  factory RideRequest.fromJson(Map<String, dynamic> json) =>
      _$RideRequestFromJson(json);
}
