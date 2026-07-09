import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RideTrackingPage extends StatelessWidget {
  final String rideId;
  const RideTrackingPage({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Map
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Live tracking map',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Trip info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Finding your driver...',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated pickup: 3-5 min',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Driver info placeholder
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Waiting for driver',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Your ride is being matched',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Safety button
                      IconButton(
                        onPressed: () {
                          // TODO: Trigger SOS
                        },
                        icon: const Icon(Icons.shield, color: Colors.blue),
                        tooltip: 'Safety',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
