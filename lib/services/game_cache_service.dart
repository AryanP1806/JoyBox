import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GameCacheService {
  static final GameCacheService _instance = GameCacheService._internal();
  factory GameCacheService() => _instance;
  GameCacheService._internal();

  final _db = FirebaseFirestore.instance;

  // Key format for SharedPreferences
  String _key(String gameId) => "game_data_$gameId";
  String _versionKey(String gameId) => "game_version_$gameId";

  /// ✅ GET PACKS (Offline First Strategy)
  /// 1. Try Local Cache
  /// 2. If empty, Fetch Remote & Cache
  /// 3. Return data
  Future<Map<String, dynamic>?> getGameData(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedString = prefs.getString(_key(gameId));

    if (cachedString != null && cachedString.isNotEmpty) {
      debugPrint("📦 LOADED LOCAL: $gameId");
      return jsonDecode(cachedString);
    }

    debugPrint("🌐 NO CACHE, FETCHING REMOTE: $gameId");
    return await _fetchAndSave(gameId);
  }

  /// 🔄 BACKGROUND SYNC (Call this in main.dart)
  /// Checks version numbers to see if packs need updating
  Future<void> syncAllGames() async {
    // List all your game IDs here exactly as they are in Firestore
    const games = ['heads_up', 'truth_dare', 'most_likely', 'viral'];

    for (var gameId in games) {
      try {
        await _fetchAndSave(gameId);
      } catch (e) {
        debugPrint("⚠️ SYNC FAILED for $gameId (Offline?)");
      }
    }
  }

  /// 🔽 PRIVATE: Fetch from Firebase -> Save to Prefs
  Future<Map<String, dynamic>?> _fetchAndSave(String gameId) async {
    try {
      // Assuming your Firestore structure is: collection 'games' -> doc 'heads_up'
      final doc = await _db.collection('games').doc(gameId).get();

      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(gameId), jsonEncode(data));

      return data;
    } catch (e) {
      debugPrint("❌ ERROR FETCHING $gameId: $e");
      return null;
    }
  }

  /// 💾 SAVE LAST PLAYED PACK (For "Quick Play" features)
  Future<void> saveLastPack(String gameId, String packId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_pack_$gameId", packId);
  }

  Future<String?> getLastPack(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_pack_$gameId");
  }
}
