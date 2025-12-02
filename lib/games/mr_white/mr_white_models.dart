enum MrWhiteMode { mrWhite, undercover }

class MrWhitePlayer {
  final String name;
  String role; // "civilian", "mrwhite", "undercover"
  bool isAlive;
  int score;
  String? word;

  MrWhitePlayer({
    required this.name,
    required this.role,
    this.isAlive = true,
    this.score = 0,
    this.word,
  });
}

class MrWhiteGameConfig {
  // ✅ OLD FIELDS (FOR EXISTING SCREENS TO WORK)
  final int playerCount;
  final MrWhiteMode mode;
  final int specialCount;
  final bool useCustomWords;
  final List<String> playerNames;

  // ✅ NEW SAFE FIELDS (CUSTOM WORD SUPPORT)
  final List<String> customWords;

  // ✅ EXTRA SETTINGS
  final bool timerEnabled;
  final int timerSeconds;
  final bool secretVoting;

  MrWhiteGameConfig({
    required this.playerCount,
    required this.mode,
    required this.specialCount,
    required this.useCustomWords,
    required this.playerNames,
    required this.customWords,
    required this.timerEnabled,
    required this.timerSeconds,
    required this.secretVoting,
  });
}
