import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

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
    final user = cred.user!;

    await _db.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "email": email,
      "username": username,
      "createdAt": FieldValue.serverTimestamp(),
      "gamesPlayed": 0,
      "wins": 0, // ✅ NEW: Real win counter
      "friendsCount": 0, // ✅ Real friend counter
      "loginDays": 1,
      "lastLoginDate": DateTime.now().toIso8601String().split('T')[0],
      "isPro": false,
      "searchKey": email.toLowerCase(), // ✅ Helper for searching friends
    });
  }

  // ✅ LOGIN
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    try {
      await checkDailyLogin();
    } catch (e) {
      print("Could not check daily login: $e");
    }
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // ✅ SMART STREAK LOGIC (Keep existing)
  Future<void> checkDailyLogin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // ... (Keep your existing Streak Logic here) ...
    // ... I am omitting the middle of this function to save space ...
    // ... Copy your existing checkDailyLogin code here ...
  }

  // ✅ FIXED: STATS UPDATE
  Future<void> updateGameStats({required bool won}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.collection("users").doc(user.uid);

    await ref.update({
      "gamesPlayed": FieldValue.increment(1),
      "wins": won ? FieldValue.increment(1) : FieldValue.increment(0),
      // ❌ REMOVED: friendsCount incrementing on win
    });
  }

  // ✅ HISTORY (Keep existing)
  Future<void> addGameHistory({
    required String gameName,
    required bool won,
    required Map<String, dynamic> details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection("users").doc(user.uid).collection("history").add({
      "game": gameName,
      "won": won,
      "timestamp": FieldValue.serverTimestamp(),
      ...details,
    });
  }

  // ---------------------------------------------------------
  // 👥 NEW FRIEND SYSTEM
  // ---------------------------------------------------------

  // 1. ADD FRIEND BY EMAIL
  Future<String> addFriend(String email) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return "Not logged in";

    final targetEmail = email.trim().toLowerCase();
    if (targetEmail == currentUser.email) return "You can't add yourself!";

    // A. Find the user
    final query = await _db
        .collection("users")
        .where("email", isEqualTo: targetEmail)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return "User not found. Check the email.";
    }

    final friendDoc = query.docs.first;
    final friendData = friendDoc.data();
    final friendId = friendDoc.id;

    // B. Check if already friends
    final existingCheck = await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("friends")
        .doc(friendId)
        .get();

    if (existingCheck.exists) return "You are already friends!";

    // C. Add to My Friend List
    await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("friends")
        .doc(friendId)
        .set({
          "uid": friendId,
          "username": friendData['username'] ?? "Unknown",
          "email": friendData['email'],
          "addedAt": FieldValue.serverTimestamp(),
        });

    // D. Increment My Friend Count
    await _db.collection("users").doc(currentUser.uid).update({
      "friendsCount": FieldValue.increment(1),
    });

    return "Success";
  }

  // 2. GET FRIENDS STREAM
  Stream<QuerySnapshot> getFriendsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection("users")
        .doc(user.uid)
        .collection("friends")
        .orderBy("username")
        .snapshots();
  }

  // 3. REMOVE FRIEND
  Future<void> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection("users")
        .doc(user.uid)
        .collection("friends")
        .doc(friendId)
        .delete();

    await _db.collection("users").doc(user.uid).update({
      "friendsCount": FieldValue.increment(-1),
    });
  }
}
