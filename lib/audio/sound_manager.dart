import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../settings/app_settings.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> _vibrate() async {
    if (!AppSettings.instance.vibrationEnabled) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 40);
    });
  }

  static Future<void> playTap() async {
    if (AppSettings.instance.soundEnabled) {
      await _player.play(AssetSource('sounds/tap.mp3'));
    }
    _vibrate();
  }

  static Future<void> playWin() async {
    if (AppSettings.instance.soundEnabled) {
      await _player.play(AssetSource('sounds/win.mp3'));
    }
    _vibrate();
  }

  static Future<void> playFail() async {
    if (AppSettings.instance.soundEnabled) {
      await _player.play(AssetSource('sounds/fail.mp3'));
    }
    _vibrate();
  }

  static Future<void> playSpin() async {
    if (AppSettings.instance.soundEnabled) {
      await _player.play(AssetSource('sounds/spin.mp3'));
    }
    _vibrate();
  }
}
