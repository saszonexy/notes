import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream untuk memantau perubahan login
  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(
          (user) => user != null ? AppUser.fromFirebaseUser(user) : null,
        );
  }

  /// Registrasi
  Future<AppUser?> signUp(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user);
  }

  /// Login
  Future<AppUser?> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user);
  }

  /// Logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
