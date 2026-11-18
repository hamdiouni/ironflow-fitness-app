/// Pure-Dart domain models and orchestration service for Android Health Connect
/// and Apple HealthKit two-way synchronization (Candidate 8.4 — ADR-008).
enum HealthPlatformType {
  androidHealthConnect,
  appleHealthKit,
  simulatedBridge,
}

enum HealthPermissionStatus {
  notDetermined,
  granted,
  denied,
  unavailable,
}

/// Normalized workout session summary exported to Health Connect / HealthKit.
class HealthWorkoutRecord {
  const HealthWorkoutRecord({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.activeEnergyKcal,
    required this.totalVolumeKg,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final double activeEnergyKcal;
  final double totalVolumeKg;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'startTimeMs': startTime.millisecondsSinceEpoch,
        'endTimeMs': endTime.millisecondsSinceEpoch,
        'activeEnergyKcal': activeEnergyKcal,
        'totalVolumeKg': totalVolumeKg,
      };
}

/// Normalized body weight and body fat sample exchanged with Health Connect / HealthKit.
class HealthWeightSample {
  const HealthWeightSample({
    required this.id,
    required this.timestamp,
    required this.weightKg,
    this.bodyFatPercent,
    this.source = 'IronFlow',
  });

  final String id;
  final DateTime timestamp;
  final double weightKg;
  final double? bodyFatPercent;
  final String source;

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestampMs': timestamp.millisecondsSinceEpoch,
        'weightKg': weightKg,
        if (bodyFatPercent != null) 'bodyFatPercent': bodyFatPercent,
        'source': source,
      };

  factory HealthWeightSample.fromMap(Map<Object?, Object?> map) {
    final tsMs = (map['timestampMs'] as num?)?.toInt() ?? 0;
    return HealthWeightSample(
      id: (map['id'] as String?) ?? 'hc_$tsMs',
      timestamp: DateTime.fromMillisecondsSinceEpoch(tsMs),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      bodyFatPercent: (map['bodyFatPercent'] as num?)?.toDouble(),
      source: (map['source'] as String?) ?? 'HealthStore',
    );
  }
}

/// Summary report returned after executing a Health Connect / HealthKit sync cycle.
class HealthSyncReport {
  const HealthSyncReport({
    required this.syncedAt,
    required this.platform,
    required this.permissionStatus,
    required this.workoutsExported,
    required this.weightSamplesExported,
    required this.weightSamplesImported,
    required this.importedSamples,
    required this.message,
  });

  final DateTime syncedAt;
  final HealthPlatformType platform;
  final HealthPermissionStatus permissionStatus;
  final int workoutsExported;
  final int weightSamplesExported;
  final int weightSamplesImported;
  final List<HealthWeightSample> importedSamples;
  final String message;
}

/// Gateway contract implemented by the platform channel adapter.
abstract class HealthPlatformGateway {
  HealthPlatformType get platformType;

  Future<HealthPermissionStatus> checkPermissions();

  Future<HealthPermissionStatus> requestPermissions({
    required bool readWeight,
    required bool writeWeight,
    required bool writeWorkouts,
  });

  Future<List<HealthWeightSample>> readWeightSamples({
    required DateTime since,
  });

  Future<int> writeWeightSamples(List<HealthWeightSample> samples);

  Future<int> writeWorkouts(List<HealthWorkoutRecord> workouts);
}

/// Domain service that orchestrates opt-in workout export and two-way body weight
/// synchronization with deduplication and active energy estimation.
class HealthSyncService {
  const HealthSyncService({
    required this.gateway,
    this.clock,
  });

  final HealthPlatformGateway gateway;
  final DateTime Function()? clock;

  DateTime _now() => clock != null ? clock!() : DateTime.now();

  /// Estimates active kilocalories burned during a resistance training session
  /// using standard Compendium of Physical Activities METs (5.0 base METs plus
  /// volume density factor).
  static double estimateWorkoutActiveCalories({
    required int durationMinutes,
    required double totalVolumeKg,
    double bodyWeightKg = 75.0,
  }) {
    final safeMinutes = durationMinutes.clamp(1, 300);
    final safeBodyWeight = bodyWeightKg.clamp(35.0, 250.0);
    final safeVolume = totalVolumeKg.clamp(0.0, 100000.0);
    final hours = safeMinutes / 60.0;
    final baseKcal = 5.0 * safeBodyWeight * hours;
    final volumeBonus = (safeVolume / 1000.0) * 8.5;
    return double.parse((baseKcal + volumeBonus).toStringAsFixed(1));
  }

  /// Deduplicates incoming remote weight samples against existing local samples
  /// within a [toleranceMinutes] window or matching ID.
  static List<HealthWeightSample> filterNewRemoteWeightSamples({
    required List<HealthWeightSample> remoteSamples,
    required List<HealthWeightSample> localSamples,
    int toleranceMinutes = 5,
  }) {
    final result = <HealthWeightSample>[];
    final windowMs = toleranceMinutes * 60 * 1000;

    for (final remote in remoteSamples) {
      if (remote.weightKg <= 0 || remote.weightKg > 500) continue;
      final alreadyExists = localSamples.any((local) {
        if (local.id == remote.id) return true;
        final diff = (local.timestamp.millisecondsSinceEpoch -
                remote.timestamp.millisecondsSinceEpoch)
            .abs();
        return diff <= windowMs &&
            (local.weightKg - remote.weightKg).abs() < 0.05;
      });
      if (!alreadyExists) {
        result.add(remote);
      }
    }
    return result;
  }

  /// Executes an opt-in synchronization cycle with the underlying health store.
  Future<HealthSyncReport> syncNow({
    required bool exportWorkouts,
    required bool twoWayWeightSync,
    List<HealthWorkoutRecord> localWorkouts = const [],
    List<HealthWeightSample> localWeights = const [],
    DateTime? since,
  }) async {
    final now = _now();
    if (!exportWorkouts && !twoWayWeightSync) {
      return HealthSyncReport(
        syncedAt: now,
        platform: gateway.platformType,
        permissionStatus: await gateway.checkPermissions(),
        workoutsExported: 0,
        weightSamplesExported: 0,
        weightSamplesImported: 0,
        importedSamples: const [],
        message: 'Enable at least one sync direction to synchronize health data.',
      );
    }

    var perm = await gateway.checkPermissions();
    if (perm != HealthPermissionStatus.granted) {
      perm = await gateway.requestPermissions(
        readWeight: twoWayWeightSync,
        writeWeight: twoWayWeightSync,
        writeWorkouts: exportWorkouts,
      );
    }

    if (perm != HealthPermissionStatus.granted) {
      return HealthSyncReport(
        syncedAt: now,
        platform: gateway.platformType,
        permissionStatus: perm,
        workoutsExported: 0,
        weightSamplesExported: 0,
        weightSamplesImported: 0,
        importedSamples: const [],
        message: 'Health store permission was not granted.',
      );
    }

    int workoutsWritten = 0;
    if (exportWorkouts && localWorkouts.isNotEmpty) {
      workoutsWritten = await gateway.writeWorkouts(localWorkouts);
    }

    int weightsWritten = 0;
    var newlyImported = const <HealthWeightSample>[];
    if (twoWayWeightSync) {
      final remote = await gateway.readWeightSamples(
        since: since ?? now.subtract(const Duration(days: 30)),
      );
      newlyImported = filterNewRemoteWeightSamples(
        remoteSamples: remote,
        localSamples: localWeights,
      );
      if (localWeights.isNotEmpty) {
        weightsWritten = await gateway.writeWeightSamples(localWeights);
      }
    }

    return HealthSyncReport(
      syncedAt: now,
      platform: gateway.platformType,
      permissionStatus: perm,
      workoutsExported: workoutsWritten,
      weightSamplesExported: weightsWritten,
      weightSamplesImported: newlyImported.length,
      importedSamples: newlyImported,
      message:
          'Synced $workoutsWritten workouts, exported $weightsWritten weights, imported ${newlyImported.length} new weight records.',
    );
  }
}
