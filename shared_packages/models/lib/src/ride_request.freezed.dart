// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RideRequest _$RideRequestFromJson(Map<String, dynamic> json) {
  return _RideRequest.fromJson(json);
}

/// @nodoc
mixin _$RideRequest {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'passenger_id')
  String get passengerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_latitude')
  double get pickupLatitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_longitude')
  double get pickupLongitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_address')
  String get pickupAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'dropoff_latitude')
  double get dropoffLatitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'dropoff_longitude')
  double get dropoffLongitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'dropoff_address')
  String get dropoffAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_vehicle_type')
  VehicleType? get requestedVehicleType => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_fare')
  double? get estimatedFare => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_distance')
  double? get estimatedDistance => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_duration')
  int? get estimatedDuration => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RideRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RideRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RideRequestCopyWith<RideRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideRequestCopyWith<$Res> {
  factory $RideRequestCopyWith(
    RideRequest value,
    $Res Function(RideRequest) then,
  ) = _$RideRequestCopyWithImpl<$Res, RideRequest>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'passenger_id') String passengerId,
    @JsonKey(name: 'pickup_latitude') double pickupLatitude,
    @JsonKey(name: 'pickup_longitude') double pickupLongitude,
    @JsonKey(name: 'pickup_address') String pickupAddress,
    @JsonKey(name: 'dropoff_latitude') double dropoffLatitude,
    @JsonKey(name: 'dropoff_longitude') double dropoffLongitude,
    @JsonKey(name: 'dropoff_address') String dropoffAddress,
    @JsonKey(name: 'payment_method') PaymentMethod paymentMethod,
    @JsonKey(name: 'requested_vehicle_type') VehicleType? requestedVehicleType,
    @JsonKey(name: 'estimated_fare') double? estimatedFare,
    @JsonKey(name: 'estimated_distance') double? estimatedDistance,
    @JsonKey(name: 'estimated_duration') int? estimatedDuration,
    String? status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$RideRequestCopyWithImpl<$Res, $Val extends RideRequest>
    implements $RideRequestCopyWith<$Res> {
  _$RideRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RideRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? passengerId = null,
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? pickupAddress = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? dropoffAddress = null,
    Object? paymentMethod = null,
    Object? requestedVehicleType = freezed,
    Object? estimatedFare = freezed,
    Object? estimatedDistance = freezed,
    Object? estimatedDuration = freezed,
    Object? status = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            passengerId: null == passengerId
                ? _value.passengerId
                : passengerId // ignore: cast_nullable_to_non_nullable
                      as String,
            pickupLatitude: null == pickupLatitude
                ? _value.pickupLatitude
                : pickupLatitude // ignore: cast_nullable_to_non_nullable
                      as double,
            pickupLongitude: null == pickupLongitude
                ? _value.pickupLongitude
                : pickupLongitude // ignore: cast_nullable_to_non_nullable
                      as double,
            pickupAddress: null == pickupAddress
                ? _value.pickupAddress
                : pickupAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            dropoffLatitude: null == dropoffLatitude
                ? _value.dropoffLatitude
                : dropoffLatitude // ignore: cast_nullable_to_non_nullable
                      as double,
            dropoffLongitude: null == dropoffLongitude
                ? _value.dropoffLongitude
                : dropoffLongitude // ignore: cast_nullable_to_non_nullable
                      as double,
            dropoffAddress: null == dropoffAddress
                ? _value.dropoffAddress
                : dropoffAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as PaymentMethod,
            requestedVehicleType: freezed == requestedVehicleType
                ? _value.requestedVehicleType
                : requestedVehicleType // ignore: cast_nullable_to_non_nullable
                      as VehicleType?,
            estimatedFare: freezed == estimatedFare
                ? _value.estimatedFare
                : estimatedFare // ignore: cast_nullable_to_non_nullable
                      as double?,
            estimatedDistance: freezed == estimatedDistance
                ? _value.estimatedDistance
                : estimatedDistance // ignore: cast_nullable_to_non_nullable
                      as double?,
            estimatedDuration: freezed == estimatedDuration
                ? _value.estimatedDuration
                : estimatedDuration // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RideRequestImplCopyWith<$Res>
    implements $RideRequestCopyWith<$Res> {
  factory _$$RideRequestImplCopyWith(
    _$RideRequestImpl value,
    $Res Function(_$RideRequestImpl) then,
  ) = __$$RideRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'passenger_id') String passengerId,
    @JsonKey(name: 'pickup_latitude') double pickupLatitude,
    @JsonKey(name: 'pickup_longitude') double pickupLongitude,
    @JsonKey(name: 'pickup_address') String pickupAddress,
    @JsonKey(name: 'dropoff_latitude') double dropoffLatitude,
    @JsonKey(name: 'dropoff_longitude') double dropoffLongitude,
    @JsonKey(name: 'dropoff_address') String dropoffAddress,
    @JsonKey(name: 'payment_method') PaymentMethod paymentMethod,
    @JsonKey(name: 'requested_vehicle_type') VehicleType? requestedVehicleType,
    @JsonKey(name: 'estimated_fare') double? estimatedFare,
    @JsonKey(name: 'estimated_distance') double? estimatedDistance,
    @JsonKey(name: 'estimated_duration') int? estimatedDuration,
    String? status,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$RideRequestImplCopyWithImpl<$Res>
    extends _$RideRequestCopyWithImpl<$Res, _$RideRequestImpl>
    implements _$$RideRequestImplCopyWith<$Res> {
  __$$RideRequestImplCopyWithImpl(
    _$RideRequestImpl _value,
    $Res Function(_$RideRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? passengerId = null,
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? pickupAddress = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? dropoffAddress = null,
    Object? paymentMethod = null,
    Object? requestedVehicleType = freezed,
    Object? estimatedFare = freezed,
    Object? estimatedDistance = freezed,
    Object? estimatedDuration = freezed,
    Object? status = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$RideRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        passengerId: null == passengerId
            ? _value.passengerId
            : passengerId // ignore: cast_nullable_to_non_nullable
                  as String,
        pickupLatitude: null == pickupLatitude
            ? _value.pickupLatitude
            : pickupLatitude // ignore: cast_nullable_to_non_nullable
                  as double,
        pickupLongitude: null == pickupLongitude
            ? _value.pickupLongitude
            : pickupLongitude // ignore: cast_nullable_to_non_nullable
                  as double,
        pickupAddress: null == pickupAddress
            ? _value.pickupAddress
            : pickupAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        dropoffLatitude: null == dropoffLatitude
            ? _value.dropoffLatitude
            : dropoffLatitude // ignore: cast_nullable_to_non_nullable
                  as double,
        dropoffLongitude: null == dropoffLongitude
            ? _value.dropoffLongitude
            : dropoffLongitude // ignore: cast_nullable_to_non_nullable
                  as double,
        dropoffAddress: null == dropoffAddress
            ? _value.dropoffAddress
            : dropoffAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as PaymentMethod,
        requestedVehicleType: freezed == requestedVehicleType
            ? _value.requestedVehicleType
            : requestedVehicleType // ignore: cast_nullable_to_non_nullable
                  as VehicleType?,
        estimatedFare: freezed == estimatedFare
            ? _value.estimatedFare
            : estimatedFare // ignore: cast_nullable_to_non_nullable
                  as double?,
        estimatedDistance: freezed == estimatedDistance
            ? _value.estimatedDistance
            : estimatedDistance // ignore: cast_nullable_to_non_nullable
                  as double?,
        estimatedDuration: freezed == estimatedDuration
            ? _value.estimatedDuration
            : estimatedDuration // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RideRequestImpl implements _RideRequest {
  const _$RideRequestImpl({
    required this.id,
    @JsonKey(name: 'passenger_id') required this.passengerId,
    @JsonKey(name: 'pickup_latitude') required this.pickupLatitude,
    @JsonKey(name: 'pickup_longitude') required this.pickupLongitude,
    @JsonKey(name: 'pickup_address') required this.pickupAddress,
    @JsonKey(name: 'dropoff_latitude') required this.dropoffLatitude,
    @JsonKey(name: 'dropoff_longitude') required this.dropoffLongitude,
    @JsonKey(name: 'dropoff_address') required this.dropoffAddress,
    @JsonKey(name: 'payment_method') required this.paymentMethod,
    @JsonKey(name: 'requested_vehicle_type') this.requestedVehicleType,
    @JsonKey(name: 'estimated_fare') this.estimatedFare,
    @JsonKey(name: 'estimated_distance') this.estimatedDistance,
    @JsonKey(name: 'estimated_duration') this.estimatedDuration,
    this.status,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$RideRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RideRequestImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'passenger_id')
  final String passengerId;
  @override
  @JsonKey(name: 'pickup_latitude')
  final double pickupLatitude;
  @override
  @JsonKey(name: 'pickup_longitude')
  final double pickupLongitude;
  @override
  @JsonKey(name: 'pickup_address')
  final String pickupAddress;
  @override
  @JsonKey(name: 'dropoff_latitude')
  final double dropoffLatitude;
  @override
  @JsonKey(name: 'dropoff_longitude')
  final double dropoffLongitude;
  @override
  @JsonKey(name: 'dropoff_address')
  final String dropoffAddress;
  @override
  @JsonKey(name: 'payment_method')
  final PaymentMethod paymentMethod;
  @override
  @JsonKey(name: 'requested_vehicle_type')
  final VehicleType? requestedVehicleType;
  @override
  @JsonKey(name: 'estimated_fare')
  final double? estimatedFare;
  @override
  @JsonKey(name: 'estimated_distance')
  final double? estimatedDistance;
  @override
  @JsonKey(name: 'estimated_duration')
  final int? estimatedDuration;
  @override
  final String? status;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RideRequest(id: $id, passengerId: $passengerId, pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, pickupAddress: $pickupAddress, dropoffLatitude: $dropoffLatitude, dropoffLongitude: $dropoffLongitude, dropoffAddress: $dropoffAddress, paymentMethod: $paymentMethod, requestedVehicleType: $requestedVehicleType, estimatedFare: $estimatedFare, estimatedDistance: $estimatedDistance, estimatedDuration: $estimatedDuration, status: $status, expiresAt: $expiresAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.passengerId, passengerId) ||
                other.passengerId == passengerId) &&
            (identical(other.pickupLatitude, pickupLatitude) ||
                other.pickupLatitude == pickupLatitude) &&
            (identical(other.pickupLongitude, pickupLongitude) ||
                other.pickupLongitude == pickupLongitude) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.dropoffLatitude, dropoffLatitude) ||
                other.dropoffLatitude == dropoffLatitude) &&
            (identical(other.dropoffLongitude, dropoffLongitude) ||
                other.dropoffLongitude == dropoffLongitude) &&
            (identical(other.dropoffAddress, dropoffAddress) ||
                other.dropoffAddress == dropoffAddress) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.requestedVehicleType, requestedVehicleType) ||
                other.requestedVehicleType == requestedVehicleType) &&
            (identical(other.estimatedFare, estimatedFare) ||
                other.estimatedFare == estimatedFare) &&
            (identical(other.estimatedDistance, estimatedDistance) ||
                other.estimatedDistance == estimatedDistance) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    passengerId,
    pickupLatitude,
    pickupLongitude,
    pickupAddress,
    dropoffLatitude,
    dropoffLongitude,
    dropoffAddress,
    paymentMethod,
    requestedVehicleType,
    estimatedFare,
    estimatedDistance,
    estimatedDuration,
    status,
    expiresAt,
    createdAt,
  );

  /// Create a copy of RideRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideRequestImplCopyWith<_$RideRequestImpl> get copyWith =>
      __$$RideRequestImplCopyWithImpl<_$RideRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RideRequestImplToJson(this);
  }
}

abstract class _RideRequest implements RideRequest {
  const factory _RideRequest({
    required final String id,
    @JsonKey(name: 'passenger_id') required final String passengerId,
    @JsonKey(name: 'pickup_latitude') required final double pickupLatitude,
    @JsonKey(name: 'pickup_longitude') required final double pickupLongitude,
    @JsonKey(name: 'pickup_address') required final String pickupAddress,
    @JsonKey(name: 'dropoff_latitude') required final double dropoffLatitude,
    @JsonKey(name: 'dropoff_longitude') required final double dropoffLongitude,
    @JsonKey(name: 'dropoff_address') required final String dropoffAddress,
    @JsonKey(name: 'payment_method') required final PaymentMethod paymentMethod,
    @JsonKey(name: 'requested_vehicle_type')
    final VehicleType? requestedVehicleType,
    @JsonKey(name: 'estimated_fare') final double? estimatedFare,
    @JsonKey(name: 'estimated_distance') final double? estimatedDistance,
    @JsonKey(name: 'estimated_duration') final int? estimatedDuration,
    final String? status,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$RideRequestImpl;

  factory _RideRequest.fromJson(Map<String, dynamic> json) =
      _$RideRequestImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'passenger_id')
  String get passengerId;
  @override
  @JsonKey(name: 'pickup_latitude')
  double get pickupLatitude;
  @override
  @JsonKey(name: 'pickup_longitude')
  double get pickupLongitude;
  @override
  @JsonKey(name: 'pickup_address')
  String get pickupAddress;
  @override
  @JsonKey(name: 'dropoff_latitude')
  double get dropoffLatitude;
  @override
  @JsonKey(name: 'dropoff_longitude')
  double get dropoffLongitude;
  @override
  @JsonKey(name: 'dropoff_address')
  String get dropoffAddress;
  @override
  @JsonKey(name: 'payment_method')
  PaymentMethod get paymentMethod;
  @override
  @JsonKey(name: 'requested_vehicle_type')
  VehicleType? get requestedVehicleType;
  @override
  @JsonKey(name: 'estimated_fare')
  double? get estimatedFare;
  @override
  @JsonKey(name: 'estimated_distance')
  double? get estimatedDistance;
  @override
  @JsonKey(name: 'estimated_duration')
  int? get estimatedDuration;
  @override
  String? get status;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of RideRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideRequestImplCopyWith<_$RideRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
