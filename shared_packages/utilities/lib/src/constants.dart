/// App-wide constants.
class ZeniConstants {
  ZeniConstants._();

  // App info
  static const String appName = 'Zeni';
  static const String riderAppName = 'Zeni Rider';
  static const String driverAppName = 'Zeni Driver';

  // Location
  static const double defaultSearchRadiusKm = 5.0;
  static const int locationUpdateIntervalSeconds = 5;
  static const double defaultZoomLevel = 15.0;

  // Ride
  static const int requestTimeoutSeconds = 30;
  static const double minFare = 20.0;
  static const double costPerKm = 8.0;
  static const double costPerMinute = 1.5;

  // Storage buckets
  static const String driverDocumentsBucket = 'driver_documents';
  static const String vehiclePhotosBucket = 'vehicle_photos';
  static const String profileAvatarsBucket = 'profile_avatars';

  // Supabase tables
  static const String profilesTable = 'profiles';
  static const String passengersTable = 'passengers';
  static const String driversTable = 'drivers';
  static const String vehiclesTable = 'vehicles';
  static const String vehicleDocumentsTable = 'vehicle_documents';
  static const String rideRequestsTable = 'ride_requests';
  static const String ridesTable = 'rides';
  static const String rideLocationsTable = 'ride_locations';
  static const String rideStatusHistoryTable = 'ride_status_history';
  static const String ratingsTable = 'ratings';
  static const String reviewsTable = 'reviews';
  static const String deviceTokensTable = 'device_tokens';

  // Colors
  static const int primaryColorValue = 0xFF6C63FF;
  static const int secondaryColorValue = 0xFFFF6584;
  static const int accentColorValue = 0xFF00C9A7;
}
