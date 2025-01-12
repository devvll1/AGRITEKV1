import 'package:firebase_auth/firebase_auth.dart';  

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Current user getter
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in method
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user method
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}