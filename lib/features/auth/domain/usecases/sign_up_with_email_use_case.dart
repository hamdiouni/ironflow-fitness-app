import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpWithEmailUseCase {
  final AuthRepository _repository;

  SignUpWithEmailUseCase(this._repository);

  Future<User> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }

    // Validate password
    if (password.isEmpty || password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Validate password confirmation
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    return await _repository.signUpWithEmail(
      email: email,
      password: password,
    );
  }
}
