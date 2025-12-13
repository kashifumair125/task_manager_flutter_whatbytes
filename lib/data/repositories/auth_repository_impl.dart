import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  FirebaseAuth? _authInstance;
  
  FirebaseAuth get _auth {
    // Ensure Firebase is initialized before accessing FirebaseAuth
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase has not been initialized. Call Firebase.initializeApp() first.');
    }
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }

  @override
  Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Login failed: Invalid credentials');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
