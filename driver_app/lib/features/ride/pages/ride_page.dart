import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';

class RidePage extends StatefulWidget {
  final String? rideId;
  const RidePage({super.key, this.rideId});

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  String _rideStatus = 'en_route_to_pickup'; // Mock status

  void _updateStatus(String status) {
    setState(() => _rideStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Map
            Expanded(
              child: Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Navigation map',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Ride controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status indicator
                  Center(
                    child: _buildStatusChip(),
                  ),
                  const SizedBox(height: 16),
                  // Passenger info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passenger Name',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('Pickup point address'),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // TODO: Call passenger
                        },
                        icon: const Icon(Icons.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons based on status
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final (label, icon) = switch (_rideStatus) {
      'en_route_to_pickup' => ('Heading to pickup', Icons.navigation),
      'arrived' => ('Arrived at pickup', Icons.location_on),
      'started' => ('Trip in progress', Icons.directions_car),
      'completed' => ('Trip completed', Icons.check_circle),
      _ => ('Unknown', Icons.help),
    };

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildActionButtons() {
    switch (_rideStatus) {
      case 'en_route_to_pickup':
        return ZeniButton(
          label: 'I\'ve Arrived',
          onPressed: () => _updateStatus('arrived'),
          icon: Icons.location_on,
        );
      case 'arrived':
        return ZeniButton(
          label: 'Start Trip',
          onPressed: () => _updateStatus('started'),
          icon: Icons.play_arrow,
        );
      case 'started':
        return Column(
          children: [
            ZeniButton(
              label: 'Complete Trip',
              onPressed: () => _updateStatus('completed'),
              icon: Icons.flag,
            ),
            const SizedBox(height: 12),
            // SOS button
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Trigger SOS alert
              },
              icon: const Icon(Icons.warning, color: Colors.orange),
              label: const Text('Emergency'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ],
        );
      case 'completed':
        return ZeniButton(
          label: 'Back to Home',
          onPressed: () => context.go('/home'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
