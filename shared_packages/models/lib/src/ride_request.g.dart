// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RideRequestImpl _$$RideRequestImplFromJson(Map<String, dynamic> json) =>
    _$RideRequestImpl(
      id: json['id'] as String,
      passengerId: json['passenger_id'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      paymentMethod: $enumDecode(
        _$PaymentMethodEnumMap,
        json['payment_method'],
      ),
      requestedVehicleType: $enumDecodeNullable(
        _$VehicleTypeEnumMap,
        json['requested_vehicle_type'],
      ),
      estimatedFare: (json['estimated_fare'] as num?)?.toDouble(),
      estimatedDistance: (json['estimated_distance'] as num?)?.toDouble(),
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      status: json['status'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RideRequestImplToJson(
  _$RideRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'passenger_id': instance.passengerId,
  'pickup_latitude': instance.pickupLatitude,
  'pickup_longitude': instance.pickupLongitude,
  'pickup_address': instance.pickupAddress,
  'dropoff_latitude': instance.dropoffLatitude,
  'dropoff_longitude': instance.dropoffLongitude,
  'dropoff_address': instance.dropoffAddress,
  'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'requested_vehicle_type': _$VehicleTypeEnumMap[instance.requestedVehicleType],
  'estimated_fare': instance.estimatedFare,
  'estimated_distance': instance.estimatedDistance,
  'estimated_duration': instance.estimatedDuration,
  'status': instance.status,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.yocoCard: 'yocoCard',
  PaymentMethod.mtnMomo: 'mtnMomo',
};

const _$VehicleTypeEnumMap = {
  VehicleType.standard: 'standard',
  VehicleType.comfort: 'comfort',
  VehicleType.premium: 'premium',
  VehicleType.motorcycle: 'motorcycle',
};
