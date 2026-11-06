/// Repository interface isolating AI consent & banner dismissal storage from presentation providers.
abstract class AIPreferencesRepository {
  Future<bool> loadPersonalizationConsent({String? userId});
  Future<void> savePersonalizationConsent({
    required String? userId,
    required bool consent,
  });

  Future<Set<String>?> loadDismissedBanners({String? userId});
  Future<void> saveDismissedBanners({
    required String? userId,
    required Set<String> dismissedIds,
  });
  Future<void> clearDismissedBanners({String? userId});
}

