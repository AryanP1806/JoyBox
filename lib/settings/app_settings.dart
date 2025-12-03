import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._internal();
  AppSettings._internal();

  bool soundEnabled = true;
  bool vibrationEnabled = true;

  // ✅ ADD THIS
  bool adultEnabled = false;

  void toggleSound() {
    soundEnabled = !soundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    vibrationEnabled = !vibrationEnabled;
    notifyListeners();
  }

  // ✅ ADD THIS
  void toggleAdultMode() {
    adultEnabled = !adultEnabled;
    notifyListeners();
  }
}
