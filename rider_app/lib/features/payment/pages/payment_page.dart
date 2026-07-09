import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Cash'),
              subtitle: const Text('Pay with cash'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Add Card'),
              subtitle: const Text('Pay with Yoco'),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () {
                // TODO: Integrate Yoco card payment
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('MTN Mobile Money'),
              subtitle: const Text('Pay with MoMo'),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () {
                // TODO: Link MTN MoMo account
              },
            ),
          ),
        ],
      ),
    );
  }
}
