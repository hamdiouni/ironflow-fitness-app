import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'food_upload_script.dart';

/// Initializes the food database in Firestore.
/// 
/// This function:
/// 1. Checks if foods already exist in Firestore
/// 2. If not, uploads all foods from the local database
/// 3. Verifies the upload was successful
/// 
/// Call this once during app initialization:
/// ```dart
/// await initializeFoodDatabase(FirebaseFirestore.instance);
/// ```
Future<void> initializeFoodDatabase(FirebaseFirestore firestore) async {
  try {
    // Check if foods already exist
    final snapshot = await firestore.collection('foods').limit(1).get();
    
    if (snapshot.docs.isNotEmpty) {
      if (kDebugMode) {
        print('✓ Foods already exist in Firestore, skipping upload');
      }
      return;
    }
    
    // Upload foods
    if (kDebugMode) {
      print('Foods not found in Firestore, uploading...');
    }
    await uploadAllFoodsToFirestore(firestore);
    
    // Verify
    final isValid = await verifyFoodsInFirestore(firestore);
    if (isValid) {
      if (kDebugMode) {
        print('✓ Food database initialized successfully');
      }
    } else {
      if (kDebugMode) {
        print('✗ Food database verification failed');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('✗ Error initializing food database: $e');
    }
    // Don't rethrow - allow app to continue even if upload fails
  }
}

/// Force re-upload all foods to Firestore.
/// 
/// This will delete all existing foods and upload fresh data.
/// Use with caution!
Future<void> reinitializeFoodDatabase(FirebaseFirestore firestore) async {
  try {
    if (kDebugMode) {
      print('Re-initializing food database...');
    }
    
    // Delete existing foods
    await deleteAllFoodsFromFirestore(firestore);
    
    // Upload fresh data
    await uploadAllFoodsToFirestore(firestore);
    
    // Verify
    final isValid = await verifyFoodsInFirestore(firestore);
    if (isValid) {
      if (kDebugMode) {
        print('✓ Food database re-initialized successfully');
      }
    } else {
      if (kDebugMode) {
        print('✗ Food database verification failed');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('✗ Error re-initializing food database: $e');
    }
    rethrow;
  }
}
