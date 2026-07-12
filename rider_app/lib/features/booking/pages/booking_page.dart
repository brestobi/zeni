import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_models/zeni_models.dart';
import '../../../../core/services/location_service.dart';
import '../bloc/booking_bloc.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc()..add(InitializeBooking()),
      child: const _BookingPageContent(),
    );
  }
}

class _BookingPageContent extends StatefulWidget {
  const _BookingPageContent();

  @override
  State<_BookingPageContent> createState() => _BookingPageContentState();
}

class _BookingPageContentState extends State<_BookingPageContent> {
  GoogleMapController? _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  final List<Map<String, dynamic>> _popularLocations = [
    {
      'name': 'O.R. Tambo International Airport',
      'address': 'Kempton Park, Johannesburg',
      'lat': -26.1367,
      'lng': 28.2411
    },
    {
      'name': 'Sandton City Shopping Centre',
      'address': '83 Rivonia Rd, Sandhurst, Sandton',
      'lat': -26.1075,
      'lng': 28.0567
    },
    {
      'name': 'Rosebank Mall',
      'address': '15A Cradock Ave, Rosebank, Johannesburg',
      'lat': -26.1460,
      'lng': 28.0425
    },
    {
      'name': 'Vilakazi Street, Soweto',
      'address': 'Orlando West, Soweto',
      'lat': -26.2386,
      'lng': 27.9099
    },
    {
      'name': 'Johannesburg Park Station',
      'address': 'Rissik St, Johannesburg CBD',
      'lat': -26.1970,
      'lng': 28.0420
    },
  ];

  @override
  void initState() {
    super.initState();
    _setCurrentLocationAsPickup();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _setCurrentLocationAsPickup() async {
    try {
      final granted = await LocationService.requestPermission();
      if (!granted) {
        // Fallback to default
        _setPickupLocation('Current Location (Default)', -26.2041, 28.0473);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _setPickupLocation('Current Location', position.latitude, position.longitude);
    } catch (e) {
      _setPickupLocation('Current Location (Default)', -26.2041, 28.0473);
    }
  }

  void _setPickupLocation(String address, double lat, double lng) {
    if (!mounted) return;
    _pickupController.text = address;
    context.read<BookingBloc>().add(
          PickupUpdated(address: address, latitude: lat, longitude: lng),
        );
    _animateCamera(lat, lng);
  }

  void _setDropoffLocation(String address, double lat, double lng) {
    if (!mounted) return;
    _dropoffController.text = address;
    context.read<BookingBloc>().add(
          DropoffUpdated(address: address, latitude: lat, longitude: lng),
        );
    
    // Auto-trigger route estimation once destination is picked
    context.read<BookingBloc>().add(EstimateRoute());
    _animateCamera(lat, lng);
  }

  void _animateCamera(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );
  }

  void _showSearchBottomSheet(BuildContext context, bool isPickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isPickup ? 'Enter Pickup Location' : 'Enter Destination',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ZeniTextField(
                label: 'Search Address',
                hint: 'e.g., Sandton City',
                onChanged: (val) {
                  // In a real application, search Google Places API.
                  // For iteration purposes, we show the popular locations filtered by name.
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Popular Locations',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _popularLocations.length,
                  itemBuilder: (ctx, idx) {
                    final item = _popularLocations[idx];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.orange),
                      title: Text(item['name']),
                      subtitle: Text(item['address']),
                      onTap: () {
                        if (isPickup) {
                          _setPickupLocation(item['name'], item['lat'], item['lng']);
                        } else {
                          _setDropoffLocation(item['name'], item['lat'], item['lng']);
                        }
                        Navigator.pop(modalContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingRequestCreated) {
          // Navigate to ride tracking with the newly created requestId
          context.go('/ride-tracking', extra: {'rideId': state.rideRequestId});
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book a Ride'),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Map
            Expanded(
              child: Stack(
                children: [
                  BlocBuilder<BookingBloc, BookingState>(
                    buildWhen: (prev, curr) =>
                        prev.pickupLatitude != curr.pickupLatitude ||
                        prev.dropoffLatitude != curr.dropoffLatitude,
                    builder: (context, state) {
                      Set<Marker> markers = {};
                      if (state.pickupLatitude != 0.0) {
                        markers.add(
                          Marker(
                            markerId: const MarkerId('pickup'),
                            position: LatLng(state.pickupLatitude, state.pickupLongitude),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            infoWindow: const InfoWindow(title: 'Pickup Location'),
                          ),
                        );
                      }
                      if (state.dropoffLatitude != 0.0) {
                        markers.add(
                          Marker(
                            markerId: const MarkerId('dropoff'),
                            position: LatLng(state.dropoffLatitude, state.dropoffLongitude),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                            infoWindow: const InfoWindow(title: 'Destination'),
                          ),
                        );
                      }

                      return GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-26.2041, 28.0473),
                          zoom: 14,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (state.pickupLatitude != 0.0) {
                            _animateCamera(state.pickupLatitude, state.pickupLongitude);
                          }
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: markers,
                      );
                    },
                  ),
                  // Floating back button / overlay elements if needed
                ],
              ),
            ),

            // Booking Form Details Panel
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pickup Search Field
                      GestureDetector(
                        onTap: () => _showSearchBottomSheet(context, true),
                        child: AbsorbPointer(
                          child: ZeniTextField(
                            label: 'Pickup Location',
                            controller: _pickupController,
                            hint: 'Set pickup location',
                            prefixIcon: const Icon(Icons.trip_origin, color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dropoff Search Field
                      GestureDetector(
                        onTap: () => _showSearchBottomSheet(context, false),
                        child: AbsorbPointer(
                          child: ZeniTextField(
                            label: 'Dropoff Location',
                            controller: _dropoffController,
                            hint: 'Where to?',
                            prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estimations & Payment Panel
                      BlocBuilder<BookingBloc, BookingState>(
                        builder: (context, state) {
                          if (state is BookingLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (state is BookingEstimated) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Estimations Display (Distance, Fare, Duration)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _EstimationItem(
                                        icon: Icons.local_taxi,
                                        label: 'Fare',
                                        value: 'R ${state.estimatedFare}',
                                      ),
                                      _EstimationItem(
                                        icon: Icons.map_outlined,
                                        label: 'Distance',
                                        value: '${state.estimatedDistance} km',
                                      ),
                                      _EstimationItem(
                                        icon: Icons.access_time,
                                        label: 'Duration',
                                        value: '${state.estimatedDuration} min',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Payment Method Picker
                                Text(
                                  'Payment Method',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PaymentSelector(
                                        label: 'Cash',
                                        icon: Icons.money,
                                        isSelected: state.paymentMethod == PaymentMethod.cash,
                                        onTap: () {
                                          context.read<BookingBloc>().add(
                                                PaymentMethodSelected(PaymentMethod.cash),
                                              );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Tooltip(
                                        message: 'Card payment coming soon',
                                        child: Opacity(
                                          opacity: 0.5,
                                          child: _PaymentSelector(
                                            label: 'Card',
                                            icon: Icons.credit_card,
                                            isSelected: state.paymentMethod == PaymentMethod.yocoCard,
                                            onTap: () {
                                              // Disabled for now - Card payment not yet implemented
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Tooltip(
                                        message: 'Mobile money coming soon',
                                        child: Opacity(
                                          opacity: 0.5,
                                          child: _PaymentSelector(
                                            label: 'MoMo',
                                            icon: Icons.phone_android,
                                            isSelected: state.paymentMethod == PaymentMethod.mtnMomo,
                                            onTap: () {
                                              // Disabled for now - Mobile money not yet implemented
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Request Button
                                ZeniButton(
                                  label: 'Confirm & Request Ride',
                                  onPressed: () {
                                    context.read<BookingBloc>().add(SubmitRideRequest());
                                  },
                                ),
                              ],
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EstimationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentSelector({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
