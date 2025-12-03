class TruthDareSettingsCache {
  static int? playerCount;
  static List<String>? playerNames;

  static int? categoryIndex;
  static int? turnModeIndex;
  static int? scoringModeIndex;
  static int? skipBehaviorIndex;

  static bool? allowSwitch;
  static bool? limitSkips;
  static int? maxSkipsPerPlayer;

  static void save({
    required int playerCount,
    required List<String> playerNames,
    required int categoryIndex,
    required int turnModeIndex,
    required int scoringModeIndex,
    required int skipBehaviorIndex,
    required bool allowSwitch,
    required bool limitSkips,
    required int maxSkipsPerPlayer,
  }) {
    TruthDareSettingsCache.playerCount = playerCount;
    TruthDareSettingsCache.playerNames = List.from(playerNames);

    TruthDareSettingsCache.categoryIndex = categoryIndex;
    TruthDareSettingsCache.turnModeIndex = turnModeIndex;
    TruthDareSettingsCache.scoringModeIndex = scoringModeIndex;
    TruthDareSettingsCache.skipBehaviorIndex = skipBehaviorIndex;

    TruthDareSettingsCache.allowSwitch = allowSwitch;
    TruthDareSettingsCache.limitSkips = limitSkips;
    TruthDareSettingsCache.maxSkipsPerPlayer = maxSkipsPerPlayer;
  }

  static void clear() {
    playerCount = null;
    playerNames = null;
    categoryIndex = null;
    turnModeIndex = null;
    scoringModeIndex = null;
    skipBehaviorIndex = null;
    allowSwitch = null;
    limitSkips = null;
    maxSkipsPerPlayer = null;
  }
}
