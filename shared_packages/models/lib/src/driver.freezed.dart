// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Driver _$DriverFromJson(Map<String, dynamic> json) {
  return _Driver.fromJson(json);
}

/// @nodoc
mixin _$Driver {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_id')
  String get profileId => throw _privateConstructorUsedError;
  DriverStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'license_number')
  String? get licenseNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'license_image_url')
  String? get licenseImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_rides')
  int? get totalRides => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_latitude')
  double? get currentLatitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_longitude')
  double? get currentLongitude => throw _privateConstructorUsedError;
  double? get heading => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_verified', defaultValue: false)
  bool get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Driver to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Driver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverCopyWith<Driver> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverCopyWith<$Res> {
  factory $DriverCopyWith(Driver value, $Res Function(Driver) then) =
      _$DriverCopyWithImpl<$Res, Driver>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'profile_id') String profileId,
    DriverStatus status,
    @JsonKey(name: 'license_number') String? licenseNumber,
    @JsonKey(name: 'license_image_url') String? licenseImageUrl,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'total_rides') int? totalRides,
    @JsonKey(name: 'current_latitude') double? currentLatitude,
    @JsonKey(name: 'current_longitude') double? currentLongitude,
    double? heading,
    @JsonKey(name: 'is_verified', defaultValue: false) bool isVerified,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$DriverCopyWithImpl<$Res, $Val extends Driver>
    implements $DriverCopyWith<$Res> {
  _$DriverCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Driver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = null,
    Object? status = null,
    Object? licenseNumber = freezed,
    Object? licenseImageUrl = freezed,
    Object? averageRating = freezed,
    Object? totalRides = freezed,
    Object? currentLatitude = freezed,
    Object? currentLongitude = freezed,
    Object? heading = freezed,
    Object? isVerified = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            profileId: null == profileId
                ? _value.profileId
                : profileId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DriverStatus,
            licenseNumber: freezed == licenseNumber
                ? _value.licenseNumber
                : licenseNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            licenseImageUrl: freezed == licenseImageUrl
                ? _value.licenseImageUrl
                : licenseImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalRides: freezed == totalRides
                ? _value.totalRides
                : totalRides // ignore: cast_nullable_to_non_nullable
                      as int?,
            currentLatitude: freezed == currentLatitude
                ? _value.currentLatitude
                : currentLatitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            currentLongitude: freezed == currentLongitude
                ? _value.currentLongitude
                : currentLongitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            heading: freezed == heading
                ? _value.heading
                : heading // ignore: cast_nullable_to_non_nullable
                      as double?,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DriverImplCopyWith<$Res> implements $DriverCopyWith<$Res> {
  factory _$$DriverImplCopyWith(
    _$DriverImpl value,
    $Res Function(_$DriverImpl) then,
  ) = __$$DriverImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'profile_id') String profileId,
    DriverStatus status,
    @JsonKey(name: 'license_number') String? licenseNumber,
    @JsonKey(name: 'license_image_url') String? licenseImageUrl,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'total_rides') int? totalRides,
    @JsonKey(name: 'current_latitude') double? currentLatitude,
    @JsonKey(name: 'current_longitude') double? currentLongitude,
    double? heading,
    @JsonKey(name: 'is_verified', defaultValue: false) bool isVerified,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$DriverImplCopyWithImpl<$Res>
    extends _$DriverCopyWithImpl<$Res, _$DriverImpl>
    implements _$$DriverImplCopyWith<$Res> {
  __$$DriverImplCopyWithImpl(
    _$DriverImpl _value,
    $Res Function(_$DriverImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Driver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = null,
    Object? status = null,
    Object? licenseNumber = freezed,
    Object? licenseImageUrl = freezed,
    Object? averageRating = freezed,
    Object? totalRides = freezed,
    Object? currentLatitude = freezed,
    Object? currentLongitude = freezed,
    Object? heading = freezed,
    Object? isVerified = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$DriverImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        profileId: null == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DriverStatus,
        licenseNumber: freezed == licenseNumber
            ? _value.licenseNumber
            : licenseNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        licenseImageUrl: freezed == licenseImageUrl
            ? _value.licenseImageUrl
            : licenseImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalRides: freezed == totalRides
            ? _value.totalRides
            : totalRides // ignore: cast_nullable_to_non_nullable
                  as int?,
        currentLatitude: freezed == currentLatitude
            ? _value.currentLatitude
            : currentLatitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        currentLongitude: freezed == currentLongitude
            ? _value.currentLongitude
            : currentLongitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        heading: freezed == heading
            ? _value.heading
            : heading // ignore: cast_nullable_to_non_nullable
                  as double?,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverImpl implements _Driver {
  const _$DriverImpl({
    required this.id,
    @JsonKey(name: 'profile_id') required this.profileId,
    required this.status,
    @JsonKey(name: 'license_number') this.licenseNumber,
    @JsonKey(name: 'license_image_url') this.licenseImageUrl,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'total_rides') this.totalRides,
    @JsonKey(name: 'current_latitude') this.currentLatitude,
    @JsonKey(name: 'current_longitude') this.currentLongitude,
    this.heading,
    @JsonKey(name: 'is_verified', defaultValue: false) required this.isVerified,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$DriverImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'profile_id')
  final String profileId;
  @override
  final DriverStatus status;
  @override
  @JsonKey(name: 'license_number')
  final String? licenseNumber;
  @override
  @JsonKey(name: 'license_image_url')
  final String? licenseImageUrl;
  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'total_rides')
  final int? totalRides;
  @override
  @JsonKey(name: 'current_latitude')
  final double? currentLatitude;
  @override
  @JsonKey(name: 'current_longitude')
  final double? currentLongitude;
  @override
  final double? heading;
  @override
  @JsonKey(name: 'is_verified', defaultValue: false)
  final bool isVerified;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Driver(id: $id, profileId: $profileId, status: $status, licenseNumber: $licenseNumber, licenseImageUrl: $licenseImageUrl, averageRating: $averageRating, totalRides: $totalRides, currentLatitude: $currentLatitude, currentLongitude: $currentLongitude, heading: $heading, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.licenseImageUrl, licenseImageUrl) ||
                other.licenseImageUrl == licenseImageUrl) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalRides, totalRides) ||
                other.totalRides == totalRides) &&
            (identical(other.currentLatitude, currentLatitude) ||
                other.currentLatitude == currentLatitude) &&
            (identical(other.currentLongitude, currentLongitude) ||
                other.currentLongitude == currentLongitude) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    profileId,
    status,
    licenseNumber,
    licenseImageUrl,
    averageRating,
    totalRides,
    currentLatitude,
    currentLongitude,
    heading,
    isVerified,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Driver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverImplCopyWith<_$DriverImpl> get copyWith =>
      __$$DriverImplCopyWithImpl<_$DriverImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverImplToJson(this);
  }
}

abstract class _Driver implements Driver {
  const factory _Driver({
    required final String id,
    @JsonKey(name: 'profile_id') required final String profileId,
    required final DriverStatus status,
    @JsonKey(name: 'license_number') final String? licenseNumber,
    @JsonKey(name: 'license_image_url') final String? licenseImageUrl,
    @JsonKey(name: 'average_rating') final double? averageRating,
    @JsonKey(name: 'total_rides') final int? totalRides,
    @JsonKey(name: 'current_latitude') final double? currentLatitude,
    @JsonKey(name: 'current_longitude') final double? currentLongitude,
    final double? heading,
    @JsonKey(name: 'is_verified', defaultValue: false)
    required final bool isVerified,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$DriverImpl;

  factory _Driver.fromJson(Map<String, dynamic> json) = _$DriverImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'profile_id')
  String get profileId;
  @override
  DriverStatus get status;
  @override
  @JsonKey(name: 'license_number')
  String? get licenseNumber;
  @override
  @JsonKey(name: 'license_image_url')
  String? get licenseImageUrl;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'total_rides')
  int? get totalRides;
  @override
  @JsonKey(name: 'current_latitude')
  double? get currentLatitude;
  @override
  @JsonKey(name: 'current_longitude')
  double? get currentLongitude;
  @override
  double? get heading;
  @override
  @JsonKey(name: 'is_verified', defaultValue: false)
  bool get isVerified;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of Driver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverImplCopyWith<_$DriverImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
