import 'package:flutter/material.dart';
import '../error/exceptions.dart';
import '../../features/workout/domain/exceptions/workout_exceptions.dart';
import '../../features/nutrition/domain/exceptions/diet_plan_exceptions.dart';

/// Utility class for handling errors and displaying user-friendly messages.
///
/// Maps domain and data exceptions to human-readable strings and presents
/// them in an [AlertDialog]. Unexpected (non-domain) errors are also logged
/// to the console via [debugPrint] for diagnostics.
class ErrorHandler {
  /// Handles [error] by mapping it to a user-friendly message and showing
  /// an error dialog in the given [context].
  ///
  /// [stack] is optional and used only for console logging of unexpected errors.
  static void handleError(
    BuildContext context,
    Object error,
    StackTrace? stack,
  ) {
    final String message = _mapErrorToMessage(error);
    
    // Log unexpected (non-domain) errors to the console for diagnostics.
    // Domain exceptions (AppException subclasses) are intentional and do not need logging.
    if (error is! AppException &&
        error is! ActiveProgramException &&
        error is! DietPlanException) {
      debugPrint('Unhandled error: $error\n$stack');
    }
    
    _showErrorDialog(context, message);
  }

  /// Display a SnackBar with the given message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Map exceptions to user-friendly messages
  static String _mapErrorToMessage(Object error) {
    // Workout-related exceptions
    if (error is ActiveProgramException) {
      return error.message;
    } else if (error is ProgramValidationException) {
      return error.message;
    }
    // Nutrition-related exceptions
    else if (error is DietPlanException) {
      return error.message;
    }
    // Legacy exceptions
    else if (error is InvalidRepsException) {
      return 'Reps must be a positive integer';
    } else if (error is InvalidWeightException) {
      return 'Weight must be a positive number';
    } else if (error is InvalidRPEException) {
      return 'RPE must be between 1 and 10';
    } else if (error is InvalidMacroException) {
      return 'Macro values must be non-negative';
    } else if (error is EntityNotFoundException) {
      return 'Item not found';
    } else if (error is StorageException) {
      return 'Failed to save data. Please try again.';
    } else if (error is SerializationException) {
      return 'Failed to process data. Please try again.';
    } else {
      return 'An unexpected error occurred';
    }
  }

  /// Display an error dialog with the given message
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
