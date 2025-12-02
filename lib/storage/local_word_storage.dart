import 'package:shared_preferences/shared_preferences.dart';

class LocalWordStorage {
  static const String _headsUpKey = "HEADS_UP_CUSTOM_WORDS";
  static const String _mrWhiteKey = "MR_WHITE_CUSTOM_WORDS";

  // ✅ IN-MEMORY CACHES (SYNC SAFE)
  static List<String> _headsUpCache = [];
  static List<String> _mrWhiteCache = [];

  // ✅ MUST BE CALLED ON APP START (main.dart)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _headsUpCache = prefs.getStringList(_headsUpKey) ?? [];
    _mrWhiteCache = prefs.getStringList(_mrWhiteKey) ?? [];
  }

  // ---------- HEADS UP ----------
  static List<String> getHeadsUpWords() => List.from(_headsUpCache);

  static Future<void> addHeadsUpWord(String word) async {
    _headsUpCache.add(word);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_headsUpKey, _headsUpCache);
  }

  static Future<void> deleteHeadsUpWord(String word) async {
    _headsUpCache.remove(word);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_headsUpKey, _headsUpCache);
  }

  // ---------- MR WHITE ----------
  static List<String> getMrWhiteWords() => List.from(_mrWhiteCache);

  static Future<void> addMrWhiteWord(String word) async {
    _mrWhiteCache.add(word);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_mrWhiteKey, _mrWhiteCache);
  }

  static Future<void> deleteMrWhiteWord(String word) async {
    _mrWhiteCache.remove(word);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_mrWhiteKey, _mrWhiteCache);
  }
}
