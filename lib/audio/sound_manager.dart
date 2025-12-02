import 'package:audioplayers/audioplayers.dart';
import '../settings/app_settings.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playTap() async {
    if (!AppSettings.instance.soundEnabled) return;
    await _player.play(AssetSource('sounds/tap.mp3'));
  }

  static Future<void> playWin() async {
    if (!AppSettings.instance.soundEnabled) return;
    await _player.play(AssetSource('sounds/win.mp3'));
  }

  static Future<void> playFail() async {
    if (!AppSettings.instance.soundEnabled) return;
    await _player.play(AssetSource('sounds/fail.mp3'));
  }

  static Future<void> playSpin() async {
    if (!AppSettings.instance.soundEnabled) return;
    await _player.play(AssetSource('sounds/spin.mp3'));
  }
}
