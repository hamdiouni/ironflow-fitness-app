import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/firestore_food_datasource.dart';
import '../../data/datasources/hive_food_datasource.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../domain/repositories/food_repository.dart';

/// THE food repository provider (Phase 3, F-10).
///
/// Three same-named providers used to exist (in `nutrition_providers`,
/// `food_providers`, and an untyped one in `food_cache_provider`), each
/// constructing — or miscasting — something different depending on which
/// file a screen happened to import. All consumers now resolve this one.
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  // Custom foods belong to the signed-in account; rebuild the local
  // data source with the guest bucket while signed out.
  final userId =
      ref.watch(currentUserIdProvider) ?? RecordOwnershipRules.guestUserId;
  return FoodRepositoryImpl(
    firestoreDataSource: FirestoreFoodDatasource(FirebaseFirestore.instance),
    hiveDataSource: HiveFoodDataSource(userId: userId),
  );
});
