import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for periodic background sync
/// This is a simple foreground periodic sync since WorkManager is incompatible
class PeriodicSyncService {
  static final PeriodicSyncService _instance = PeriodicSyncService._internal();
  factory PeriodicSyncService() => _instance;
  PeriodicSyncService._internal();

  Timer? _syncTimer;
  bool _isRunning = false;
  final Duration _syncInterval = const Duration(minutes: 15);

  /// Callback to execute on each sync
  Future<void> Function()? _onSync;

  /// Start periodic sync
  void start({required Future<void> Function() onSync}) {
    if (_isRunning) {
      print('⚠️ Periodic sync already running');
      return;
    }

    _onSync = onSync;
    _isRunning = true;

    // Run initial sync
    _performSync();

    // Schedule periodic sync
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _performSync();
    });

    print('✅ Periodic sync started (every ${_syncInterval.inMinutes} minutes)');
  }

  /// Stop periodic sync
  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isRunning = false;
    _onSync = null;
    print('❌ Periodic sync stopped');
  }

  /// Perform sync if online
  Future<void> _performSync() async {
    if (_onSync == null) return;

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);

      if (!isOnline) {
        print('⚠️ Skipping sync - device is offline');
        return;
      }

      print('🔄 Running periodic sync...');
      await _onSync!();
      print('✅ Periodic sync completed');
    } catch (e) {
      print('❌ Periodic sync failed: $e');
    }
  }

  /// Manually trigger sync
  Future<void> triggerSync() async {
    if (_onSync != null) {
      await _performSync();
    }
  }

  /// Check if sync is running
  bool get isRunning => _isRunning;
}
