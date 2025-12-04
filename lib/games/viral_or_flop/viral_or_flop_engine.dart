import 'dart:math';
// Import the single source of truth for your models
import 'viral_or_flop_models.dart';
// Import your database file (I am assuming you named the DB file viral_or_flop_data.dart)
import 'viral_or_flop_static_db.dart';

class ViralOrFlopEngine {
  static List<ViralMediaItem> getRandomPair({
    required MediaCategory forceCategory,
    required bool includeFake,
    required ViralPlayMode playMode, // ✅ ADDED: Needed to know the target
  }) {
    // 1. Determine what the user is LOOKING for (The Correct Answer)
    // If mode is ViralOnly, we want items where isViral == true
    bool targetIsViral = (playMode == ViralPlayMode.viralOnly);

    // 2. Get the Correct Option (Must be REAL and match the target)
    final correctPool = staticViralFlopDatabase.where((item) {
      return item.category == forceCategory &&
          !item.isFake &&
          item.isViral == targetIsViral;
    }).toList();

    // 3. Get the Wrong Option
    List<ViralMediaItem> wrongPool = [];

    if (includeFake) {
      // ✅ LOGIC CHANGE: If Fake is enabled, the "Wrong" option is ALWAYS a Fake.
      // It replaces the standard "Wrong" option.
      wrongPool = staticViralFlopDatabase.where((item) {
        return item.category == forceCategory && item.isFake;
      }).toList();
    }

    // Fallback: If Fake is disabled OR if we ran out of fakes,
    // use the standard "Real Opposite" as the wrong answer.
    if (wrongPool.isEmpty) {
      wrongPool = staticViralFlopDatabase.where((item) {
        return item.category == forceCategory &&
            !item.isFake &&
            item.isViral != targetIsViral; // The opposite of target
      }).toList();
    }

    // Safety Check
    if (correctPool.isEmpty || wrongPool.isEmpty) return [];

    final random = Random();

    // 4. Pick one from each pool
    final correctItem = correctPool[random.nextInt(correctPool.length)];
    final wrongItem = wrongPool[random.nextInt(wrongPool.length)];

    // 5. Shuffle positions (Left vs Right)
    if (random.nextBool()) {
      return [correctItem, wrongItem];
    } else {
      return [wrongItem, correctItem];
    }
  }
}
