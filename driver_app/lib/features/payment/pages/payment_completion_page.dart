import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/payment_bloc.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_models/zeni_models.dart';

class PaymentCompletionPage extends StatelessWidget {
  final String rideId;
  final PaymentMethod paymentMethod;

  const PaymentCompletionPage({
    super.key,
    required this.rideId,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(supabase: Supabase.instance.client),
      child: Scaffold(
        appBar: AppBar(title: const Text('Complete Payment')),
        body: Center(
          child: BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state is PaymentProcessing) {
                return const CircularProgressIndicator();
              }
              if (state is PaymentSuccess) {
                return const Text('Payment Successful');
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Method: ${paymentMethod.name}'),
                  const SizedBox(height: 20),
                  if (paymentMethod == PaymentMethod.cash)
                    ZeniButton(
                      label: 'Confirm Cash Received',
                      onPressed: () => context.read<PaymentBloc>().add(
                            ConfirmCashPayment(rideId),
                          ),
                    ),
                  if (paymentMethod == PaymentMethod.yocoCard)
                    const Text('Yoco Integration Pending'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
