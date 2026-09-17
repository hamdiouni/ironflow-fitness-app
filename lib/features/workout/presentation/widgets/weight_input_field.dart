import 'package:flutter/material.dart';

/// A reusable weight input field widget with validation for 0-500kg range.
///
/// Features:
/// - Validates weight range 0-500kg
/// - Supports decimal values (e.g., 22.5kg)
/// - Shows inline error messages
/// - Real-time validation feedback
/// - Prevents saving invalid values
/// - Customizable validator function
///
/// Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 16.1, 16.7, 16.8
class WeightInputField extends StatefulWidget {
  /// Initial weight value to display
  final double? initialValue;

  /// Callback when weight changes and is valid
  final Function(double) onChanged;

  /// Optional custom validator function
  final String? Function(String?)? validator;

  /// Label text for the field
  final String label;

  /// Hint text for the field
  final String? hint;

  /// Whether the field is required
  final bool isRequired;

  const WeightInputField({
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.label = 'Weight (kg)',
    this.hint = '0-500',
    this.isRequired = true,
    super.key,
  });

  @override
  State<WeightInputField> createState() => _WeightInputFieldState();
}

class _WeightInputFieldState extends State<WeightInputField> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateWeight(String? value) {
    // Check if required and empty
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'Weight is required';
    }

    // Allow empty if not required
    if (value == null || value.isEmpty) {
      return null;
    }

    // Try to parse as double
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    // Check range 0-500kg
    if (weight < 0 || weight > 500) {
      return 'Weight must be between 0 and 500kg';
    }

    // Call custom validator if provided
    return widget.validator?.call(value);
  }

  void _handleChanged(String value) {
    final error = _validateWeight(value);

    setState(() {
      _errorMessage = error;
    });

    // Only call onChanged if valid
    if (error == null && value.isNotEmpty) {
      final weight = double.tryParse(value);
      if (weight != null) {
        widget.onChanged(weight);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: _errorMessage,
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: _errorMessage != null
            ? const Icon(Icons.error_outline, color: Colors.red)
            : null,
      ),
      validator: _validateWeight,
      onChanged: _handleChanged,
    );
  }
}
