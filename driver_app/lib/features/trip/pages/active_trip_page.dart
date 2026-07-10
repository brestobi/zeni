import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/trip_management_bloc.dart';
import 'package:zeni_widgets/zeni_widgets.dart';

class ActiveTripPage extends StatelessWidget {
  final String rideId;
  final String currentStatus;

  const ActiveTripPage({
    super.key,
    required this.rideId,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripManagementBloc(
        supabase: Supabase.instance.client,
      ),
      child: ActiveTripView(rideId: rideId, initialStatus: currentStatus),
    );
  }
}

class ActiveTripView extends StatefulWidget {
  final String rideId;
  final String initialStatus;

  const ActiveTripView({
    super.key,
    required this.rideId,
    required this.initialStatus,
  });

  @override
  State<ActiveTripView> createState() => _ActiveTripViewState();
}

class _ActiveTripViewState extends State<ActiveTripView> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Trip')),
      body: BlocListener<TripManagementBloc, TripState>(
        listener: (context, state) {
          if (state is TripStatusUpdated) {
            setState(() => _status = state.status);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Status: $_status'),
              const Spacer(),
              if (_status == 'accepted')
                ZeniButton(
                  label: 'Arrived',
                  onPressed: () => context.read<TripManagementBloc>().add(
                        UpdateTripStatus(widget.rideId, 'driverArrived'),
                      ),
                ),
              if (_status == 'driverArrived')
                ZeniButton(
                  label: 'Start Trip',
                  onPressed: () => context.read<TripManagementBloc>().add(
                        UpdateTripStatus(widget.rideId, 'started'),
                      ),
                ),
              if (_status == 'started')
                ZeniButton(
                  label: 'Complete Trip',
                  onPressed: () => context.read<TripManagementBloc>().add(
                        UpdateTripStatus(widget.rideId, 'completed'),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
