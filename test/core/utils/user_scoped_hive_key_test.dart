import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/utils/user_scoped_hive_key.dart';

void main() {
  group('UserScopedHiveKey', () {
    test('encodes records with the owner ID', () {
      expect(UserScopedHiveKey.encode('user-a', 'record-1'), 'user-a::record-1');
    });

    test('keeps legacy records visible only while signed out', () {
      expect(UserScopedHiveKey.belongsTo('record-1', null), isTrue);
      expect(UserScopedHiveKey.belongsTo('user-a::record-1', null), isFalse);
      expect(UserScopedHiveKey.belongsTo('record-1', 'user-a'), isFalse);
    });

    test('isolates each account and allows legacy records to be migrated explicitly', () {
      expect(UserScopedHiveKey.belongsTo('user-a::record-1', 'user-a'), isTrue);
      expect(UserScopedHiveKey.belongsTo('user-a::record-1', 'user-b'), isFalse);
      expect(UserScopedHiveKey.belongsTo('user-ab::record-1', 'user-a'), isFalse);
    });

    test('rejects invalid authenticated owner IDs', () {
      expect(() => UserScopedHiveKey.encode('', 'record-1'), throwsArgumentError);
      expect(() => UserScopedHiveKey.encode('user/a', 'record-1'), throwsArgumentError);
      expect(() => UserScopedHiveKey.encode('user::a', 'record-1'), throwsArgumentError);
    });
  });
}
