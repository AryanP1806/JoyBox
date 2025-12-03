import 'mr_white_models.dart';

class MrWhiteSettingsCache {
  static int? playerCount;
  static int? specialCount;
  static MrWhiteMode? mode;

  static bool? useCustomWords;
  static bool? timerEnabled;
  static int? timerSeconds;
  static bool? secretVoting;

  static List<String>? playerNames;

  static void save({
    required int playerCount,
    required int specialCount,
    required MrWhiteMode mode,
    required bool useCustomWords,
    required bool timerEnabled,
    required int timerSeconds,
    required bool secretVoting,
    required List<String> playerNames,
  }) {
    MrWhiteSettingsCache.playerCount = playerCount;
    MrWhiteSettingsCache.specialCount = specialCount;
    MrWhiteSettingsCache.mode = mode;
    MrWhiteSettingsCache.useCustomWords = useCustomWords;
    MrWhiteSettingsCache.timerEnabled = timerEnabled;
    MrWhiteSettingsCache.timerSeconds = timerSeconds;
    MrWhiteSettingsCache.secretVoting = secretVoting;
    MrWhiteSettingsCache.playerNames = List.from(playerNames);
  }

  static void clear() {
    playerCount = null;
    specialCount = null;
    mode = null;
    useCustomWords = null;
    timerEnabled = null;
    timerSeconds = null;
    secretVoting = null;
    playerNames = null;
  }
}
