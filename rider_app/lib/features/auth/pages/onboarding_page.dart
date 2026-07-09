import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_utilities/zeni_utilities.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Create passenger profile in Supabase
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tell us about yourself',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                ZeniTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  validator: (v) => Validators.required(v, 'Name'),
                  prefixIcon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                ZeniTextField(
                  label: 'Email (optional)',
                  hint: 'john@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                const SizedBox(height: 32),
                Text(
                  'Emergency Contact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ZeniTextField(
                  label: 'Contact Name',
                  hint: 'Jane Doe',
                  controller: _emergencyNameController,
                  prefixIcon: const Icon(Icons.contact_emergency),
                ),
                const SizedBox(height: 16),
                ZeniTextField(
                  label: 'Contact Phone',
                  hint: '+27 81 234 5678',
                  controller: _emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 32),
                ZeniButton(
                  label: 'Continue',
                  onPressed: _submitProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
