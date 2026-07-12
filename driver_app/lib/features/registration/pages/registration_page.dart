import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_widgets/zeni_widgets.dart';
import 'package:zeni_utilities/zeni_utilities.dart';
import 'package:zeni_services/zeni_services.dart';
import 'package:zeni_models/zeni_models.dart';

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
  VehicleType? _selectedVehicleType = VehicleType.standard;
  final ImagePicker _picker = ImagePicker();
  File? _licenseImage;
  bool _isSubmitting = false;

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

  Future<String?> _uploadFile(
    File file,
    String bucket,
    String folder,
    String filename,
  ) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$filename';
      final storagePath = '$folder/$fileName';
      await Supabase.instance.client.storage.from(bucket).upload(storagePath, file);
      return Supabase.instance.client.storage.from(bucket).getPublicUrl(storagePath);
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

      if (_selectedVehicleType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle type.')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please sign in again.')),
          );
          return;
        }

        // 1. Upload license image to driver_documents bucket
        final licenseUrl = await _uploadFile(
          _licenseImage!,
          'driver_documents',
          userId,
          'license',
        );

        if (licenseUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload license photo. Please try again.')),
          );
          return;
        }

        // 2. Submit registration through BLoC
        if (mounted) {
          // For now, directly call the database API since registration_bloc is being tested
          await Supabase.instance.client.from('profiles').update({
            'full_name': _nameController.text.trim(),
            if (_emailController.text.trim().isNotEmpty)
              'email': _emailController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', userId);

          await Supabase.instance.client.from('drivers').upsert({
            'id': userId,
            'license_number': _licenseController.text.trim(),
            'license_image_url': licenseUrl,
            'is_verified': false,
            'status': DriverStatus.pendingApproval.name,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');

          await Supabase.instance.client.from('vehicles').insert({
            'driver_id': userId,
            'make': _vehicleMakeController.text.trim(),
            'model': _vehicleModelController.text.trim(),
            'year': int.parse(_vehicleYearController.text.trim()),
            'plate_number': _licensePlateController.text.trim(),
            'vehicle_type': _selectedVehicleType!.name,
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration submitted! Awaiting approval.'),
            ),
          );
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
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
                      label: 'Email (optional)',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? Validators.email(v) : null,
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
                    DropdownButtonFormField<VehicleType>(
                      value: _selectedVehicleType,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: VehicleType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.name[0].toUpperCase() +
                                      type.name.substring(1),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedVehicleType = value),
                      validator: (v) => v == null
                          ? 'Please select a vehicle type'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ZeniButton(
                      label: 'Upload Vehicle Photo',
                      onPressed: () {
                        // TODO: Implement vehicle photo upload to vehicle_photos bucket
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
