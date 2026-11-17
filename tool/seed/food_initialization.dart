import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'food_upload_script.dart';

/// Initializes the food database in Firestore if empty.
Future<void> initializeFoodDatabase(FirebaseFirestore firestore) async {
  try {
    final snapshot = await firestore.collection('foods').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      if (kDebugMode) {
        AppLogger.debug('✓ Foods already exist in Firestore, skipping upload');
      }
      return;
    }

    if (kDebugMode) {
      AppLogger.debug('Foods not found in Firestore, uploading...');
    }
    await uploadAllFoodsToFirestore(firestore);

    final isValid = await verifyFoodsInFirestore(firestore);
    if (kDebugMode) {
      AppLogger.debug(
        isValid
            ? '✓ Food database initialized successfully'
            : '✗ Food database verification failed',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      AppLogger.debug('✗ Error initializing food database: $e');
    }
  }
}

/// Force re-upload all foods to Firestore (admin script only).
Future<void> reinitializeFoodDatabase(FirebaseFirestore firestore) async {
  try {
    if (kDebugMode) {
      AppLogger.debug('Re-initializing food database...');
    }
    await deleteAllFoodsFromFirestore(firestore);
    await uploadAllFoodsToFirestore(firestore);
    final isValid = await verifyFoodsInFirestore(firestore);
    if (kDebugMode) {
      AppLogger.debug(
        isValid
            ? '✓ Food database re-initialized successfully'
            : '✗ Food database verification failed',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      AppLogger.debug('✗ Error re-initializing food database: $e');
    }
    rethrow;
  }
}
