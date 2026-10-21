import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/utils/user_scoped_hive_key.dart';
import '../domain/entities/user_profile.dart';

/// Persists and retrieves [UserProfile] using Hive.
class UserProfileStorage {
  static const _boxName = 'user_profile';
  static const _profileKey = 'profile';
  static const _onboardedKey = 'onboarded';

  final String? userId;

  UserProfileStorage({this.userId});

  String get _profileStorageKey => UserScopedHiveKey.encode(userId, _profileKey);
  String get _onboardedStorageKey =>
      UserScopedHiveKey.encode(userId, _onboardedKey);

  Future<Box> get _box async => Hive.openBox(_boxName);

  Future<bool> isOnboarded() async {
    final box = await _box;
    final result = box.get(_onboardedStorageKey, defaultValue: false) as bool;
    if (kDebugMode) {
      print('📊 [Onboarding] Checking onboarding status: $result');
    }
    return result;
  }

  Future<void> markOnboarded() async {
    final box = await _box;
    await box.put(_onboardedStorageKey, true);
    if (kDebugMode) {
      print('✅ [Onboarding] User marked as onboarded');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _box;
    await box.put(_profileStorageKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final box = await _box;
    final raw = box.get(_profileStorageKey) as String?;
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
