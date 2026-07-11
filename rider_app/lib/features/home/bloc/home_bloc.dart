import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

// --- Events ---
sealed class HomeEvent {}

final class LoadNearbyDrivers extends HomeEvent {}

final class UpdateNearbyDrivers extends HomeEvent {
  final List<Map<String, dynamic>> locations;
  UpdateNearbyDrivers(this.locations);
}

// --- States ---
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<RideLocation> nearbyDrivers;
  HomeLoaded(this.nearbyDrivers);
}

final class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// --- BLoC ---
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SupabaseClient _supabase;
  StreamSubscription? _locationsSubscription;

  HomeBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(HomeInitial()) {
    on<LoadNearbyDrivers>(_onLoadNearbyDrivers);
    on<UpdateNearbyDrivers>(_onUpdateNearbyDrivers);
  }

  Future<void> _onLoadNearbyDrivers(
    LoadNearbyDrivers event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // 1. Fetch initial active driver locations
      // In a real-world app, we would use a PostGIS RPC function to query within a radius.
      // For this implementation, we fetch all active locations updated in the last 15 minutes.
      final fifteenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String();
      
      final data = await _supabase
          .from('ride_locations')
          .select()
          .gt('updated_at', fifteenMinutesAgo);

      final List<RideLocation> drivers = (data as List).map((json) {
        return RideLocation(
          id: json['driver_id'] as String,
          rideId: '', // rideId is not applicable here
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
          heading: (json['heading'] as num?)?.toDouble(),
          recordedAt: DateTime.parse(json['updated_at'] as String),
        );
      }).toList();

      emit(HomeLoaded(drivers));

      // 2. Subscribe to real-time changes
      _locationsSubscription?.cancel();
      _locationsSubscription = _supabase
          .from('ride_locations')
          .stream(primaryKey: ['driver_id'])
          .listen((data) {
            if (!isClosed) {
              add(UpdateNearbyDrivers(data));
            }
          });
    } catch (e) {
      emit(HomeError('Failed to load nearby drivers: $e'));
    }
  }

  void _onUpdateNearbyDrivers(
    UpdateNearbyDrivers event,
    Emitter<HomeState> emit,
  ) {
    try {
      final fifteenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 15));
      final List<RideLocation> drivers = event.locations
          .map((json) {
            return RideLocation(
              id: json['driver_id'] as String,
              rideId: '',
              latitude: (json['latitude'] as num).toDouble(),
              longitude: (json['longitude'] as num).toDouble(),
              heading: (json['heading'] as num?)?.toDouble(),
              recordedAt: DateTime.parse(json['updated_at'] as String),
            );
          })
          .where((driver) => driver.recordedAt.isAfter(fifteenMinutesAgo))
          .toList();

      emit(HomeLoaded(drivers));
    } catch (e) {
      // Gracefully handle real-time parsing errors
    }
  }

  @override
  Future<void> close() {
    _locationsSubscription?.cancel();
    return super.close();
  }
}
