import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

@freezed
class Driver with _$Driver {
  const factory Driver({
    required String id,
    @JsonKey(name: 'profile_id') required String profileId,
    required DriverStatus status,
    @JsonKey(name: 'license_number') String? licenseNumber,
    @JsonKey(name: 'license_image_url') String? licenseImageUrl,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'total_rides') int? totalRides,
    @JsonKey(name: 'current_latitude') double? currentLatitude,
    @JsonKey(name: 'current_longitude') double? currentLongitude,
    double? heading,
    @JsonKey(name: 'is_verified', defaultValue: false) required bool isVerified,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Driver;

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
}
