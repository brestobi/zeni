import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ride_request_bloc.dart';
import '../../home/bloc/driver_home_bloc.dart';
import 'package:zeni_widgets/zeni_widgets.dart';

/// Displays the first available pending ride request and lets the driver
/// accept or decline it.
///
/// All DB mutations are routed through [DriverHomeBloc] to avoid the
/// race condition of inserting a ride record twice (once here and once
/// in the bloc's _onAcceptRide handler).
class IncomingRequestPage extends StatelessWidget {
  const IncomingRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverRideRequestBloc(
        supabase: context.read<DriverHomeBloc>().supabase,
      )..add(ListenForRideRequests()),
      child: const IncomingRequestView(),
    );
  }
}

class IncomingRequestView extends StatelessWidget {
  const IncomingRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Ride Request')),
      body: BlocBuilder<DriverRideRequestBloc, RideRequestState>(
        builder: (context, state) {
          if (state is RideRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RideRequestAvailable) {
            final request = state.rideRequest;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pickup: ${request.pickupAddress}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dropoff: ${request.dropoffAddress}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ZeniButton(
                          label: 'Decline',
                          isOutlined: true,
                          onPressed: () {
                            // Route decline through DriverHomeBloc so
                            // that state stays consistent.
                            context
                                .read<DriverHomeBloc>()
                                .add(DriverDeclineRide(request.id));
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ZeniButton(
                          label: 'Accept',
                          onPressed: () {
                            // Route acceptance through DriverHomeBloc only.
                            // The bloc handles the DB insert, so we must NOT
                            // duplicate it here.
                            context
                                .read<DriverHomeBloc>()
                                .add(DriverAcceptRide(request.id));
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No active ride requests'));
        },
      ),
    );
  }
}
