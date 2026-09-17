/// Utility class for input validation across the app.
class InputValidators {
  // ── Weight validation ───────────────────────────────────────────────────────
  /// Validates weight input (0-500kg).
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }

    if (weight > 500) {
      return 'Weight cannot exceed 500 kg';
    }

    return null;
  }

  // ── Sets validation ─────────────────────────────────────────────────────────
  /// Validates sets input (positive integer).
  static String? validateSets(String? value) {
    if (value == null || value.isEmpty) {
      return 'Sets is required';
    }

    final sets = int.tryParse(value);
    if (sets == null) {
      return 'Please enter a valid number';
    }

    if (sets <= 0) {
      return 'Sets must be at least 1';
    }

    if (sets > 100) {
      return 'Sets cannot exceed 100';
    }

    return null;
  }

  // ── Reps validation ─────────────────────────────────────────────────────────
  /// Validates reps input (positive integer or "X-Y" range).
  static String? validateReps(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reps is required';
    }

    // Check if it's a range (e.g., "8-12")
    if (value.contains('-')) {
      final parts = value.split('-');
      if (parts.length != 2) {
        return 'Invalid range format. Use "X-Y"';
      }

      final min = int.tryParse(parts[0].trim());
      final max = int.tryParse(parts[1].trim());

      if (min == null || max == null) {
        return 'Please enter valid numbers';
      }

      if (min <= 0 || max <= 0) {
        return 'Reps must be greater than 0';
      }

      if (min > max) {
        return 'Minimum reps cannot be greater than maximum';
      }

      if (max > 100) {
        return 'Reps cannot exceed 100';
      }

      return null;
    }

    // Single number
    final reps = int.tryParse(value);
    if (reps == null) {
      return 'Please enter a valid number';
    }

    if (reps <= 0) {
      return 'Reps must be at least 1';
    }

    if (reps > 100) {
      return 'Reps cannot exceed 100';
    }

    return null;
  }

  // ── Rest seconds validation ─────────────────────────────────────────────────
  /// Validates rest seconds input (non-negative integer).
  static String? validateRestSeconds(String? value) {
    if (value == null || value.isEmpty) {
      return 'Rest time is required';
    }

    final seconds = int.tryParse(value);
    if (seconds == null) {
      return 'Please enter a valid number';
    }

    if (seconds < 0) {
      return 'Rest time cannot be negative';
    }

    if (seconds > 600) {
      return 'Rest time cannot exceed 10 minutes';
    }

    return null;
  }

  // ── Calories validation ─────────────────────────────────────────────────────
  /// Validates calories input (positive number).
  static String? validateCalories(String? value) {
    if (value == null || value.isEmpty) {
      return 'Calories is required';
    }

    final calories = double.tryParse(value);
    if (calories == null) {
      return 'Please enter a valid number';
    }

    if (calories <= 0) {
      return 'Calories must be greater than 0';
    }

    if (calories > 10000) {
      return 'Calories cannot exceed 10,000';
    }

    return null;
  }

  // ── Macros validation ───────────────────────────────────────────────────────
  /// Validates macro input (positive number).
  static String? validateMacro(String? value, String macroName) {
    if (value == null || value.isEmpty) {
      return '$macroName is required';
    }

    final macro = double.tryParse(value);
    if (macro == null) {
      return 'Please enter a valid number';
    }

    if (macro < 0) {
      return '$macroName cannot be negative';
    }

    if (macro > 500) {
      return '$macroName cannot exceed 500g';
    }

    return null;
  }

  // ── Email validation ────────────────────────────────────────────────────────
  /// Validates email format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // ── Name validation ─────────────────────────────────────────────────────────
  /// Validates name input.
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    return null;
  }

  // ── Age validation ──────────────────────────────────────────────────────────
  /// Validates age input.
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age < 13) {
      return 'You must be at least 13 years old';
    }

    if (age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  // ── Height validation ───────────────────────────────────────────────────────
  /// Validates height input (cm).
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }

    if (height < 100) {
      return 'Height must be at least 100 cm';
    }

    if (height > 250) {
      return 'Height cannot exceed 250 cm';
    }

    return null;
  }

  // ── Body weight validation ──────────────────────────────────────────────────
  /// Validates body weight input (kg).
  static String? validateBodyWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Body weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight < 30) {
      return 'Body weight must be at least 30 kg';
    }

    if (weight > 300) {
      return 'Body weight cannot exceed 300 kg';
    }

    return null;
  }
}
