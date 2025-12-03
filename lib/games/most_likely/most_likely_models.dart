// lib/games/most_likely/most_likely_models.dart
import '../../settings/app_settings.dart';

/// Question packs for "Who's Most Likely To"
enum MostLikelyPack { clean, savage, adult, smart, stupidFun }

extension MostLikelyPackX on MostLikelyPack {
  String get label {
    switch (this) {
      case MostLikelyPack.clean:
        return "😇 Clean";
      case MostLikelyPack.savage:
        return "🔥 Savage";
      case MostLikelyPack.adult:
        return "🔞 Adult";
      case MostLikelyPack.smart:
        return "🧠 Smart";
      case MostLikelyPack.stupidFun:
        return "🐒 Stupid Fun";
    }
  }

  bool get isAdult => this == MostLikelyPack.adult;
}

/// How players vote
enum MostLikelyVotingMode {
  phonePass, // one phone, each taps secretly
  groupPointing, // players point, one person taps result
}

/// How scores are handled
enum MostLikelyScoringMode {
  none, // no score, pure chaos
  winnerGetsPoint, // most-voted player +1
  loserGetsPoint, // most-voted player gets a "shame" point
}

/// What happens to the chosen player
enum MostLikelyPunishmentMode { none, truth, dare, drink, custom }

/// How/when the game ends
enum MostLikelyEndCondition {
  manualStop, // until user presses STOP
  fixedRounds, // stop after N rounds
}

/// Single player in the game
class MostLikelyPlayer {
  final String name;
  int score;

  MostLikelyPlayer({required this.name, this.score = 0});
}

/// Full game configuration passed from setup → game
class MostLikelyGameConfig {
  final List<String> playerNames;
  final List<MostLikelyPack> packs;

  final MostLikelyVotingMode votingMode;
  final MostLikelyScoringMode scoringMode;
  final MostLikelyPunishmentMode punishmentMode;

  /// If false, UI must block voting for self.
  final bool allowSelfVote;

  /// End condition
  final MostLikelyEndCondition endCondition;
  final int? totalRounds; // used only when endCondition == fixedRounds

  MostLikelyGameConfig({
    required this.playerNames,
    required this.packs,
    required this.votingMode,
    required this.scoringMode,
    required this.punishmentMode,
    required this.allowSelfVote,
    required this.endCondition,
    this.totalRounds,
  }) : assert(
         endCondition == MostLikelyEndCondition.manualStop ||
             (endCondition == MostLikelyEndCondition.fixedRounds &&
                 (totalRounds ?? 0) > 0),
         "If using fixedRounds, totalRounds must be > 0",
       );

  int get playerCount => playerNames.length;

  /// Safety helper: filter out adult packs if settings disabled.
  /// Use this before actually starting the game.
  List<MostLikelyPack> get effectivePacks {
    final adultEnabled = AppSettings.instance.adultEnabled;
    if (adultEnabled) return packs;

    return packs.where((p) => !p.isAdult).toList();
  }

  bool get usesAdultContent =>
      packs.any((p) => p.isAdult) && AppSettings.instance.adultEnabled;
}
