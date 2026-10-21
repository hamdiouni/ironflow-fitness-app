import 'package:hive/hive.dart';

import '../../../../core/utils/user_scoped_hive_key.dart';
import '../models/body_entry_model.dart';

/// Recursively casts a [Map<dynamic, dynamic>] (as returned by Hive) to
/// [Map<String, dynamic>] so that json_serializable can deserialize it.
Map<String, dynamic> _deepCast(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), _deepCast(value));
    } else if (value is List) {
      return MapEntry(key.toString(), _deepCastList(value));
    }
    return MapEntry(key.toString(), value);
  });
}

List<dynamic> _deepCastList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) return _deepCast(item);
    if (item is List) return _deepCastList(item);
    return item;
  }).toList();
}

class HiveBodyDataSource {
  static const String boxName = 'body_entries';

  final String? userId;

  HiveBodyDataSource({this.userId});

  Box<Map> get _box => Hive.box<Map>(boxName);

  String _storageKey(String id) => UserScopedHiveKey.encode(userId, id);

  bool _ownsKey(Object? key) => UserScopedHiveKey.belongsTo(key, userId);

  Future<void> saveBodyEntry(BodyEntryModel entry) async {
    try {
      print('📊 [BodyData] Saving body measurement...');
      print('🔍 [BodyData] Entry ID: ${entry.id}, Weight: ${entry.weight}kg');
      
      if (!_box.isOpen) {
        print('⚠️ [BodyData] Body entries box is not open');
        throw Exception('Body entries box not open');
      }
      
      await _box.put(_storageKey(entry.id), entry.toJson());
      
      print('✅ [BodyData] Body measurement saved successfully');
      print('🔍 [BodyData] Weight: ${entry.weight}kg, Date: ${entry.date}, Measurements: ${entry.measurements.length}');
    } catch (e, stackTrace) {
      print('❌ [BodyData] Failed to save body measurement: $e');
      print('🔍 [BodyData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<BodyEntryModel>> getAllBodyEntries() async {
    try {
      print('📊 [BodyData] Retrieving all body measurements...');
      
      if (!_box.isOpen) {
        print('⚠️ [BodyData] Body entries box is not open');
        throw Exception('Body entries box not open');
      }
      
      final ownedKeys = _box.keys.where(_ownsKey).toList();
      print('🔍 [BodyData] Box contains ${ownedKeys.length} entries for this user');
      
      final entries = ownedKeys
          .map((key) => _box.get(key))
          .whereType<Map>()
          .map((json) => BodyEntryModel.fromJson(_deepCast(json)))
          .toList();

      // Sort by date descending
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      print('✅ [BodyData] Retrieved ${entries.length} body measurements');
      print('🔍 [BodyData] Sorted by date descending');
      
      return entries;
    } catch (e, stackTrace) {
      print('❌ [BodyData] Failed to retrieve body measurements: $e');
      print('🔍 [BodyData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteBodyEntry(String id) async {
    try {
      print('📊 [BodyData] Deleting body measurement...');
      print('🔍 [BodyData] Entry ID: $id');
      
      if (!_box.isOpen) {
        print('⚠️ [BodyData] Body entries box is not open');
        throw Exception('Body entries box not open');
      }
      
      await _box.delete(_storageKey(id));
      
      print('✅ [BodyData] Body measurement deleted successfully');
    } catch (e, stackTrace) {
      print('❌ [BodyData] Failed to delete body measurement: $e');
      print('🔍 [BodyData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
