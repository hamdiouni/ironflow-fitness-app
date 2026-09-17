import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Units system enum.
enum UnitsSystem {
  metric,   // kg, cm, g
  imperial, // lbs, in, oz
}

/// Provider for managing app units system (metric/imperial).
///
/// Persists units preference to Hive storage.
/// **Validates: Requirements 10.2 (Units System)**
final unitsProvider = StateNotifierProvider<UnitsNotifier, UnitsSystem>((ref) {
  return UnitsNotifier();
});

/// Notifier for managing units system state.
class UnitsNotifier extends StateNotifier<UnitsSystem> {
  static const String _boxName = 'app_settings';
  static const String _unitsKey = 'units_system';

  UnitsNotifier() : super(UnitsSystem.metric) {
    _loadUnits();
  }

  /// Loads units preference from Hive storage.
  Future<void> _loadUnits() async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      final unitsStr = box.get(_unitsKey, defaultValue: 'metric');
      
      final units = unitsStr == 'imperial' ? UnitsSystem.imperial : UnitsSystem.metric;
      state = units;
    } catch (e) {
      print('Error loading units: $e');
      state = UnitsSystem.metric;
    }
  }

  /// Sets the units system.
  Future<void> setUnits(UnitsSystem units) async {
    state = units;
    
    try {
      final box = await Hive.openBox<String>(_boxName);
      final unitsStr = units == UnitsSystem.imperial ? 'imperial' : 'metric';
      await box.put(_unitsKey, unitsStr);
    } catch (e) {
      print('Error saving units: $e');
    }
  }

  /// Toggles between metric and imperial.
  Future<void> toggleUnits() async {
    final newUnits = state == UnitsSystem.metric ? UnitsSystem.imperial : UnitsSystem.metric;
    await setUnits(newUnits);
  }

  /// Gets the display name for the current units system.
  String get currentUnitsName {
    return state == UnitsSystem.metric ? 'Metric (kg, cm, g)' : 'Imperial (lbs, in, oz)';
  }
}

/// Provider for getting the current units system.
final currentUnitsProvider = Provider<UnitsSystem>((ref) {
  return ref.watch(unitsProvider);
});

/// Utility class for unit conversions.
///
/// Provides methods to convert between metric and imperial units.
class UnitsConverter {
  // Weight conversions
  static const double kgToLbs = 2.20462;
  static const double lbsToKg = 0.453592;
  
  // Length conversions
  static const double cmToIn = 0.393701;
  static const double inToCm = 2.54;
  
  // Mass conversions (food)
  static const double gToOz = 0.035274;
  static const double ozToG = 28.3495;

  /// Convert weight from kg to lbs.
  static double kgToLbsConvert(double kg) {
    return kg * kgToLbs;
  }

  /// Convert weight from lbs to kg.
  static double lbsToKgConvert(double lbs) {
    return lbs * lbsToKg;
  }

  /// Convert length from cm to inches.
  static double cmToInConvert(double cm) {
    return cm * cmToIn;
  }

  /// Convert length from inches to cm.
  static double inToCmConvert(double inches) {
    return inches * inToCm;
  }

  /// Convert mass from grams to ounces.
  static double gToOzConvert(double grams) {
    return grams * gToOz;
  }

  /// Convert mass from ounces to grams.
  static double ozToGConvert(double ounces) {
    return ounces * ozToG;
  }

  /// Format weight value with appropriate unit.
  static String formatWeight(double value, UnitsSystem units, {int decimals = 1}) {
    if (units == UnitsSystem.imperial) {
      final lbs = kgToLbsConvert(value);
      return '${lbs.toStringAsFixed(decimals)} lbs';
    } else {
      return '${value.toStringAsFixed(decimals)} kg';
    }
  }

  /// Format length value with appropriate unit.
  static String formatLength(double value, UnitsSystem units, {int decimals = 1}) {
    if (units == UnitsSystem.imperial) {
      final inches = cmToInConvert(value);
      return '${inches.toStringAsFixed(decimals)} in';
    } else {
      return '${value.toStringAsFixed(decimals)} cm';
    }
  }

  /// Format mass value with appropriate unit (for food).
  static String formatMass(double value, UnitsSystem units, {int decimals = 1}) {
    if (units == UnitsSystem.imperial) {
      final oz = gToOzConvert(value);
      return '${oz.toStringAsFixed(decimals)} oz';
    } else {
      return '${value.toStringAsFixed(decimals)} g';
    }
  }

  /// Get weight unit label.
  static String getWeightUnit(UnitsSystem units) {
    return units == UnitsSystem.imperial ? 'lbs' : 'kg';
  }

  /// Get length unit label.
  static String getLengthUnit(UnitsSystem units) {
    return units == UnitsSystem.imperial ? 'in' : 'cm';
  }

  /// Get mass unit label (for food).
  static String getMassUnit(UnitsSystem units) {
    return units == UnitsSystem.imperial ? 'oz' : 'g';
  }

  /// Convert weight value to display value based on units.
  static double convertWeightToDisplay(double kgValue, UnitsSystem units) {
    return units == UnitsSystem.imperial ? kgToLbsConvert(kgValue) : kgValue;
  }

  /// Convert weight value from display value to kg (storage format).
  static double convertWeightToStorage(double displayValue, UnitsSystem units) {
    return units == UnitsSystem.imperial ? lbsToKgConvert(displayValue) : displayValue;
  }

  /// Convert length value to display value based on units.
  static double convertLengthToDisplay(double cmValue, UnitsSystem units) {
    return units == UnitsSystem.imperial ? cmToInConvert(cmValue) : cmValue;
  }

  /// Convert length value from display value to cm (storage format).
  static double convertLengthToStorage(double displayValue, UnitsSystem units) {
    return units == UnitsSystem.imperial ? inToCmConvert(displayValue) : displayValue;
  }

  /// Convert mass value to display value based on units.
  static double convertMassToDisplay(double gValue, UnitsSystem units) {
    return units == UnitsSystem.imperial ? gToOzConvert(gValue) : gValue;
  }

  /// Convert mass value from display value to grams (storage format).
  static double convertMassToStorage(double displayValue, UnitsSystem units) {
    return units == UnitsSystem.imperial ? ozToGConvert(displayValue) : displayValue;
  }
}
