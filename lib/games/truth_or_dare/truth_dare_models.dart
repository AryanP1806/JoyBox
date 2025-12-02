import 'dart:math';

/// Which pack/category of questions is used.
enum TruthDareCategory { friends, family, couples, adult, custom }

/// How the next player is chosen.
enum TurnSelectionMode { spinBottle, random }

/// How the game is scored.
enum ScoringMode { points, casual }

/// What happens when a player skips.
enum SkipBehavior {
  penalty, // lose points
  forcedDare, // must do a dare instead
  disabled, // skipping is not allowed
}

/// What the player chose for this turn.
enum TruthOrDareChoice { truth, dare }

/// Single question item.
class TruthDareQuestion {
  final String text;
  final TruthOrDareChoice type;
  final TruthDareCategory category;
  final bool isAdult;

  const TruthDareQuestion({
    required this.text,
    required this.type,
    required this.category,
    this.isAdult = false,
  });
}

/// Player in the game.
class TruthDarePlayer {
  final String name;
  int score;

  TruthDarePlayer({required this.name, this.score = 0});
}

/// Game configuration chosen at setup.
class TruthDareGameConfig {
  final int playerCount;
  final List<String> playerNames;
  final TruthDareCategory category;
  final TurnSelectionMode turnSelectionMode;
  final ScoringMode scoringMode;
  final SkipBehavior skipBehavior;
  final bool allowSwitchAfterQuestion; // truth <-> dare
  final bool limitSkips; // optional anti-boring
  final int maxSkipsPerPlayer; // used only if limitSkips == true

  TruthDareGameConfig({
    required this.playerCount,
    required this.playerNames,
    required this.category,
    required this.turnSelectionMode,
    required this.scoringMode,
    required this.skipBehavior,
    required this.allowSwitchAfterQuestion,
    required this.limitSkips,
    this.maxSkipsPerPlayer = 2,
  }) : assert(playerNames.length == playerCount);
}

/// Runtime state of the game.
class TruthDareGameState {
  final TruthDareGameConfig config;
  final List<TruthDarePlayer> players;
  final Map<int, int> _skipsPerPlayer = {};
  final Random _rand = Random();

  int currentPlayerIndex = 0;

  TruthDareGameState({required this.config})
    : players = List.generate(
        config.playerCount,
        (i) => TruthDarePlayer(
          name: config.playerNames[i].isEmpty
              ? 'Player ${i + 1}'
              : config.playerNames[i],
        ),
      );

  TruthDarePlayer get currentPlayer => players[currentPlayerIndex];

  int getSkipsFor(int playerIndex) => _skipsPerPlayer[playerIndex] ?? 0;

  void _incSkip(int playerIndex) {
    _skipsPerPlayer[playerIndex] = getSkipsFor(playerIndex) + 1;
  }

  bool canSkipCurrentPlayer() {
    if (config.skipBehavior == SkipBehavior.disabled) return false;
    if (!config.limitSkips) return true;
    return getSkipsFor(currentPlayerIndex) < config.maxSkipsPerPlayer;
  }

  /// Apply scoring based on what the player actually did.
  void applyResult({
    required TruthOrDareChoice finalChoice,
    required bool completed,
    required bool skipped,
  }) {
    if (config.scoringMode == ScoringMode.casual) {
      // No points in casual mode.
      return;
    }

    final player = currentPlayer;

    if (skipped) {
      // Player pressed skip.
      switch (config.skipBehavior) {
        case SkipBehavior.penalty:
          player.score -= 1;
          _incSkip(currentPlayerIndex);
          break;
        case SkipBehavior.forcedDare:
          // In real flow, you should not call applyResult with skipped=true
          // after forced dare; but if you do, we treat as no score change here.
          _incSkip(currentPlayerIndex);
          break;
        case SkipBehavior.disabled:
          // Should not be possible if you block skip in UI.
          break;
      }
    } else if (completed) {
      // Player actually completed truth/dare.
      if (finalChoice == TruthOrDareChoice.truth) {
        player.score += 1;
      } else {
        player.score += 2;
      }
    }
  }

  /// Move to next player based on selection mode.
  void moveToNextPlayer() {
    if (config.turnSelectionMode == TurnSelectionMode.random) {
      currentPlayerIndex = _rand.nextInt(players.length);
    } else {
      // Spin bottle mode or simple round-robin.
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }
  }
}
