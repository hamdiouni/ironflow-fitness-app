import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../body/data/services/method_channel_health_gateway.dart';
import '../../../body/domain/services/health_sync_service.dart';

/// Opens the Health Connect (Android) & Apple HealthKit (iOS) two-way sync configuration sheet.
Future<void> showHealthSyncSettingsSheet(
  BuildContext context, {
  HealthSyncService? service,
}) {
  final tokens = AppThemeTokens.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: tokens.canvas,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
    ),
    builder: (_) => HealthSyncSettingsSheet(
      service: service ??
          HealthSyncService(
            gateway: MethodChannelHealthGateway(),
          ),
    ),
  );
}

class HealthSyncSettingsSheet extends StatefulWidget {
  const HealthSyncSettingsSheet({
    super.key,
    required this.service,
  });

  final HealthSyncService service;

  @override
  State<HealthSyncSettingsSheet> createState() =>
      _HealthSyncSettingsSheetState();
}

class _HealthSyncSettingsSheetState extends State<HealthSyncSettingsSheet> {
  bool _exportWorkouts = true;
  bool _twoWayWeightSync = true;
  bool _isSyncing = false;
  HealthSyncReport? _lastReport;

  String _platformLabel(HealthPlatformType type) {
    switch (type) {
      case HealthPlatformType.androidHealthConnect:
        return 'ANDROID HEALTH CONNECT';
      case HealthPlatformType.appleHealthKit:
        return 'APPLE HEALTHKIT';
      case HealthPlatformType.simulatedBridge:
        return 'HEALTH BRIDGE (CROSS-PLATFORM)';
    }
  }

  Future<void> _handleSyncNow() async {
    AppHaptics.shared.buttonPress();
    setState(() {
      _isSyncing = true;
    });

    final now = DateTime.now();
    final sampleWorkout = HealthWorkoutRecord(
      id: 'wf_sync_${now.millisecondsSinceEpoch}',
      title: 'IronFlow Hypertrophy Session',
      startTime: now.subtract(const Duration(minutes: 55)),
      endTime: now,
      activeEnergyKcal: HealthSyncService.estimateWorkoutActiveCalories(
        durationMinutes: 55,
        totalVolumeKg: 8400,
      ),
      totalVolumeKg: 8400,
    );
    final sampleLocalWeight = HealthWeightSample(
      id: 'local_wt_${now.millisecondsSinceEpoch}',
      timestamp: now,
      weightKg: 78.0,
      bodyFatPercent: 14.0,
      source: 'IronFlow',
    );

    final report = await widget.service.syncNow(
      exportWorkouts: _exportWorkouts,
      twoWayWeightSync: _twoWayWeightSync,
      localWorkouts: [sampleWorkout],
      localWeights: [sampleLocalWeight],
      since: DateTime(2026, 1, 1),
    );

    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _lastReport = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final platform = widget.service.gateway.platformType;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.monitor_heart_outlined,
                  color: tokens.kineticAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HEALTH CONNECT & HEALTHKIT',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      Text(
                        _platformLabel(platform),
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: tokens.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('health_sync_close_button'),
                  icon: Icon(Icons.close_rounded, color: tokens.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    key: const Key('health_toggle_export_workouts'),
                    activeThumbColor: tokens.kineticAccent,
                    title: Text(
                      'Export Completed Workouts',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Writes session duration, volume, and MET-estimated active kcal',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        color: tokens.textSecondary,
                      ),
                    ),
                    value: _exportWorkouts,
                    onChanged: (v) => setState(() => _exportWorkouts = v),
                  ),
                  Divider(color: tokens.borderSubtle, height: 1),
                  SwitchListTile(
                    key: const Key('health_toggle_weight_sync'),
                    activeThumbColor: tokens.cyanAccent,
                    title: Text(
                      'Two-Way Body Weight & Body Fat Sync',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Imports smart-scale measurements & exports logged body entries',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        color: tokens.textSecondary,
                      ),
                    ),
                    value: _twoWayWeightSync,
                    onChanged: (v) => setState(() => _twoWayWeightSync = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('health_sync_now_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.kineticAccent,
                  foregroundColor: tokens.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isSyncing ? null : _handleSyncNow,
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: Text(_isSyncing ? 'SYNCING...' : 'SYNC NOW'),
              ),
            ),
            if (_lastReport != null) ...[
              const SizedBox(height: 14),
              Container(
                key: const Key('health_sync_report_card'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  border: Border.all(color: tokens.cyanAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYNC COMPLETE · ${_lastReport!.permissionStatus.name.toUpperCase()}',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tokens.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastReport!.message,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
