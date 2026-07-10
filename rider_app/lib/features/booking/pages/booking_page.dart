import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_models/zeni_models.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  PaymentMethod _selectedPayment = PaymentMethod.cash;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      body: Column(
        children: [
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const ZeniTextField(
                            label: 'Pickup',
                            hint: 'Current location',
                          ),
                          const SizedBox(height: 8),
                          const ZeniTextField(
                            label: 'Destination',
                            hint: 'Where to?',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    icon: Icons.money,
                    label: 'Cash',
                    isSelected: _selectedPayment == PaymentMethod.cash,
                    onTap: () =>
                        setState(() => _selectedPayment = PaymentMethod.cash),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    icon: Icons.credit_card,
                    label: 'Card (Yoco)',
                    isSelected: _selectedPayment == PaymentMethod.yocoCard,
                    onTap: () => setState(
                        () => _selectedPayment = PaymentMethod.yocoCard),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    icon: Icons.phone_android,
                    label: 'MTN MoMo',
                    isSelected: _selectedPayment == PaymentMethod.mtnMomo,
                    onTap: () => setState(
                        () => _selectedPayment = PaymentMethod.mtnMomo),
                  ),
                  const SizedBox(height: 32),
                  ZeniButton(
                    label: 'Request Ride',
                    onPressed: () async {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please sign in to request a ride')),
                        );
                        return;
                      }

                      try {
                        final rideRequest = {
                          'passenger_id': userId,
                          'pickup_latitude': -26.2041, // TODO: Get from UI
                          'pickup_longitude': 28.0473, // TODO: Get from UI
                          'pickup_address': 'Current Location', // TODO: Get from UI
                          'dropoff_latitude': -26.2100, // TODO: Get from UI
                          'dropoff_longitude': 28.0500, // TODO: Get from UI
                          'dropoff_address': 'Destination Address', // TODO: Get from UI
                          'payment_method': _selectedPayment.name,
                          'status': 'pending',
                        };

                        final response = await Supabase.instance.client
                            .from('ride_requests')
                            .insert(rideRequest)
                            .select()
                            .single();
                        
                        final requestId = response['id'];
                        context.go('/ride-tracking', extra: {'rideId': requestId});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to request ride: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
