import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/active_program_providers.dart';
import '../providers/workout_providers.dart';

/// Screen for selecting a workout program split type.
///
/// Displays three split type options: Full Body, Upper-Lower, and Push-Pull-Legs.
/// Users can select a split to generate a new program.
/// 
/// **Validates: Requirements 2.1, 2.2, 13.3, 13.4**
class ProgramSelectionScreen extends ConsumerWidget {
  const ProgramSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Program'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose Your Training Split'),
            const SizedBox(height: 32),
            _SplitOption(
              title: 'Full Body',
              description: '3 days per week',
              onPressed: () => _selectSplit(context, ref, 'full_body'),
            ),
            const SizedBox(height: 16),
            _SplitOption(
              title: 'Upper-Lower',
              description: '4 days per week',
              onPressed: () => _selectSplit(context, ref, 'upper_lower'),
            ),
            const SizedBox(height: 16),
            _SplitOption(
              title: 'Push-Pull-Legs',
              description: '6 days per week',
              onPressed: () => _selectSplit(context, ref, 'push_pull_legs'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectSplit(BuildContext context, WidgetRef ref, String splitType) async {
    try {
      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your program...'),
              ],
            ),
          ),
        );
      }
      
      // Get user profile from onboarding provider
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;
      
      if (userProfile == null) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User profile not found')),
          );
        }
        return;
      }
      
      // Generate program with selected split
      final generateUseCase = ref.read(generateWorkoutProgramUseCaseProvider);
      final program = await generateUseCase(
        userProfile: userProfile,
        splitType: splitType,
      );
      
      // Set as active program
      await ref.read(activeProgramProvider.notifier).setActiveProgram(program);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        context.go(AppRoutes.workout); // Navigate back to workout screen
      }
    } catch (e, s) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ErrorHandler.handleError(context, e, s);
      }
    }
  }
}

class _SplitOption extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;
  
  const _SplitOption({
    required this.title,
    required this.description,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 24),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
