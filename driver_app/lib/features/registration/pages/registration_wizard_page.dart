import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/registration_bloc.dart';

class RegistrationWizardPage extends StatelessWidget {
  const RegistrationWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationBloc(),
      child: const RegistrationWizardView(),
    );
  }
}

class RegistrationWizardView extends StatelessWidget {
  const RegistrationWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final currentStep = state is RegistrationInProgress ? state.currentStep : 0;
        
        return Scaffold(
          appBar: AppBar(title: Text('Driver Registration - Step ${currentStep + 1}')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: _buildStepContent(currentStep),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentStep > 0)
                      ElevatedButton(
                        onPressed: () => context.read<RegistrationBloc>().add(StepChanged(currentStep - 1)),
                        child: const Text('Back'),
                      ),
                    ElevatedButton(
                      onPressed: () => context.read<RegistrationBloc>().add(StepChanged(currentStep + 1)),
                      child: Text(currentStep < 2 ? 'Next' : 'Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const Center(child: Text('Step 1: Vehicle Details'));
      case 1:
        return const Center(child: Text('Step 2: Upload Documents'));
      case 2:
        return const Center(child: Text('Step 3: Review & Submit'));
      default:
        return const Center(child: Text('Unknown Step'));
    }
  }
}
