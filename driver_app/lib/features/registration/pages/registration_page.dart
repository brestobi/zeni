import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_utilities/zeni_utilities.dart';
import 'package:zeni_services/zeni_services.dart';

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
  final ImagePicker _picker = ImagePicker();
  File? _licenseImage;

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

  Future<void> _pickImage(Function(File) onPicked) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onPicked(File(image.path));
    }
  }

  Future<String?> _uploadFile(File file, String bucket, String path) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$path/$fileName';
      await Supabase.instance.client.storage
          .from(bucket)
          .upload(storagePath, file);
      return Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_licenseImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your license photo.')),
        );
        return;
      }

      setState(() {}); // Show loading state

      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please sign in again.')),
          );
          return;
        }

        // 1. Upload license image
        final licenseUrl = await _uploadFile(_licenseImage!, 'driver_documents', userId);

        // 2. Insert/Update Driver record
        await Supabase.instance.client.from('drivers').upsert({
          'id': userId,
          'license_number': _licenseController.text.trim(),
          'license_image_url': licenseUrl,
          'status': 'pending_approval',
        });

        // 3. Insert Vehicle record
        await Supabase.instance.client.from('vehicles').insert({
          'driver_id': userId,
          'make': _vehicleMakeController.text.trim(),
          'model': _vehicleModelController.text.trim(),
          'year': int.parse(_vehicleYearController.text.trim()),
          'plate_number': _licensePlateController.text.trim(),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration submitted! Awaiting approval.'),
          ),
        );
        context.go('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
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
                      label: _licenseImage == null ? 'Upload License Photo' : 'License Photo Selected',
                      onPressed: () => _pickImage((file) => setState(() => _licenseImage = file)),
                      isOutlined: true,
                      icon: Icons.camera_alt,
                    ),
                    const SizedBox(height: 12),
                    ZeniButton(
                      label: 'Upload Vehicle Registration',
                      onPressed: () {
                        // TODO: Implement registration document upload
                      },
                      isOutlined: true,
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 12),
                    ZeniButton(
                      label: 'Upload Insurance',
                      onPressed: () {
                        // TODO: Implement insurance document upload
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
                        // TODO: Implement vehicle photo upload
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
