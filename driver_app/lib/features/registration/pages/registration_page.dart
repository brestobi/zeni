import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_utilities/zeni_utilities.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Upload to Supabase, set driver status to pending_approval
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted! Awaiting approval.'),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Registration')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _submit();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            steps: [
              Step(
                title: const Text('Personal Info'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  children: [
                    ZeniTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      validator: (v) => Validators.required(v, 'Name'),
                    ),
                    const SizedBox(height: 16),
                    ZeniTextField(
                      label: 'Email',
                      controller: _emailController,
                      validator: Validators.email,
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('License & Documents'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ZeniTextField(
                      label: "Driver's License Number",
                      controller: _licenseController,
                      validator: (v) =>
                          Validators.required(v, 'License number'),
                    ),
                    const SizedBox(height: 16),
                    ZeniButton(
                      label: 'Upload License Photo',
                      onPressed: () {
                        // TODO: Use image_picker to capture license
                      },
                      isOutlined: true,
                      icon: Icons.camera_alt,
                    ),
                    const SizedBox(height: 12),
                    ZeniButton(
                      label: 'Upload Vehicle Registration',
                      onPressed: () {
                        // TODO: Use image_picker
                      },
                      isOutlined: true,
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 12),
                    ZeniButton(
                      label: 'Upload Insurance',
                      onPressed: () {
                        // TODO: Use image_picker
                      },
                      isOutlined: true,
                      icon: Icons.verified_user,
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Vehicle Details'),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    ZeniTextField(
                      label: 'Make',
                      hint: 'Toyota',
                      controller: _vehicleMakeController,
                      validator: (v) => Validators.required(v, 'Make'),
                    ),
                    const SizedBox(height: 16),
                    ZeniTextField(
                      label: 'Model',
                      hint: 'Corolla',
                      controller: _vehicleModelController,
                      validator: (v) => Validators.required(v, 'Model'),
                    ),
                    const SizedBox(height: 16),
                    ZeniTextField(
                      label: 'Year',
                      hint: '2022',
                      controller: _vehicleYearController,
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.required(v, 'Year'),
                    ),
                    const SizedBox(height: 16),
                    ZeniTextField(
                      label: 'License Plate',
                      hint: 'ABC 123 GP',
                      controller: _licensePlateController,
                      validator: (v) =>
                          Validators.required(v, 'License plate'),
                    ),
                    const SizedBox(height: 16),
                    ZeniButton(
                      label: 'Upload Vehicle Photo',
                      onPressed: () {
                        // TODO: Use image_picker
                      },
                      isOutlined: true,
                      icon: Icons.camera_alt,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
