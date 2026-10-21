import 'package:cloud_firestore/cloud_firestore.dart';

/// Canonical Firestore layout for user-owned data.
///
/// User data lives below `/users/{uid}` so the path itself can be checked by
/// Firestore security rules. Public reference catalogs (foods and exercises)
/// remain top-level collections.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String workouts = 'workouts';
  static const String programs = 'programs';
  static const String nutrition = 'nutrition';
  static const String bodyProgress = 'body_progress';
  static const String profile = 'profile';
  static const String syncMetadata = 'sync_metadata';
  static const String foods = 'foods';
  static const String exercises = 'exercises';

  static String userCollectionPath(String userId, String collection) {
    _validateSegment(userId, 'userId');
    _validateSegment(collection, 'collection');
    return '$users/$userId/$collection';
  }

  static String userDocumentPath(
    String userId,
    String collection,
    String documentId,
  ) {
    _validateSegment(documentId, 'documentId');
    return '${userCollectionPath(userId, collection)}/$documentId';
  }

  static CollectionReference<Map<String, dynamic>> userCollection(
    FirebaseFirestore firestore,
    String userId,
    String collection,
  ) =>
      firestore.collection(userCollectionPath(userId, collection));

  static DocumentReference<Map<String, dynamic>> userDocument(
    FirebaseFirestore firestore,
    String userId,
    String collection,
    String documentId,
  ) {
    _validateSegment(documentId, 'documentId');
    return userCollection(firestore, userId, collection).doc(documentId);
  }

  static void _validateSegment(String value, String name) {
    if (value.trim().isEmpty || value.contains('/')) {
      throw ArgumentError.value(
        value,
        name,
        'must be a non-empty Firestore path segment',
      );
    }
  }
}
