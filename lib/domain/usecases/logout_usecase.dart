import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User?> call(String email, String password) {
    return repository.login(email, password);
  }
}
