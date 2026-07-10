import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_models/zeni_models.dart';
import '../../home/bloc/driver_home_bloc.dart';

class RidePage extends StatelessWidget {
  final String? rideId;
  const RidePage({super.key, this.rideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DriverHomeBloc, DriverHomeState>(
        builder: (context, state) {
          if (state is! DriverOnRide) {
            return const Center(child: CircularProgressIndicator());
          }
          final ride = state.ride;
          final status = ride.status;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Navigation map', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _buildStatusChip(context, status)),
                      const SizedBox(height: 16),
                      _buildActionButtons(context, ride, status),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, RideStatus status) {
    final (label, icon) = switch (status) {
      RideStatus.accepted => ('Heading to pickup', Icons.navigation),
      RideStatus.driverArrived => ('Arrived at pickup', Icons.location_on),
      RideStatus.started => ('Trip in progress', Icons.directions_car),
      RideStatus.completed => ('Trip completed', Icons.check_circle),
      _ => (status.name, Icons.help),
    };

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildActionButtons(BuildContext context, Ride ride, RideStatus status) {
    final bloc = context.read<DriverHomeBloc>();
    final rideId = ride.id;

    switch (status) {
      case RideStatus.accepted:
        return ZeniButton(
          label: 'I\'ve Arrived',
          onPressed: () => bloc.add(DriverUpdateRideStatus(rideId, RideStatus.driverArrived)),
          icon: Icons.location_on,
        );
      case RideStatus.driverArrived:
        return ZeniButton(
          label: 'Start Trip',
          onPressed: () => bloc.add(DriverUpdateRideStatus(rideId, RideStatus.started)),
          icon: Icons.play_arrow,
        );
      case RideStatus.started:
        return Column(
          children: [
            ZeniButton(
              label: 'Complete Trip',
              onPressed: () => bloc.add(DriverUpdateRideStatus(rideId, RideStatus.completed)),
              icon: Icons.flag,
            ),
          ],
        );
      case RideStatus.completed:
        return ZeniButton(
          label: 'Back to Home',
          onPressed: () => context.go('/home'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
