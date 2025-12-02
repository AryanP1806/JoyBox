class GameReset {
  static void resetTruthDare(List players) {
    for (var p in players) {
      p.score = 0;
      p.skips = 0;
    }
  }

  static void resetMafia(List players) {
    for (var p in players) {
      p.isAlive = true;
      p.role = null;
    }
  }

  static void resetMrWhite(List players) {
    for (var p in players) {
      p.isAlive = true;
      p.word = null;
    }
  }

  static void resetHeadsUp() {
    // No persistent state needed
  }
}
