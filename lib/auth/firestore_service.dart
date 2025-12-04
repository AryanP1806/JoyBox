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
}
