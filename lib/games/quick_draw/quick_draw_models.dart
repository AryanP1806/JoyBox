enum QuickDrawMode {
  classic, // Standard "Wait for Green"
  chaos, // Fake-outs, distractions, weird timings
}

enum QuickDrawState {
  idle, // "Tap to Start"
  waiting, // Random timer running (Tension)
  triggered, // GO! (Green screen)
  early, // You failed (Red screen)
  won, // Success (Show time)
}

class QuickDrawConfig {
  final QuickDrawMode mode;
  final int totalRounds;

  QuickDrawConfig({required this.mode, required this.totalRounds});
}
