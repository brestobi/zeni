import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_utilities/zeni_utilities.dart';
import '../bloc/auth_bloc.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitPhoneNumber() {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<AuthBloc>()
          .add(PhoneNumberSubmitted(_phoneController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.go('/otp-verify', extra: {
            'phoneNumber': state.phoneNumber,
          });
        } else if (state is AuthAuthenticated) {
          if (state.driver != null) {
            context.go('/home');
          } else {
            context.go('/registration');
          }
        } else if (state is AuthNewUser) {
          context.go('/registration');
        } else if (state is AuthRegistrationPending) {
          // Show pending approval screen
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Icon(
                    Icons.directions_car_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Zeni Driver',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your phone number to sign in',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 48),
                  ZeniTextField(
                    label: 'Phone Number',
                    hint: '+27 81 234 5678',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => Validators.phone(v),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ZeniButton(
                        label: 'Send OTP',
                        onPressed: _submitPhoneNumber,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
