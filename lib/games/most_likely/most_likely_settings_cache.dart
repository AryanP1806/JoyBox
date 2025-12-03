// lib/games/most_likely/most_likely_settings_cache.dart
import 'most_likely_models.dart';

/// Simple in-memory cache so that after a game
/// the setup screen is pre-filled with last used settings.
///
/// We are NOT using SharedPreferences here,
/// same as your other games.
class MostLikelySettingsCache {
  static int? playerCount;
  static List<String>? playerNames;

  static List<int>? selectedPackIndexes;

  static int? votingModeIndex;
  static int? scoringModeIndex;
  static int? punishmentModeIndex;

  static bool? allowSelfVote;

  static MostLikelyEndCondition? endCondition;
  static int? totalRounds;

  static void save({
    required int playerCountValue,
    required List<String> playerNamesValue,
    required List<MostLikelyPack> packs,
    required MostLikelyVotingMode votingMode,
    required MostLikelyScoringMode scoringMode,
    required MostLikelyPunishmentMode punishmentMode,
    required bool allowSelfVoteValue,
    required MostLikelyEndCondition endConditionValue,
    int? totalRoundsValue,
  }) {
    playerCount = playerCountValue;
    playerNames = List<String>.from(playerNamesValue);

    selectedPackIndexes = packs.map((p) => p.index).toList();

    votingModeIndex = votingMode.index;
    scoringModeIndex = scoringMode.index;
    punishmentModeIndex = punishmentMode.index;

    allowSelfVote = allowSelfVoteValue;

    endCondition = endConditionValue;
    totalRounds = totalRoundsValue;
  }

  /// Recover selected packs from cached indexes.
  static List<MostLikelyPack> getCachedPacks() {
    if (selectedPackIndexes == null) return [];
    return selectedPackIndexes!
        .where((i) => i >= 0 && i < MostLikelyPack.values.length)
        .map((i) => MostLikelyPack.values[i])
        .toList();
  }
}
