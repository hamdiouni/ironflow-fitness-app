import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/entities/user_profile.dart';

/// Persists and retrieves [UserProfile] using Hive.
class UserProfileStorage {
  static const _boxName = 'user_profile';
  static const _profileKey = 'profile';
  static const _onboardedKey = 'onboarded';

  Future<Box> get _box async => Hive.openBox(_boxName);

  /// Synchronous check if user is onboarded.
  /// Relies on HiveManager.initialize() having opened the box, or returns false if unopened.
  bool isOnboardedSync() {
    if (Hive.isBoxOpen(_boxName)) {
      final result = Hive.box(_boxName).get(_onboardedKey, defaultValue: false) as bool;
      return result;
    }
    return false;
  }

  Future<bool> isOnboarded() async {
    final box = await _box;
    final result = box.get(_onboardedKey, defaultValue: false) as bool;
    if (kDebugMode) {
      print('📊 [Onboarding] Checking onboarding status: $result');
    }
    return result;
  }

  Future<void> markOnboarded() async {
    final box = await _box;
    await box.put(_onboardedKey, true);
    await clearDraft();
    if (kDebugMode) {
      print('✅ [Onboarding] User marked as onboarded');
    }
  }

  Future<void> resetOnboarding() async {
    final box = await _box;
    await box.put(_onboardedKey, false);
    await clearDraft();
    if (kDebugMode) {
      print('🔄 [Onboarding] User marked as NOT onboarded (reset)');
    }
  }

  static const _draftStepKey = 'draft_step';
  static const _draftDataKey = 'draft_data';

  Future<void> saveDraft({required int step, required Map<String, dynamic> data}) async {
    final box = await _box;
    await box.put(_draftStepKey, step);
    await box.put(_draftDataKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getDraft() async {
    final box = await _box;
    final raw = box.get(_draftDataKey) as String?;
    final step = box.get(_draftStepKey, defaultValue: 0) as int;
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map['draft_step'] = step;
      return map;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    final box = await _box;
    await box.delete(_draftStepKey);
    await box.delete(_draftDataKey);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _box;
    await box.put(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final box = await _box;
    final raw = box.get(_profileKey) as String?;
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
