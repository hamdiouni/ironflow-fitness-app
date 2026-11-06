// Wave 2.2 — runs the seven end-to-end journeys on a real device or emulator.
//
//   flutter test integration_test/wave2_e2e_journeys_test.dart -d <device-id>
//
// The journeys use a temp Hive directory, mocked SharedPreferences and fake
// platform edges, so they never touch real user data, Firebase or the AI
// service. The same journeys run headless in CI from
// test/integration/wave2_e2e_journeys_test.dart.

import 'package:integration_test/integration_test.dart';

import '../test/integration/wave2_e2e_journeys_test.dart' as journeys;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  journeys.defineWave2Journeys();
}

