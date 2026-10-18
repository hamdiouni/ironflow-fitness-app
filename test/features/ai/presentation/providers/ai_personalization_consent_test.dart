import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_chat_storage.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Batch E: AI Personalization Consent & Safety Guardrails Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Personalization consent defaults to false (privacy-first)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consent = container.read(aiPersonalizationConsentProvider);
      expect(consent, isFalse);
    });

    test('Setting consent updates state and persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(aiPersonalizationConsentProvider.notifier);
      await notifier.setConsent(true);

      expect(container.read(aiPersonalizationConsentProvider), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AIPersonalizationConsentNotifier.key), isTrue);

      await notifier.toggle();
      expect(container.read(aiPersonalizationConsentProvider), isFalse);
      expect(prefs.getBool(AIPersonalizationConsentNotifier.key), isFalse);
    });

    test('AIChatNotifier instantiates cleanly with safe defaults', () {
      final container = ProviderContainer(
        overrides: [
          aiChatStorageProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(aiChatProvider.notifier);

      // Verify that chat notifier can be instantiated cleanly
      expect(notifier, isNotNull);
      expect(container.read(aiChatProvider).messages, isEmpty);
    });
  });
}
