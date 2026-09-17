import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

/// Local session storage using Hive
/// Stores user session data for persistence across app restarts
class AuthSessionStorage {
  static const String _boxName = 'auth_session';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';
  static const String _displayNameKey = 'display_name';
  static const String _photoUrlKey = 'photo_url';
  static const String _createdAtKey = 'created_at';
  static const String _updatedAtKey = 'updated_at';
  static const String _isLoggedInKey = 'is_logged_in';

  Box<dynamic> get _box => Hive.box(_boxName);

  /// Save user session
  Future<void> saveSession(User user) async {
    print('📊 [AuthSession] Saving user session...');
    print('🔍 [AuthSession] User ID: ${user.id.substring(0, 8)}...');
    
    await _box.put(_userIdKey, user.id);
    await _box.put(_emailKey, user.email);
    await _box.put(_displayNameKey, user.displayName);
    await _box.put(_photoUrlKey, user.photoUrl);
    await _box.put(_createdAtKey, user.createdAt.toIso8601String());
    await _box.put(_updatedAtKey, user.updatedAt.toIso8601String());
    await _box.put(_isLoggedInKey, true);
    
    print('✅ [AuthSession] Session saved successfully');
  }

  /// Load user session
  Future<User?> loadSession() async {
    print('📊 [AuthSession] Loading user session...');
    
    final isLoggedIn = _box.get(_isLoggedInKey, defaultValue: false) as bool;
    
    if (!isLoggedIn) {
      print('⚠️ [AuthSession] No active session found');
      return null;
    }

    final userId = _box.get(_userIdKey) as String?;
    final email = _box.get(_emailKey) as String?;
    
    if (userId == null || email == null) {
      print('⚠️ [AuthSession] Incomplete session data');
      return null;
    }

    final displayName = _box.get(_displayNameKey) as String?;
    final photoUrl = _box.get(_photoUrlKey) as String?;
    final createdAtStr = _box.get(_createdAtKey) as String?;
    final updatedAtStr = _box.get(_updatedAtKey) as String?;

    final user = User(
      id: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAtStr != null 
          ? DateTime.parse(createdAtStr) 
          : DateTime.now(),
      updatedAt: updatedAtStr != null 
          ? DateTime.parse(updatedAtStr) 
          : DateTime.now(),
    );

    print('✅ [AuthSession] Session loaded successfully');
    print('🔍 [AuthSession] User ID: ${userId.substring(0, 8)}...');
    
    return user;
  }

  /// Clear user session
  Future<void> clearSession() async {
    print('📊 [AuthSession] Clearing user session...');
    
    await _box.clear();
    
    print('✅ [AuthSession] Session cleared successfully');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final isLoggedIn = _box.get(_isLoggedInKey, defaultValue: false) as bool;
    print('📊 [AuthSession] Checking login status: $isLoggedIn');
    return isLoggedIn;
  }

  /// Get stored user ID
  String? getUserId() {
    return _box.get(_userIdKey) as String?;
  }
}
