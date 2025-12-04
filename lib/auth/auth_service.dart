import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // ✅ REGISTER
  Future<void> register(
    String email,
    String password, {
    required String username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ✅ AUTO CREATE USER PROFILE IN FIRESTORE
    await _db.collection("users").doc(cred.user!.uid).set({
      "uid": cred.user!.uid,
      "email": email,
      "username": username,
      "games": 0,
      "wins": 0,
      "streak": 0,
      "pro": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // ✅ LOGIN
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ✅ SESSION PERSISTENCE
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
