/// Enums shared across the Zeni platform.
enum RideStatus {
  pending,
  accepted,
  driverArrived,
  started,
  completed,
  cancelled,
}

enum DriverStatus {
  offline,
  online,
  onRide,
  pendingApproval,
  suspended,
}

enum PaymentMethod {
  cash,
  yocoCard,
  mtnMomo,
}

enum PaymentStatus {
  pending,
  authorized,
  captured,
  failed,
  refunded,
}

enum VehicleType {
  standard,
  comfort,
  premium,
  motorcycle,
}

enum DocumentStatus {
  pending,
  verified,
  rejected,
}
