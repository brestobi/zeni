import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/ride_request_bloc.dart';
import 'package:zeni_widgets/zeni_widgets.dart';

class IncomingRequestPage extends StatelessWidget {
  const IncomingRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverRideRequestBloc(
        supabase: Supabase.instance.client,
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
                children: [
                  Text('Pickup: ${request.pickupAddress}'),
                  Text('Dropoff: ${request.dropoffAddress}'),
                  const Spacer(),
                  ZeniButton(
                    label: 'Accept Ride',
                    onPressed: () async {
                      // Logic to accept ride (update status in DB)
                      await Supabase.instance.client
                          .from('rides')
                          .insert({
                        'ride_request_id': request.id,
                        'driver_id': Supabase.instance.client.auth.currentUser!.id,
                        'status': 'accepted',
                      });
                      
                      await Supabase.instance.client
                          .from('ride_requests')
                          .update({'status': 'accepted'})
                          .eq('id', request.id);
                    },
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
