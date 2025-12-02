import 'package:shared_preferences/shared_preferences.dart';

class TruthDareLocalStorage {
  static const _truthKey = "custom_truth_words";
  static const _dareKey = "custom_dare_words";

  static Future<List<String>> getTruths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_truthKey) ?? [];
  }

  static Future<List<String>> getDares() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dareKey) ?? [];
  }

  static Future<void> addTruth(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_truthKey) ?? [];
    list.add(word);
    await prefs.setStringList(_truthKey, list);
  }

  static Future<void> addDare(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dareKey) ?? [];
    list.add(word);
    await prefs.setStringList(_dareKey, list);
  }

  static Future<void> deleteTruth(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_truthKey) ?? [];
    list.removeAt(index);
    await prefs.setStringList(_truthKey, list);
  }

  static Future<void> deleteDare(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dareKey) ?? [];
    list.removeAt(index);
    await prefs.setStringList(_dareKey, list);
  }
}
