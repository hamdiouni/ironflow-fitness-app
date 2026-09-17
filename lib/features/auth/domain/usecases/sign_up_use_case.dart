import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return repository.signUpWithEmail(
      email: email,
      password: password,
    );
  }
}
