import 'package:hive/hive.dart';
import '../../../../core/utils/hive_json_utils.dart';
import '../../../../core/utils/hive_manager.dart';
import '../../../../core/utils/record_ownership.dart';
import '../models/diet_plan_state_model.dart';

/// Hive data source for diet plan storage.
///
/// Plans are stored per signed-in user (`current_diet_plan_<uid>`). The
/// previous single global key meant every account on a device shared —
/// and overwrote — the same diet plan. The legacy key is adopted once,
/// only when no per-account plan exists yet, mirroring
/// `UserProfileStorage`.
class HiveDietPlanDataSource {
  static const String boxName = HiveManager.dietPlanBox;
  static const String key = 'current_diet_plan';

  Future<Box<Map>> get _box => HiveManager.ensureDietPlanBox();

  String? _sessionUserId() {
    if (!Hive.isBoxOpen(HiveManager.authSessionBox)) return null;
    final sessionBox = HiveManager.getAuthSessionBox();
    final isLoggedIn =
        sessionBox.get('is_logged_in', defaultValue: false) as bool;
    if (!isLoggedIn) return null;
    final userId = sessionBox.get('user_id') as String?;
    return (userId != null && userId.isNotEmpty) ? userId : null;
  }

  String? _resolveUserId(String? userId) {
    final raw = (userId != null && userId.isNotEmpty) ? userId : _sessionUserId();
    return RecordOwnershipRules.storageScope(raw);
  }

  String _scopedKey(String userId) => '${key}_$userId';

  /// Save the diet plan to local storage for [userId], when supplied.
  Future<void> saveDietPlan(
    DietPlanStateModel planState, {
    String? userId,
  }) async {
    final box = await _box;
    final resolvedUserId = _resolveUserId(userId);
    await box.put(
      resolvedUserId == null ? key : _scopedKey(resolvedUserId),
      planState.toJson(),
    );
  }

  /// Load the diet plan from local storage for [userId], when supplied.
  Future<DietPlanStateModel?> loadDietPlan({String? userId}) async {
    final box = await _box;
    final resolvedUserId = _resolveUserId(userId);

    Map? json;
    if (resolvedUserId != null) {
      json = box.get(_scopedKey(resolvedUserId));
      if (json == null) {
        // One-time adoption of a pre-scoping plan, only when no
        // per-account plan exists yet (otherwise the legacy plan may
        // belong to a different account).
        final hasScopedPlan =
            box.keys.any((k) => k.toString().startsWith('${key}_'));
        if (!hasScopedPlan) {
          json = box.get(key);
          if (json != null) {
            await box.put(_scopedKey(resolvedUserId), json);
            await box.delete(key);
          }
        }
      }
    } else {
      json = box.get(key);
    }

    if (json == null) return null;

    return DietPlanStateModel.fromJson(deepCastMap(json));
  }

  /// Clear the diet plan from local storage for [userId], when supplied.
  Future<void> clearDietPlan({String? userId}) async {
    final box = await _box;
    final resolvedUserId = _resolveUserId(userId);
    await box.delete(
      resolvedUserId == null ? key : _scopedKey(resolvedUserId),
    );
  }
}
