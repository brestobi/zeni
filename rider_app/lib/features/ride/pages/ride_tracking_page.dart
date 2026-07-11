import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import '../bloc/ride_tracking_bloc.dart';

class RideTrackingPage extends StatelessWidget {
  final String rideId;
  const RideTrackingPage({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideTrackingBloc()..add(StartTrackingRide(rideId)),
      child: _RideTrackingPageContent(rideRequestId: rideId),
    );
  }
}

class _RideTrackingPageContent extends StatefulWidget {
  final String rideRequestId;
  const _RideTrackingPageContent({required this.rideRequestId});

  @override
  State<_RideTrackingPageContent> createState() => _RideTrackingPageContentState();
}

class _RideTrackingPageContentState extends State<_RideTrackingPageContent> {
  GoogleMapController? _mapController;
  bool _hasFitBounds = false;

  void _fitBounds(LatLng p1, LatLng p2) {
    if (_mapController == null) return;
    
    double southWestLat = math.min(p1.latitude, p2.latitude);
    double southWestLng = math.min(p1.longitude, p2.longitude);
    double northEastLat = math.max(p1.latitude, p2.latitude);
    double northEastLng = math.max(p1.longitude, p2.longitude);
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(southWestLat, southWestLng),
          northeast: LatLng(northEastLat, northEastLng),
        ),
        80, // padding
      ),
    );
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.accepted:
        return 'Driver is heading to you';
      case RideStatus.driverArrived:
        return 'Driver has arrived!';
      case RideStatus.started:
        return 'On your way to destination';
      case RideStatus.completed:
        return 'Ride completed';
      case RideStatus.cancelled:
        return 'Ride cancelled';
      default:
        return 'Please wait...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RideTrackingBloc, RideTrackingState>(
      listener: (context, state) {
        if (state is RideTrackingActive && !_hasFitBounds) {
          _hasFitBounds = true;
          // Auto-fit camera to contain pickup location and driver location
          _fitBounds(
            LatLng(state.ride.pickupLatitude, state.ride.pickupLongitude),
            LatLng(state.driverLatitude, state.driverLongitude),
          );
        }
      },
      builder: (context, state) {
        Set<Marker> markers = {};

        // Define map pins based on state
        if (state is RideTrackingActive) {
          markers.addAll([
            Marker(
              markerId: const MarkerId('pickup'),
              position: LatLng(state.ride.pickupLatitude, state.ride.pickupLongitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(title: 'Pickup Location'),
            ),
            Marker(
              markerId: const MarkerId('dropoff'),
              position: LatLng(state.ride.dropoffLatitude, state.ride.dropoffLongitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'Destination'),
            ),
            Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(state.driverLatitude, state.driverLongitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              rotation: state.driverHeading ?? 0.0,
              flat: true,
              anchor: const Offset(0.5, 0.5),
              infoWindow: InfoWindow(title: state.driverProfile.fullName ?? 'Driver'),
            ),
          ]);
        }

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-26.2041, 28.0473),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (state is RideTrackingActive) {
                      _fitBounds(
                        LatLng(state.ride.pickupLatitude, state.ride.pickupLongitude),
                        LatLng(state.driverLatitude, state.driverLongitude),
                      );
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: markers,
                ),

                // Floating Safe/SOS Overlay
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'sos_btn',
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('SOS emergency triggered! Dispatching help.')),
                      );
                    },
                    child: const Icon(Icons.shield),
                  ),
                ),

                // Bottom sheet detailing ride tracking state
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: _buildDetailsPanel(context, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsPanel(BuildContext context, RideTrackingState state) {
    if (state is RideTrackingLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Connecting to live tracking...'),
        ],
      );
    }

    if (state is RideTrackingWaitingForDriver) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.orange),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding your driver...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'We are broadcasting your request to nearby drivers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ZeniButton(
            label: 'Cancel Ride Request',
            onPressed: () async {
              try {
                // Cancel ride_request in Supabase
                await Supabase.instance.client
                    .from('ride_requests')
                    .update({'status': 'cancelled'})
                    .eq('id', widget.rideRequestId);
                if (context.mounted) {
                  context.go('/home');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel request: $e')),
                  );
                }
              }
            },
            isOutlined: true,
            backgroundColor: Colors.red,
            foregroundColor: Colors.red,
          ),
        ],
      );
    }

    if (state is RideTrackingActive) {
      final driverName = state.driverProfile.fullName ?? 'Zeni Partner';
      final vehicleInfo = '${state.vehicleMake} ${state.vehicleModel}';
      final plateNumber = state.vehiclePlate;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(state.ride.status),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Driver details row
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '4.8', // Mock rating
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plateNumber,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Text(
                    vehicleInfo,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Call / chat actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling driver...')),
                    );
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Call Driver'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening chat...')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (state is RideTrackingCompleted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Ride Completed!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Fare: R ${state.ride.fare ?? "45.00"}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ZeniButton(
            label: 'Back to Home',
            onPressed: () => context.go('/home'),
          ),
        ],
      );
    }

    if (state is RideTrackingCancelled) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.cancel, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Ride Cancelled',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.reason,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ZeniButton(
            label: 'Back to Home',
            onPressed: () => context.go('/home'),
          ),
        ],
      );
    }

    // Default error state UI
    final errorMessage = (state is RideTrackingError) ? state.message : 'An error occurred';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'Tracking Error',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ZeniButton(
          label: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }
}
