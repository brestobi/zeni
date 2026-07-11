import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session expired. Please sign in again.')),
            );
          }
          return;
        }
        await Supabase.instance.client.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        }).eq('id', userId);

        // Also ensure passenger record exists
        await Supabase.instance.client.from('passengers').upsert({
          'id': userId,
        });

        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
                  validator: (v) => v != null && v.isNotEmpty ? Validators.email(v) : null,
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
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
