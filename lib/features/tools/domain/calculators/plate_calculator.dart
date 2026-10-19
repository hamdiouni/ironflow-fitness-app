/// Pure domain logic for barbell plate loading calculations.
enum PlateUnit {
  kg,
  lb;

  String get symbol => name;
}

class PlateCount {
  final double weight;
  final int count;

  const PlateCount({required this.weight, required this.count});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlateCount &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          count == other.count;

  @override
  int get hashCode => weight.hashCode ^ count.hashCode;

  @override
  String toString() => '${weight.toStringAsFixed(1)}${count > 1 ? " × $count" : ""}';
}

class PlateCalculationResult {
  final double targetWeight;
  final double barWeight;
  final PlateUnit unit;
  final double weightPerSide;
  final List<PlateCount> platesPerSide;
  final double totalLoadedWeight;
  final double remainder;

  const PlateCalculationResult({
    required this.targetWeight,
    required this.barWeight,
    required this.unit,
    required this.weightPerSide,
    required this.platesPerSide,
    required this.totalLoadedWeight,
    required this.remainder,
  });

  bool get isExactMatch => remainder.abs() < 0.001;

  /// Flat list of individual plates on one side, sorted heaviest to lightest.
  List<double> get flatPlatesList {
    final list = <double>[];
    for (final p in platesPerSide) {
      for (int i = 0; i < p.count; i++) {
        list.add(p.weight);
      }
    }
    return list;
  }

  /// Plain English summary of how to load the bar.
  String get plainEnglishSummary {
    if (targetWeight <= barWeight) {
      return 'Empty bar (${barWeight.toStringAsFixed(1)} ${unit.symbol}). No plates needed.';
    }

    if (platesPerSide.isEmpty) {
      return 'Weight is less than one pair of smallest plates. Load empty bar.';
    }

    final platesStr = platesPerSide
        .map((p) => '${p.count}× ${p.weight.toStringAsFixed(1)} ${unit.symbol}')
        .join(', ');

    final base = 'Each side: $platesStr.';
    if (isExactMatch) {
      return '$base Total: ${totalLoadedWeight.toStringAsFixed(1)} ${unit.symbol}.';
    } else {
      return '$base Total: ${totalLoadedWeight.toStringAsFixed(1)} ${unit.symbol} (${remainder.toStringAsFixed(1)} ${unit.symbol} under target).';
    }
  }
}

class PlateCalculator {
  static const List<double> defaultKgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
  static const List<double> defaultLbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

  static const double defaultBarWeightKg = 20.0;
  static const double defaultBarWeightLb = 45.0;

  /// Calculates plates needed per side using standard greedy algorithm.
  static PlateCalculationResult calculate({
    required double targetWeight,
    double? barWeight,
    PlateUnit unit = PlateUnit.kg,
    List<double>? availablePlates,
  }) {
    final actualBarWeight = barWeight ??
        (unit == PlateUnit.kg ? defaultBarWeightKg : defaultBarWeightLb);

    final plates = (availablePlates ??
            (unit == PlateUnit.kg ? defaultKgPlates : defaultLbPlates))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order

    if (targetWeight <= actualBarWeight) {
      return PlateCalculationResult(
        targetWeight: targetWeight,
        barWeight: actualBarWeight,
        unit: unit,
        weightPerSide: 0.0,
        platesPerSide: const [],
        totalLoadedWeight: actualBarWeight,
        remainder: 0.0,
      );
    }

    double weightNeededPerSide = (targetWeight - actualBarWeight) / 2.0;
    final List<PlateCount> result = [];
    double loadedPerSide = 0.0;

    for (final plate in plates) {
      if (plate <= 0) continue;
      if (weightNeededPerSide >= plate) {
        final count = (weightNeededPerSide / plate).floor();
        if (count > 0) {
          result.add(PlateCount(weight: plate, count: count));
          final added = count * plate;
          loadedPerSide += added;
          weightNeededPerSide -= added;
          // Avoid floating point inaccuracies
          weightNeededPerSide = (weightNeededPerSide * 1000).round() / 1000;
        }
      }
    }

    final totalLoaded = actualBarWeight + (loadedPerSide * 2.0);
    final remainder = (targetWeight - totalLoaded);

    return PlateCalculationResult(
      targetWeight: targetWeight,
      barWeight: actualBarWeight,
      unit: unit,
      weightPerSide: loadedPerSide,
      platesPerSide: result,
      totalLoadedWeight: totalLoaded,
      remainder: (remainder * 1000).round() / 1000,
    );
  }
}
