/// Interface for purging remote user data in cloud storage/database.
///
/// Ensures compliance with store policies (Apple Guideline 5.1.1(v) and Google Play User Data).
/// Sync-ready for Release 1.3: Today purges whatever remote data exists for [userId].
abstract class RemoteDataPurger {
  /// Purges all user-associated records stored in remote cloud backends (e.g., Firestore, Storage).
  ///
  /// Throws an exception if remote communication fails or the user is offline,
  /// preventing destructive local state deletion without remote purge completion.
  Future<void> purgeRemoteUserData(String userId);
}
