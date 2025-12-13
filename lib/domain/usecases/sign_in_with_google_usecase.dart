import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<UserCredential> call() {
    return _repository.signInWithGoogle();
  }
}
