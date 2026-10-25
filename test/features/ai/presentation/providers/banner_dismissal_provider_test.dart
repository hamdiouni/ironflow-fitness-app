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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('dismissals are stored separately for each user', () async {
    final aliceNotifier = BannerDismissalNotifier(userId: 'Alice');
    final bobNotifier = BannerDismissalNotifier(userId: 'bob');
    await waitForLoad();

    await aliceNotifier.dismiss('Alice-insight');
    await bobNotifier.dismiss('bob-insight');

    final prefs = await SharedPreferences.getInstance();
    expect(aliceNotifier.state, <String>{'Alice-insight'});
    expect(bobNotifier.state, <String>{'bob-insight'});
    expect(prefs.getStringList(aliceKey), <String>['Alice-insight']);
    expect(prefs.getStringList(bobKey), <String>['bob-insight']);
    expect(prefs.getStringList(legacyKey), isNull);
  });

  test('legacy dismissals migrate only to the first scoped user', () async {
    SharedPreferences.setMockInitialValues({
      legacyKey: <String>['legacy-insight'],
    });

    final aliceNotifier = BannerDismissalNotifier(userId: 'Alice');
    await waitForLoad();
    final bobNotifier = BannerDismissalNotifier(userId: 'bob');
    await waitForLoad();

    final prefs = await SharedPreferences.getInstance();
    expect(aliceNotifier.state, <String>{'legacy-insight'});
    expect(bobNotifier.state, isEmpty);
    expect(prefs.getStringList(aliceKey), <String>['legacy-insight']);
    expect(prefs.getStringList(legacyKey), isNull);
  });

  test('reset removes only the scoped user dismissals', () async {
    final aliceNotifier = BannerDismissalNotifier(userId: 'Alice');
    final bobNotifier = BannerDismissalNotifier(userId: 'bob');
    await waitForLoad();
    await aliceNotifier.dismiss('Alice-insight');
    await bobNotifier.dismiss('bob-insight');

    await aliceNotifier.reset();

    final prefs = await SharedPreferences.getInstance();
    expect(aliceNotifier.state, isEmpty);
    expect(bobNotifier.state, <String>{'bob-insight'});
    expect(prefs.getStringList(aliceKey), isNull);
    expect(prefs.getStringList(bobKey), <String>['bob-insight']);
  });
}
