// lib/core/game_session.dart

/// Which game is currently running.
enum GameType { truthDare, mafia, mrWhite, headsUp }

/// Holds the state for a single running game session.
/// This is intentionally simple and uses `Object` so it doesn't depend
/// on your specific model classes.
class GameSession {
  final GameType type;

  /// The config object for the game (TruthDareGameConfig, MafiaGameConfig, etc.).
  final Object config;

  /// Current players list (TruthDarePlayer, MafiaPlayer, etc.).
  final List<Object> players;

  /// Round number (if your game has rounds).
  int round;

  /// Extra per-game data you might want to stash (optional).
  final Map<String, Object?> extras;

  GameSession({
    required this.type,
    required this.config,
    required this.players,
    this.round = 1,
    Map<String, Object?>? extras,
  }) : extras = extras ?? {};
}

/// Global store for the active game session.
/// Single point of truth for:
/// - which game is active
/// - config
/// - players
/// - round
/// - extras
class GameSessionStore {
  static GameSession? _current;

  /// Is there any active game at all?
  static bool get hasActive => _current != null;

  /// What game is active (truthDare / mafia / mrWhite / headsUp)?
  static GameType? get currentType => _current?.type;

  /// Current round (defaults to 1 if no game).
  static int get round => _current?.round ?? 1;

  /// Start / replace the active session.
  /// You pass your config + players as `Object`/`List<Object>`.
  static void start({
    required GameType type,
    required Object config,
    required List<Object> players,
    Map<String, Object?>? extras,
  }) {
    _current = GameSession(
      type: type,
      config: config,
      players: List<Object>.from(players),
      round: 1,
      extras: extras,
    );
  }

  /// Clear the active session completely (e.g. when exiting to home).
  static void clear() {
    _current = null;
  }

  /// Get config casted to your real type.
  ///
  /// Example:
  ///   final cfg = GameSessionStore.config<TruthDareGameConfig>();
  static T? config<T>() {
    final c = _current?.config;
    if (c is T) return c;
    return null;
  }

  /// Get players casted to your real player type.
  ///
  /// Example:
  ///   final players = GameSessionStore.players<TruthDarePlayer>();
  static List<T> players<T>() {
    final list = _current?.players ?? const <Object>[];
    return list.cast<T>();
  }

  /// Replace the players list (e.g. after kills, score updates, etc.).
  static void updatePlayers<T>(List<T> updated) {
    final cur = _current;
    if (cur == null) return;

    _current = GameSession(
      type: cur.type,
      config: cur.config,
      players: List<Object>.from(updated),
      round: cur.round,
      extras: Map<String, Object?>.from(cur.extras),
    );
  }

  /// Increment round counter.
  static void nextRound() {
    final cur = _current;
    if (cur == null) return;
    cur.round += 1;
  }

  /// Read/write extra data in a safe-ish way.
  ///
  /// Example:
  ///   GameSessionStore.setExtra('mrWhiteTotalRounds', 3);
  ///   final rounds = GameSessionStore.getExtra<int>('mrWhiteTotalRounds');
  static void setExtra(String key, Object? value) {
    final cur = _current;
    if (cur == null) return;
    cur.extras[key] = value;
  }

  static T? getExtra<T>(String key) {
    final cur = _current;
    if (cur == null) return null;
    final v = cur.extras[key];
    if (v is T) return v;
    return null;
  }
}
