import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmailUseCase {
  final AuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }

    // Validate password
    if (password.isEmpty || password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return await _repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
