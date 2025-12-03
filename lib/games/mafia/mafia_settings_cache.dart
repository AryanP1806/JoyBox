// lib/games/mafia/mafia_settings_cache.dart

class MafiaSettingsCache {
  static int? playerCount;
  static int? mafiaCount;
  static bool? hasDoctor;
  static bool? hasDetective;
  static bool? secretVoting;
  static bool? timerEnabled;
  static int? timerSeconds;
  static List<String>? playerNames;

  static void save({
    required int playerCount,
    required int mafiaCount,
    required bool hasDoctor,
    required bool hasDetective,
    required bool secretVoting,
    required bool timerEnabled,
    required int timerSeconds,
    required List<String> playerNames,
  }) {
    MafiaSettingsCache.playerCount = playerCount;
    MafiaSettingsCache.mafiaCount = mafiaCount;
    MafiaSettingsCache.hasDoctor = hasDoctor;
    MafiaSettingsCache.hasDetective = hasDetective;
    MafiaSettingsCache.secretVoting = secretVoting;
    MafiaSettingsCache.timerEnabled = timerEnabled;
    MafiaSettingsCache.timerSeconds = timerSeconds;
    MafiaSettingsCache.playerNames = List<String>.from(playerNames);
  }
}
