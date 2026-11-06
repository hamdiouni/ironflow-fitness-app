import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progression_tracker/features/ai/presentation/providers/banner_dismissal_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const legacyKey = 'ironflow_dismissed_ai_banners';
  const aliceKey = 'ironflow_dismissed_ai_banners_alice';
  const bobKey = 'ironflow_dismissed_ai_banners_bob';

  Future<void> waitForLoad() {
    return Future<void>.delayed(const Duration(milliseconds: 1));
  }

  ProviderContainer createUserContainer(String userId) {
    final container = ProviderContainer(
      overrides: [
        bannerDismissalProvider.overrideWith(
          () => BannerDismissalNotifier(userId: userId),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(bannerDismissalProvider);
    return container;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('dismissals are stored separately for each user', () async {
    final aliceContainer = createUserContainer('Alice');
    final bobContainer = createUserContainer('bob');
    await waitForLoad();

    await aliceContainer
        .read(bannerDismissalProvider.notifier)
        .dismiss('Alice-insight');
    await bobContainer
        .read(bannerDismissalProvider.notifier)
        .dismiss('bob-insight');

    final prefs = await SharedPreferences.getInstance();
    expect(aliceContainer.read(bannerDismissalProvider), <String>{'Alice-insight'});
    expect(bobContainer.read(bannerDismissalProvider), <String>{'bob-insight'});
    expect(prefs.getStringList(aliceKey), <String>['Alice-insight']);
    expect(prefs.getStringList(bobKey), <String>['bob-insight']);
    expect(prefs.getStringList(legacyKey), isNull);
  });

  test('legacy dismissals migrate only to the first scoped user', () async {
    SharedPreferences.setMockInitialValues({
      legacyKey: <String>['legacy-insight'],
    });

    final aliceContainer = createUserContainer('Alice');
    await waitForLoad();
    final bobContainer = createUserContainer('bob');
    await waitForLoad();

    final prefs = await SharedPreferences.getInstance();
    expect(aliceContainer.read(bannerDismissalProvider), <String>{'legacy-insight'});
    expect(bobContainer.read(bannerDismissalProvider), isEmpty);
    expect(prefs.getStringList(aliceKey), <String>['legacy-insight']);
    expect(prefs.getStringList(legacyKey), isNull);
  });

  test('reset removes only the scoped user dismissals', () async {
    final aliceContainer = createUserContainer('Alice');
    final bobContainer = createUserContainer('bob');
    await waitForLoad();
    await aliceContainer
        .read(bannerDismissalProvider.notifier)
        .dismiss('Alice-insight');
    await bobContainer
        .read(bannerDismissalProvider.notifier)
        .dismiss('bob-insight');

    await aliceContainer.read(bannerDismissalProvider.notifier).reset();

    final prefs = await SharedPreferences.getInstance();
    expect(aliceContainer.read(bannerDismissalProvider), isEmpty);
    expect(bobContainer.read(bannerDismissalProvider), <String>{'bob-insight'});
    expect(prefs.getStringList(aliceKey), isNull);
    expect(prefs.getStringList(bobKey), <String>['bob-insight']);
  });
}
