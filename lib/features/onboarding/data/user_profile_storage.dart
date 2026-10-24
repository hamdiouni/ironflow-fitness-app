import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/entities/user_profile.dart';

/// Persists and retrieves [UserProfile] using Hive.
class UserProfileStorage {
  static const _boxName = 'user_profile';
  static const _profileKeyPrefix = 'profile_';
  static const _onboardedKeyPrefix = 'onboarded_';
  static const _draftStepKeyPrefix = 'draft_step_';
  static const _draftDataKeyPrefix = 'draft_data_';

  // Legacy keys for fallback
  static const _legacyProfileKey = 'profile';
  static const _legacyOnboardedKey = 'onboarded';
  static const _legacyDraftStepKey = 'draft_step';
  static const _legacyDraftDataKey = 'draft_data';

  Future<Box> get _box async => Hive.openBox(_boxName);

  String? _resolveCurrentUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) return userId;
    if (Hive.isBoxOpen('auth_session')) {
      final sessionBox = Hive.box('auth_session');
      final isLoggedIn = sessionBox.get('is_logged_in', defaultValue: false) as bool;
      if (isLoggedIn) {
        final currentUid = sessionBox.get('user_id') as String?;
        if (currentUid != null && currentUid.isNotEmpty) return currentUid;
      }
    }
    return null;
  }

  String _getOnboardedKey(String? userId) {
    final resolved = _resolveCurrentUserId(userId);
    if (resolved != null && resolved.isNotEmpty) {
      return '$_onboardedKeyPrefix$resolved';
    }
    return _legacyOnboardedKey;
  }

  String _getProfileKey(String? userId) {
    final resolved = _resolveCurrentUserId(userId);
    if (resolved != null && resolved.isNotEmpty) {
      return '$_profileKeyPrefix$resolved';
    }
    return _legacyProfileKey;
  }

  String _getDraftStepKey(String? userId) {
    final resolved = _resolveCurrentUserId(userId);
    if (resolved != null && resolved.isNotEmpty) {
      return '$_draftStepKeyPrefix$resolved';
    }
    return _legacyDraftStepKey;
  }

  String _getDraftDataKey(String? userId) {
    final resolved = _resolveCurrentUserId(userId);
    if (resolved != null && resolved.isNotEmpty) {
      return '$_draftDataKeyPrefix$resolved';
    }
    return _legacyDraftDataKey;
  }

  /// Synchronous check if user is onboarded.
  /// If a user ID is specified or resolved from an active auth session, checks user-specific flag first,
  /// then user-specific profile. If neither exists for a given user, returns false.
  bool isOnboardedSync({String? userId}) {
    if (Hive.isBoxOpen(_boxName)) {
      final box = Hive.box(_boxName);
      final resolvedUid = _resolveCurrentUserId(userId);
      if (resolvedUid != null && resolvedUid.isNotEmpty) {
        final userVal = box.get(_getOnboardedKey(resolvedUid));
        if (userVal != null) {
          return userVal as bool;
        }
        final userProfile = box.get(_getProfileKey(resolvedUid));
        if (userProfile != null) {
          return true;
        }
        return false;
      }
      return box.get(_legacyOnboardedKey, defaultValue: false) as bool;
    }
    return false;
  }

  Future<bool> isOnboarded({String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      final userVal = box.get(_getOnboardedKey(resolvedUid));
      if (userVal != null) {
        final result = userVal as bool;
        if (kDebugMode) {
          AppLogger.debug('📊 [Onboarding] Checking onboarding status for $resolvedUid: $result');
        }
        return result;
      }
      final userProfile = box.get(_getProfileKey(resolvedUid));
      if (userProfile != null) {
        if (kDebugMode) {
          AppLogger.debug('📊 [Onboarding] User profile exists for $resolvedUid -> onboarded');
        }
        return true;
      }
      if (kDebugMode) {
        AppLogger.debug('📊 [Onboarding] No profile/onboarded flag found for $resolvedUid -> needs onboarding');
      }
      return false;
    }
    final result = box.get(_legacyOnboardedKey, defaultValue: false) as bool;
    if (kDebugMode) {
      AppLogger.debug('📊 [Onboarding] Checking global onboarding status: $result');
    }
    return result;
  }

  Future<void> markOnboarded({String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      await box.put(_getOnboardedKey(resolvedUid), true);
    }
    await box.put(_legacyOnboardedKey, true);
    await clearDraft(userId: resolvedUid);
    if (kDebugMode) {
      AppLogger.debug('✅ [Onboarding] User marked as onboarded (userId: $resolvedUid)');
    }
  }

  Future<void> resetOnboarding({String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      await box.put(_getOnboardedKey(resolvedUid), false);
      await box.delete(_getProfileKey(resolvedUid));
      await clearDraft(userId: resolvedUid);
    } else {
      for (final key in box.keys.toList()) {
        final keyStr = key.toString();
        if (keyStr.startsWith('onboarded_')) {
          await box.put(key, false);
        } else if (keyStr.startsWith('draft_')) {
          await box.delete(key);
        } else if (keyStr.startsWith('profile_')) {
          await box.delete(key);
        }
      }
      await clearDraft();
    }
    await box.put(_legacyOnboardedKey, false);
    if (kDebugMode) {
      AppLogger.debug('🔄 [Onboarding] User marked as NOT onboarded (reset, userId: $resolvedUid)');
    }
  }

  Future<void> saveDraft({
    required int step,
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    await box.put(_getDraftStepKey(resolvedUid), step);
    await box.put(_getDraftDataKey(resolvedUid), jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getDraft({String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    String? raw;
    int step = 0;

    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      raw = box.get(_getDraftDataKey(resolvedUid)) as String?;
      step = box.get(_getDraftStepKey(resolvedUid), defaultValue: 0) as int;

      if (raw == null) {
        // Same one-time legacy adoption rule as profiles: only when no
        // account-scoped draft exists yet, so one account's onboarding
        // draft is never resumed by another account.
        final hasScopedDraft = box.keys
            .any((key) => key.toString().startsWith(_draftDataKeyPrefix));
        if (!hasScopedDraft) {
          raw = box.get(_legacyDraftDataKey) as String?;
          step = box.get(_legacyDraftStepKey, defaultValue: 0) as int;
          if (raw != null) {
            await box.put(_getDraftDataKey(resolvedUid), raw);
            await box.put(_getDraftStepKey(resolvedUid), step);
            await box.delete(_legacyDraftDataKey);
            await box.delete(_legacyDraftStepKey);
          }
        }
      }
    } else {
      raw = box.get(_legacyDraftDataKey) as String?;
      step = box.get(_legacyDraftStepKey, defaultValue: 0) as int;
    }

    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map['draft_step'] = step;
      return map;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft({String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      await box.delete(_getDraftStepKey(resolvedUid));
      await box.delete(_getDraftDataKey(resolvedUid));
    }
    await box.delete(_legacyDraftStepKey);
    await box.delete(_legacyDraftDataKey);
  }

  Future<void> saveProfile(UserProfile profile, {String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    final jsonStr = jsonEncode(profile.toJson());
    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      // Account-scoped only. The legacy global key used to be overwritten
      // on every save, which made the most recent account's profile the
      // fallback profile for every other account on the device.
      await box.put(_getProfileKey(resolvedUid), jsonStr);
    } else {
      await box.put(_legacyProfileKey, jsonStr);
    }
  }

  Future<UserProfile?> loadProfile({String? userId}) async {
    final box = await _box;
    final resolvedUid = _resolveCurrentUserId(userId);
    String? raw;
    if (resolvedUid != null && resolvedUid.isNotEmpty) {
      raw = box.get(_getProfileKey(resolvedUid)) as String?;
      if (raw == null) {
        // One-time migration for installs that predate per-account keys:
        // adopt the legacy profile only when NO account-scoped profile
        // exists yet. If one does, the legacy value may belong to a
        // different account and must not be shown to this user.
        final hasScopedProfile = box.keys
            .any((key) => key.toString().startsWith(_profileKeyPrefix));
        if (!hasScopedProfile) {
          raw = box.get(_legacyProfileKey) as String?;
          if (raw != null) {
            await box.put(_getProfileKey(resolvedUid), raw);
            await box.delete(_legacyProfileKey);
          }
        }
      }
    } else {
      raw = box.get(_legacyProfileKey) as String?;
    }
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
