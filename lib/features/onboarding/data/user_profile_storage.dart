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
    if (kDebugMode) {
      print('✅ [Onboarding] User marked as onboarded');
    }
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
