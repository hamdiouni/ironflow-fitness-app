import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/hive_json_utils.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import '../models/body_entry_model.dart';

class HiveBodyDataSource {
  static const String boxName = HiveManager.bodyEntriesBox;

  Future<Box<Map>> get _box => HiveManager.ensureBodyEntriesBox();

  Future<void> saveBodyEntry(BodyEntryModel entry) async {
    try {
      AppLogger.debug('📊 [BodyData] Saving body measurement...');
      AppLogger.debug('🔍 [BodyData] Entry ID: ${entry.id}, Weight: ${entry.weight}kg');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [BodyData] Body entries box is not open');
        throw Exception('Body entries box not open');
      }
      
      await box.put(entry.id, entry.toJson());
      
      AppLogger.debug('✅ [BodyData] Body measurement saved successfully');
      AppLogger.debug('🔍 [BodyData] Weight: ${entry.weight}kg, Date: ${entry.date}, Measurements: ${entry.measurements.length}');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [BodyData] Failed to save body measurement: $e');
      AppLogger.debug('🔍 [BodyData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<BodyEntryModel>> getAllBodyEntries() async {
    try {
      AppLogger.debug('📊 [BodyData] Retrieving all body measurements...');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [BodyData] Body entries box is not open');
        throw Exception('Body entries box not open');
      }
      
      AppLogger.debug('🔍 [BodyData] Box contains ${box.length} entries');
      
      final entries = box.values
          .map((json) => BodyEntryModel.fromJson(deepCastMap(json)))
          .toList();

      // Sort by date descending
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      AppLogger.debug('✅ [BodyData] Retrieved ${entries.length} body measurements');
      AppLogger.debug('🔍 [BodyData] Sorted by date descending');
      
      return entries;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [BodyData] Failed to retrieve body measurements: $e');
      AppLogger.debug('🔍 [BodyData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Reactive stream of all body entries (Phase 3, F-12): emits the
  /// current snapshot immediately, then a fresh snapshot on every box
  /// change. Replaces the manual `bodyRefreshCounterProvider` bumps.
  Stream<List<BodyEntryModel>> watchAllBodyEntries() async* {
    final box = await _box;
    yield await getAllBodyEntries();
    yield* box.watch().asyncMap((_) => getAllBodyEntries());
  }

  Future<void> deleteBodyEntry(String id) async {
    try {
      AppLogger.debug('📊 [BodyData] Deleting body measurement...');
      AppLogger.debug('🔍 [BodyData] Entry ID: $id');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [BodyData] Body entries box is not open');
        throw Exception('Body entries box not open');
      }
      
      await box.delete(id);
      
      AppLogger.debug('✅ [BodyData] Body measurement deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [BodyData] Failed to delete body measurement: $e');
      AppLogger.debug('🔍 [BodyData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
