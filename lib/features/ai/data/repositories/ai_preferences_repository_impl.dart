import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../domain/repositories/ai_preferences_repository.dart';

/// [SharedPreferences]-backed implementation of [AIPreferencesRepository].
class AIPreferencesRepositoryImpl implements AIPreferencesRepository {
  static const String consentKey = 'ai_personalization_consent';
  static const String dismissedBannersKey = 'ironflow_dismissed_ai_banners';

  static String consentKeyForUser(String? userId) {
    final scopeUserId = RecordOwnershipRules.normalizeUserId(userId);
    return scopeUserId == null ? consentKey : '${consentKey}_$scopeUserId';
  }

  static String dismissedBannersKeyForUser(String? userId) {
    final scopeUserId = RecordOwnershipRules.storageScope(userId);
    return scopeUserId == null
        ? dismissedBannersKey
        : '${dismissedBannersKey}_$scopeUserId';
  }

  static Future<bool> loadStoredConsentFromPrefs(
    SharedPreferences prefs, {
    String? userId,
  }) async {
    final storageKey = consentKeyForUser(userId);
    var consent = prefs.getBool(storageKey);

    if (consent == null && storageKey != consentKey) {
      final hasScopedConsent = prefs
          .getKeys()
          .any((storedKey) => storedKey.startsWith('${consentKey}_'));
      final legacyConsent = prefs.getBool(consentKey);
      if (!hasScopedConsent && legacyConsent != null) {
        consent = legacyConsent;
        await prefs.setBool(storageKey, legacyConsent);
        await prefs.remove(consentKey);
      }
    }

    return consent ?? false;
  }

  @override
  Future<bool> loadPersonalizationConsent({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return loadStoredConsentFromPrefs(prefs, userId: userId);
  }

  @override
  Future<void> savePersonalizationConsent({
    required String? userId,
    required bool consent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(consentKeyForUser(userId), consent);
  }

  @override
  Future<Set<String>?> loadDismissedBanners({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = dismissedBannersKeyForUser(userId);
    var list = prefs.getStringList(storageKey);

    if (list == null && storageKey != dismissedBannersKey) {
      final hasScopedDismissals = prefs
          .getKeys()
          .any((key) => key.startsWith('${dismissedBannersKey}_'));
      final legacyList = prefs.getStringList(dismissedBannersKey);
      if (!hasScopedDismissals && legacyList != null) {
        list = legacyList;
        await prefs.setStringList(storageKey, legacyList);
        await prefs.remove(dismissedBannersKey);
      }
    }

    return list?.toSet();
  }

  @override
  Future<void> saveDismissedBanners({
    required String? userId,
    required Set<String> dismissedIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      dismissedBannersKeyForUser(userId),
      dismissedIds.toList(),
    );
  }

  @override
  Future<void> clearDismissedBanners({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dismissedBannersKeyForUser(userId));
  }
}

