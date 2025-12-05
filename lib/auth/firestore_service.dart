import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ✅ CREATE USER DOCUMENT AFTER REGISTER
  Future<void> createUser(AppUser user) async {
    await _db.collection("users").doc(user.uid).set(user.toMap());
  }

  // ✅ GET USER DATA
  Future<AppUser> getUser(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    return AppUser.fromMap(uid, doc.data()!);
  }

  // ✅ UPDATE STATS
  Future<void> updateStats({
    required String uid,
    required int games,
    required int wins,
    required int streak,
  }) async {
    await _db.collection("users").doc(uid).update({
      "games": games,
      "wins": wins,
      "streak": streak,
    });
  }

  // ✅ PRO UPGRADE
  Future<void> upgradeToPro(String uid) async {
    await _db.collection("users").doc(uid).update({"isPro": true});
  }

  // ADD THIS TO FirestoreService class
  Future<void> saveGameResult({
    required String uid,
    required String gameTitle,
    required bool won,
    required int currentStreak,
  }) async {
    // 1. Add to History Subcollection
    await _db.collection("users").doc(uid).collection("history").add({
      "game": gameTitle,
      "won": won,
      "streak": currentStreak,
      "timestamp": FieldValue.serverTimestamp(), // Crucial for sorting
    });

    // 2. Update Aggregate Stats (Total games, wins, etc.)
    final userRef = _db.collection("users").doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      int games = (data['gamesPlayed'] ?? 0) + 1;
      int wins = (data['wins'] ?? 0) + (won ? 1 : 0);

      transaction.update(userRef, {
        "gamesPlayed": games,
        "wins": wins,
        "streak": currentStreak, // Update current streak on profile
      });
    });
  }
}
