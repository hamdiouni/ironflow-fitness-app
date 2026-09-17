import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_all_data_use_case.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Entity representing a backup record.
class BackupRecord {
  final String id;
  final DateTime createdAt;
  final String fileName;
  final int fileSize;
  final String cloudPath;
  final BackupType type;
  final Map<String, int> statistics;

  const BackupRecord({
    required this.id,
    required this.createdAt,
    required this.fileName,
    required this.fileSize,
    required this.cloudPath,
    required this.type,
    required this.statistics,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'file_name': fileName,
    'file_size': fileSize,
    'cloud_path': cloudPath,
    'type': type.toString(),
    'statistics': statistics,
  };

  factory BackupRecord.fromJson(Map<String, dynamic> json) => BackupRecord(
    id: json['id'],
    createdAt: DateTime.parse(json['created_at']),
    fileName: json['file_name'],
    fileSize: json['file_size'],
    cloudPath: json['cloud_path'],
    type: BackupType.values.firstWhere((e) => e.toString() == json['type']),
    statistics: Map<String, int>.from(json['statistics']),
  );
}

/// Types of backups available.
enum BackupType {
  automatic,
  manual,
  scheduled,
}

/// Use case for backing up user data to cloud storage.
class BackupDataUseCase {
  final ExportAllDataUseCase _exportAllDataUseCase;
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  BackupDataUseCase(
    this._exportAllDataUseCase,
    this._authRepository,
    this._firestore,
    this._storage,
  );

  /// Creates a manual backup of all user data.
  ///
  /// Returns the backup record with cloud storage information.
  Future<BackupRecord> createManualBackup() async {
    return await _createBackup(BackupType.manual);
  }

  /// Creates an automatic backup (called by system).
  ///
  /// Returns the backup record with cloud storage information.
  Future<BackupRecord> createAutomaticBackup() async {
    return await _createBackup(BackupType.automatic);
  }

  /// Creates a scheduled backup.
  ///
  /// Returns the backup record with cloud storage information.
  Future<BackupRecord> createScheduledBackup() async {
    return await _createBackup(BackupType.scheduled);
  }

  /// Gets all backup records for the current user.
  ///
  /// Returns a list of backup records sorted by creation date (newest first).
  Future<List<BackupRecord>> getAllBackups() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.id)
        .collection('backups')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BackupRecord.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Deletes a backup from cloud storage and removes the record.
  ///
  /// [backupId] - ID of the backup to delete
  Future<void> deleteBackup(String backupId) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');

    // Get backup record
    final doc = await _firestore
        .collection('users')
        .doc(user.id)
        .collection('backups')
        .doc(backupId)
        .get();

    if (!doc.exists) throw Exception('Backup not found');

    final backup = BackupRecord.fromJson({...doc.data()!, 'id': doc.id});

    // Delete from cloud storage
    try {
      await _storage.ref(backup.cloudPath).delete();
    } catch (e) {
      // File might already be deleted, continue with record deletion
    }

    // Delete record
    await doc.reference.delete();
  }

  /// Cleans up old automatic backups, keeping only the specified number.
  ///
  /// [keepCount] - Number of automatic backups to keep (default: 7)
  Future<void> cleanupOldBackups({int keepCount = 7}) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.id)
        .collection('backups')
        .where('type', isEqualTo: BackupType.automatic.toString())
        .orderBy('created_at', descending: true)
        .get();

    final backups = snapshot.docs
        .map((doc) => BackupRecord.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Delete old backups beyond keepCount
    if (backups.length > keepCount) {
      final toDelete = backups.skip(keepCount);
      for (final backup in toDelete) {
        await deleteBackup(backup.id);
      }
    }
  }

  /// Gets backup statistics for the current user.
  ///
  /// Returns a map with backup counts and storage usage.
  Future<Map<String, dynamic>> getBackupStatistics() async {
    final backups = await getAllBackups();
    
    final totalBackups = backups.length;
    final automaticBackups = backups.where((b) => b.type == BackupType.automatic).length;
    final manualBackups = backups.where((b) => b.type == BackupType.manual).length;
    final totalSize = backups.fold<int>(0, (sum, b) => sum + b.fileSize);
    final lastBackup = backups.isNotEmpty ? backups.first.createdAt : null;

    return {
      'total_backups': totalBackups,
      'automatic_backups': automaticBackups,
      'manual_backups': manualBackups,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'last_backup': lastBackup?.toIso8601String(),
      'oldest_backup': backups.isNotEmpty ? backups.last.createdAt.toIso8601String() : null,
    };
  }

  /// Schedules automatic daily backups.
  ///
  /// This should be called during app initialization.
  Future<void> scheduleAutomaticBackups() async {
    // TODO: Implement with workmanager or similar background task scheduler
    // For now, this is a placeholder that would be called by a background service
  }

  /// Checks if a backup is needed based on the last backup date.
  ///
  /// Returns true if more than 24 hours have passed since the last automatic backup.
  Future<bool> isBackupNeeded() async {
    final backups = await getAllBackups();
    final automaticBackups = backups.where((b) => b.type == BackupType.automatic);
    
    if (automaticBackups.isEmpty) return true;
    
    final lastBackup = automaticBackups.first;
    final hoursSinceLastBackup = DateTime.now().difference(lastBackup.createdAt).inHours;
    
    return hoursSinceLastBackup >= 24;
  }

  Future<BackupRecord> _createBackup(BackupType type) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');

    // Get export statistics
    final statistics = await _exportAllDataUseCase.getExportStatistics();

    // Create local backup file
    final localFilePath = await _exportAllDataUseCase.exportToJSON();
    final file = File(localFilePath);
    final fileSize = await file.length();

    // Generate backup metadata
    final timestamp = DateTime.now();
    final backupId = '${type.name}_${timestamp.millisecondsSinceEpoch}';
    final fileName = 'backup_${_formatTimestamp(timestamp)}.json';
    final cloudPath = 'users/${user.id}/backups/$fileName';

    try {
      // Upload to cloud storage
      final uploadTask = _storage.ref(cloudPath).putFile(file);
      await uploadTask;

      // Create backup record
      final backupRecord = BackupRecord(
        id: backupId,
        createdAt: timestamp,
        fileName: fileName,
        fileSize: fileSize,
        cloudPath: cloudPath,
        type: type,
        statistics: statistics,
      );

      // Save backup record to Firestore
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('backups')
          .doc(backupId)
          .set(backupRecord.toJson());

      // Clean up local file
      await file.delete();

      // Clean up old automatic backups
      if (type == BackupType.automatic) {
        await cleanupOldBackups();
      }

      return backupRecord;
    } catch (e) {
      // Clean up local file on error
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}';
  }
}