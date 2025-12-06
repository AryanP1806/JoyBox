import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final user = cred.user!;

    await _db.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "email": email,
      "username": username,
      // Helper for case-insensitive search
      "searchKey": username.toLowerCase(),
      "createdAt": FieldValue.serverTimestamp(),
      "gamesPlayed": 0,
      "wins": 0,
      "friendsCount": 0,
      "loginDays": 1,
      "lastLoginDate": DateTime.now().toIso8601String().split('T')[0],
      "isPro": false,
    });
  }

  // ✅ LOGIN & LOGOUT
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    try {
      await checkDailyLogin();
    } catch (_) {}
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ✅ SEARCH USERS (By Username or Email)
  // final _auth = FirebaseAuth.instance;
  // final _db = FirebaseFirestore.instance;

  // User? get currentUser => _auth.currentUser;

  // ... (Keep register, login, logout, checkDailyLogin exactly as they were) ...
  // [PASTE YOUR EXISTING REGISTER/LOGIN CODE HERE]

  // ✅ SEARCH USERS
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final myUid = currentUser?.uid;
    if (myUid == null || query.isEmpty) return [];

    try {
      final lowerQuery = query.toLowerCase();

      // 1. Try email
      final emailQuery = await _db
          .collection("users")
          .where("email", isEqualTo: lowerQuery)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return emailQuery.docs
            .where((doc) => doc.id != myUid)
            .map((doc) => doc.data())
            .toList();
      }

      // 2. Try Username
      final usernameQuery = await _db
          .collection("users")
          .where("searchKey", isGreaterThanOrEqualTo: lowerQuery)
          .where("searchKey", isLessThan: "${lowerQuery}z")
          .limit(10)
          .get();

      return usernameQuery.docs
          .where((doc) => doc.id != myUid)
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print("SEARCH ERROR: $e"); // Debug print
      return [];
    }
  }

  // ✅ SEND REQUEST
  Future<String> sendFriendRequest(String targetUid) async {
    final user = currentUser;
    if (user == null) return "Not logged in";

    try {
      // Check existing friendship
      final friendDoc = await _db
          .collection("users")
          .doc(user.uid)
          .collection("friends")
          .doc(targetUid)
          .get();

      if (friendDoc.exists) return "Already friends!";

      // Check pending request
      final reqDoc = await _db
          .collection("users")
          .doc(targetUid)
          .collection("friend_requests")
          .doc(user.uid)
          .get();

      if (reqDoc.exists) return "Request already sent!";

      final myProfile = await _db.collection("users").doc(user.uid).get();
      final myData = myProfile.data()!;

      // Send Request
      await _db
          .collection("users")
          .doc(targetUid)
          .collection("friend_requests")
          .doc(user.uid)
          .set({
            "uid": user.uid,
            "username": myData['username'],
            "email": myData['email'],
            "timestamp": FieldValue.serverTimestamp(),
          });

      return "Request Sent!";
    } catch (e) {
      print("SEND REQ ERROR: $e");
      return "Error sending request";
    }
  }

  // ✅ REMOVE FRIEND (Fixed with Batch)
  Future<bool> removeFriend(String friendUid) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      WriteBatch batch = _db.batch();

      DocumentReference myRef = _db.collection("users").doc(user.uid);
      DocumentReference theirRef = _db.collection("users").doc(friendUid);

      // 1. Remove from MY friends
      batch.delete(myRef.collection("friends").doc(friendUid));

      // 2. Remove from THEIR friends
      batch.delete(theirRef.collection("friends").doc(user.uid));

      // 3. Decrement MY count
      batch.update(myRef, {"friendsCount": FieldValue.increment(-1)});

      // 4. Decrement THEIR count
      batch.update(theirRef, {"friendsCount": FieldValue.increment(-1)});

      await batch.commit();
      return true;
    } catch (e) {
      print("REMOVE FRIEND ERROR: $e");
      return false;
    }
  }

  // ✅ ACCEPT REQUEST (Keep Transaction)
  Future<void> acceptFriendRequest(
    String requesterUid,
    String requesterName,
    String requesterEmail,
  ) async {
    final user = currentUser;
    if (user == null) return;

    try {
      final myRef = _db.collection("users").doc(user.uid);
      final theirRef = _db.collection("users").doc(requesterUid);

      final myProfile = await myRef.get();
      final myName = myProfile.data()?['username'] ?? "Unknown";
      final myEmail = myProfile.data()?['email'] ?? "";

      await _db.runTransaction((tx) async {
        // Add to My Friends
        tx.set(myRef.collection("friends").doc(requesterUid), {
          "uid": requesterUid,
          "username": requesterName,
          "email": requesterEmail,
          "since": FieldValue.serverTimestamp(),
        });

        // Add to Their Friends
        tx.set(theirRef.collection("friends").doc(user.uid), {
          "uid": user.uid,
          "username": myName,
          "email": myEmail,
          "since": FieldValue.serverTimestamp(),
        });

        // Delete Request
        tx.delete(myRef.collection("friend_requests").doc(requesterUid));

        // Increment Counts
        tx.update(myRef, {"friendsCount": FieldValue.increment(1)});
        tx.update(theirRef, {"friendsCount": FieldValue.increment(1)});
      });
    } catch (e) {
      print("ACCEPT ERROR: $e");
    }
  }

  Future<void> rejectFriendRequest(String requesterUid) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await _db
          .collection("users")
          .doc(user.uid)
          .collection("friend_requests")
          .doc(requesterUid)
          .delete();
    } catch (e) {
      print("REJECT ERROR: $e");
    }
  }

  // ... (Streams and other methods remain the same) ...
  Stream<QuerySnapshot> getFriendsStream() {
    return _db
        .collection("users")
        .doc(currentUser?.uid)
        .collection("friends")
        .snapshots();
  }

  Stream<QuerySnapshot> getRequestsStream() {
    return _db
        .collection("users")
        .doc(currentUser?.uid)
        .collection("friend_requests")
        .snapshots();
  }

  // ... (Keep your existing checkDailyLogin, updateGameStats, addGameHistory functions exactly as they were) ...
  // ✅ SMART STREAK LOGIC
  Future<void> checkDailyLogin() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _db.collection("users").doc(user.uid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = today.toIso8601String().split('T')[0];

    final prefs = await SharedPreferences.getInstance();
    final lastLocal = prefs.getString('last_login_date');

    if (lastLocal == todayStr) return;

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      String lastDbDateStr = data['lastLoginDate'] ?? "";
      int currentStreak = data['loginDays'] ?? 0;
      int newStreak = 1;

      if (lastDbDateStr.isEmpty) {
        newStreak = 1;
      } else {
        try {
          DateTime lastDate = DateTime.parse(lastDbDateStr);
          DateTime lastDateMidnight = DateTime(
            lastDate.year,
            lastDate.month,
            lastDate.day,
          );
          int difference = today.difference(lastDateMidnight).inDays;

          if (difference == 0)
            return;
          else if (difference == 1)
            newStreak = currentStreak + 1;
          else
            newStreak = 1;
        } catch (e) {
          newStreak = 1;
        }
      }

      tx.update(userRef, {'loginDays': newStreak, 'lastLoginDate': todayStr});
      await prefs.setString('last_login_date', todayStr);
    });
  }

  Future<void> updateGameStats({required bool won}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _db.collection("users").doc(user.uid);
    await ref.update({
      "gamesPlayed": FieldValue.increment(1),
      "wins": won ? FieldValue.increment(1) : FieldValue.increment(0),
    });
  }

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
}
