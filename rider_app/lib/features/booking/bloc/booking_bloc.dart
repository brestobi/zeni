import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class BookingEvent {}

final class InitializeBooking extends BookingEvent {}

final class PickupUpdated extends BookingEvent {
  final String address;
  final double latitude;
  final double longitude;
  PickupUpdated({required this.address, required this.latitude, required this.longitude});
}

final class DropoffUpdated extends BookingEvent {
  final String address;
  final double latitude;
  final double longitude;
  DropoffUpdated({required this.address, required this.latitude, required this.longitude});
}

final class PaymentMethodSelected extends BookingEvent {
  final PaymentMethod method;
  PaymentMethodSelected(this.method);
}

final class EstimateRoute extends BookingEvent {}

final class SubmitRideRequest extends BookingEvent {}

// --- States ---
sealed class BookingState {
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final PaymentMethod paymentMethod;

  const BookingState({
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.paymentMethod,
  });
}

final class BookingInitial extends BookingState {
  const BookingInitial({
    super.pickupAddress = '',
    super.pickupLatitude = 0.0,
    super.pickupLongitude = 0.0,
    super.dropoffAddress = '',
    super.dropoffLatitude = 0.0,
    super.dropoffLongitude = 0.0,
    super.paymentMethod = PaymentMethod.cash,
  });
}

final class BookingLoading extends BookingState {
  const BookingLoading({
    required super.pickupAddress,
    required super.pickupLatitude,
    required super.pickupLongitude,
    required super.dropoffAddress,
    required super.dropoffLatitude,
    required super.dropoffLongitude,
    required super.paymentMethod,
  });
}

final class BookingEstimated extends BookingState {
  final double estimatedFare;
  final double estimatedDistance; // in km
  final int estimatedDuration; // in minutes

  const BookingEstimated({
    required super.pickupAddress,
    required super.pickupLatitude,
    required super.pickupLongitude,
    required super.dropoffAddress,
    required super.dropoffLatitude,
    required super.dropoffLongitude,
    required super.paymentMethod,
    required this.estimatedFare,
    required this.estimatedDistance,
    required this.estimatedDuration,
  });
}

final class BookingRequestCreated extends BookingState {
  final String rideRequestId;

  const BookingRequestCreated({
    required super.pickupAddress,
    required super.pickupLatitude,
    required super.pickupLongitude,
    required super.dropoffAddress,
    required super.dropoffLatitude,
    required super.dropoffLongitude,
    required super.paymentMethod,
    required this.rideRequestId,
  });
}

final class BookingError extends BookingState {
  final String message;

  const BookingError({
    required super.pickupAddress,
    required super.pickupLatitude,
    required super.pickupLongitude,
    required super.dropoffAddress,
    required super.dropoffLatitude,
    required super.dropoffLongitude,
    required super.paymentMethod,
    required this.message,
  });
}

// --- BLoC ---
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final SupabaseClient _supabase;

  BookingBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(const BookingInitial()) {
    on<InitializeBooking>(_onInitialize);
    on<PickupUpdated>(_onPickupUpdated);
    on<DropoffUpdated>(_onDropoffUpdated);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<EstimateRoute>(_onEstimateRoute);
    on<SubmitRideRequest>(_onSubmitRideRequest);
  }

  void _onInitialize(InitializeBooking event, Emitter<BookingState> emit) {
    emit(const BookingInitial());
  }

  void _onPickupUpdated(PickupUpdated event, Emitter<BookingState> emit) {
    emit(BookingInitial(
      pickupAddress: event.address,
      pickupLatitude: event.latitude,
      pickupLongitude: event.longitude,
      dropoffAddress: state.dropoffAddress,
      dropoffLatitude: state.dropoffLatitude,
      dropoffLongitude: state.dropoffLongitude,
      paymentMethod: state.paymentMethod,
    ));
  }

  void _onDropoffUpdated(DropoffUpdated event, Emitter<BookingState> emit) {
    emit(BookingInitial(
      pickupAddress: state.pickupAddress,
      pickupLatitude: state.pickupLatitude,
      pickupLongitude: state.pickupLongitude,
      dropoffAddress: event.address,
      dropoffLatitude: event.latitude,
      dropoffLongitude: event.longitude,
      paymentMethod: state.paymentMethod,
    ));
  }

  void _onPaymentMethodSelected(PaymentMethodSelected event, Emitter<BookingState> emit) {
    if (state is BookingEstimated) {
      final s = state as BookingEstimated;
      emit(BookingEstimated(
        pickupAddress: state.pickupAddress,
        pickupLatitude: state.pickupLatitude,
        pickupLongitude: state.pickupLongitude,
        dropoffAddress: state.dropoffAddress,
        dropoffLatitude: state.dropoffLatitude,
        dropoffLongitude: state.dropoffLongitude,
        paymentMethod: event.method,
        estimatedFare: s.estimatedFare,
        estimatedDistance: s.estimatedDistance,
        estimatedDuration: s.estimatedDuration,
      ));
    } else {
      emit(BookingInitial(
        pickupAddress: state.pickupAddress,
        pickupLatitude: state.pickupLatitude,
        pickupLongitude: state.pickupLongitude,
        dropoffAddress: state.dropoffAddress,
        dropoffLatitude: state.dropoffLatitude,
        dropoffLongitude: state.dropoffLongitude,
        paymentMethod: event.method,
      ));
    }
  }

  Future<void> _onEstimateRoute(
    EstimateRoute event,
    Emitter<BookingState> emit,
  ) async {
    if (state.pickupAddress.isEmpty || state.dropoffAddress.isEmpty) {
      emit(BookingError(
        pickupAddress: state.pickupAddress,
        pickupLatitude: state.pickupLatitude,
        pickupLongitude: state.pickupLongitude,
        dropoffAddress: state.dropoffAddress,
        dropoffLatitude: state.dropoffLatitude,
        dropoffLongitude: state.dropoffLongitude,
        paymentMethod: state.paymentMethod,
        message: 'Please specify pickup and destination locations.',
      ));
      return;
    }

    emit(BookingLoading(
      pickupAddress: state.pickupAddress,
      pickupLatitude: state.pickupLatitude,
      pickupLongitude: state.pickupLongitude,
      dropoffAddress: state.dropoffAddress,
      dropoffLatitude: state.dropoffLatitude,
      dropoffLongitude: state.dropoffLongitude,
      paymentMethod: state.paymentMethod,
    ));

    try {
      // Call server-side fare calculation function
      // This ensures the fare cannot be manipulated by a modified client
      final fare = await _supabase.rpc(
        'calculate_fare',
        params: {
          'pickup_lat': state.pickupLatitude,
          'pickup_lng': state.pickupLongitude,
          'dropoff_lat': state.dropoffLatitude,
          'dropoff_lng': state.dropoffLongitude,
          'vehicle_type_param': 'standard', // TODO: make this dynamic based on vehicle selection
        },
      );

      // Calculate distance client-side for display only (not used for billing)
      final distance = _calculateDistance(
        state.pickupLatitude,
        state.pickupLongitude,
        state.dropoffLatitude,
        state.dropoffLongitude,
      );
      final duration = (distance * 2.5).round(); // ~2.5 minutes per km

      emit(BookingEstimated(
        pickupAddress: state.pickupAddress,
        pickupLatitude: state.pickupLatitude,
        pickupLongitude: state.pickupLongitude,
        dropoffAddress: state.dropoffAddress,
        dropoffLatitude: state.dropoffLatitude,
        dropoffLongitude: state.dropoffLongitude,
        paymentMethod: state.paymentMethod,
        estimatedFare: (fare as num).toDouble(),
        estimatedDistance: double.parse(distance.toStringAsFixed(2)),
        estimatedDuration: duration > 1 ? duration : 2,
      ));
    } catch (e) {
      emit(BookingError(
        pickupAddress: state.pickupAddress,
        pickupLatitude: state.pickupLatitude,
        pickupLongitude: state.pickupLongitude,
        dropoffAddress: state.dropoffAddress,
        dropoffLatitude: state.dropoffLatitude,
        dropoffLongitude: state.dropoffLongitude,
        paymentMethod: state.paymentMethod,
        message: 'Failed to calculate estimation: $e',
      ));
    }
  }

  Future<void> _onSubmitRideRequest(
    SubmitRideRequest event,
    Emitter<BookingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookingEstimated) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      emit(BookingError(
        pickupAddress: state.pickupAddress,
        pickupLatitude: state.pickupLatitude,
        pickupLongitude: state.pickupLongitude,
        dropoffAddress: state.dropoffAddress,
        dropoffLatitude: state.dropoffLatitude,
        dropoffLongitude: state.dropoffLongitude,
        paymentMethod: state.paymentMethod,
        message: 'You must be logged in to request a ride.',
      ));
      return;
    }

    emit(BookingLoading(
      pickupAddress: state.pickupAddress,
      pickupLatitude: state.pickupLatitude,
      pickupLongitude: state.pickupLongitude,
      dropoffAddress: state.dropoffAddress,
      dropoffLatitude: state.dropoffLatitude,
      dropoffLongitude: state.dropoffLongitude,
      paymentMethod: state.paymentMethod,
    ));

    try {
      final response = await _supabase.from('ride_requests').insert({
        'passenger_id': userId,
        'pickup_latitude': currentState.pickupLatitude,
        'pickup_longitude': currentState.pickupLongitude,
        'pickup_address': currentState.pickupAddress,
        'dropoff_latitude': currentState.dropoffLatitude,
        'dropoff_longitude': currentState.dropoffLongitude,
        'dropoff_address': currentState.dropoffAddress,
        'payment_method': currentState.paymentMethod.name,
        'status': 'pending',
        'estimated_fare': currentState.estimatedFare,
        'estimated_distance': currentState.estimatedDistance,
        'estimated_duration': currentState.estimatedDuration,
      }).select().single();

      emit(BookingRequestCreated(
        pickupAddress: currentState.pickupAddress,
        pickupLatitude: currentState.pickupLatitude,
        pickupLongitude: currentState.pickupLongitude,
        dropoffAddress: currentState.dropoffAddress,
        dropoffLatitude: currentState.dropoffLatitude,
        dropoffLongitude: currentState.dropoffLongitude,
        paymentMethod: currentState.paymentMethod,
        rideRequestId: response['id'] as String,
      ));
    } catch (e) {
      emit(BookingError(
        pickupAddress: currentState.pickupAddress,
        pickupLatitude: currentState.pickupLatitude,
        pickupLongitude: currentState.pickupLongitude,
        dropoffAddress: currentState.dropoffAddress,
        dropoffLatitude: currentState.dropoffLatitude,
        dropoffLongitude: currentState.dropoffLongitude,
        paymentMethod: currentState.paymentMethod,
        message: 'Failed to create ride request: $e',
      ));
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula
    const double earthRadiusKm = 6371.0;
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1Rad) * math.cos(lat2Rad);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

