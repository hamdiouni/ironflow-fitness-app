// Example usage of ErrorHandler in a Flutter widget
// This file demonstrates how to use the ErrorHandler utility

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_handler.dart';

/// Example widget showing how to use ErrorHandler
class ErrorHandlerExample extends ConsumerWidget {
  const ErrorHandlerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handler Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Perform async operation that might throw an exception
              // Example: await ref.read(workoutNotifierProvider.notifier).start();
              
              // Or any other operation that might fail
              // await someRepository.saveData();
            } catch (e, stack) {
              // Use ErrorHandler to display user-friendly error message
              ErrorHandler.handleError(context, e, stack);
            }
          },
          child: const Text('Perform Action'),
        ),
      ),
    );
  }
}

/// Example of wrapping multiple operations with error handling
class MultipleOperationsExample extends ConsumerWidget {
  const MultipleOperationsExample({super.key});

  Future<void> _performOperations(BuildContext context, WidgetRef ref) async {
    try {
      // Operation 1
      // await ref.read(workoutNotifierProvider.notifier).start();
      
      // Operation 2
      // await ref.read(bodyRepositoryProvider).saveBodyEntry(entry);
      
      // Operation 3
      // await ref.read(nutritionRepositoryProvider).saveMeal(meal);
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operations completed successfully')),
        );
      }
    } catch (e, stack) {
      // All errors are handled in one place
      if (context.mounted) {
        ErrorHandler.handleError(context, e, stack);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => _performOperations(context, ref),
        child: const Text('Perform Multiple Operations'),
      ),
    );
  }
}
