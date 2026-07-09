import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import '../bloc/driver_home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isOnline = false;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            const _EarningsTabPlaceholder(),
            const _ProfileTabPlaceholder(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return BlocBuilder<DriverHomeBloc, DriverHomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOnline ? 'You are online' : 'You are offline',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isOnline
                            ? 'Waiting for ride requests...'
                            : 'Go online to start receiving rides',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Switch(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() => _isOnline = value);
                      context
                          .read<DriverHomeBloc>()
                          .add(DriverToggleOnline(value));
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-26.2041, 28.0473), // Example: Johannesburg
                  zoom: 14,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
          ],
        );
      },
    );
  }
// ... rest of the file
            Expanded(
              child: state is DriverIncomingRequest
                  ? _buildIncomingRequest(context, state)
                  : _buildMapPlaceholder(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Map will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequest(
      BuildContext context, DriverIncomingRequest state) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.notifications_active, size: 48),
              const SizedBox(height: 16),
              Text(
                'New Ride Request!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '3.5 km away • ~R 45.00',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.trip_origin, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.request.pickupAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.request.dropoffAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ZeniButton(
                      label: 'Decline',
                      onPressed: () {
                        context.read<DriverHomeBloc>().add(
                              DriverDeclineRide(state.request.id),
                            );
                      },
                      isOutlined: true,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ZeniButton(
                      label: 'Accept',
                      onPressed: () {
                        context.read<DriverHomeBloc>().add(
                              DriverAcceptRide(state.request.id),
                            );
                        context.go('/ride',
                            extra: {'rideId': state.request.id});
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsTabPlaceholder extends StatelessWidget {
  const _EarningsTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Earnings', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProfileTabPlaceholder extends StatelessWidget {
  const _ProfileTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profile', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
