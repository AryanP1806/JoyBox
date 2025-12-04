import 'dart:math';
import 'viral_models.dart';
import 'viral_static_db.dart';

final Random _rng = Random();

class ViralEngine {
  /// Returns a list of exactly 2 items [Left, Right]
  static List<ViralMediaItem> getRandomPair({
    bool includeFake = false,
    required MediaCategory forceCategory,
  }) {
    // 1. Separate database into Real and Fake pools based on Category
    List<ViralMediaItem> realPool = staticViralDatabase
        .where((item) => item.category == forceCategory && !item.isFake)
        .toList();

    List<ViralMediaItem> fakePool = staticViralDatabase
        .where((item) => item.category == forceCategory && item.isFake)
        .toList();

    // Safety Check: Ensure we have enough real data to play
    if (realPool.length < 2) {
      return _getDummyErrorData();
    }

    // 2. Determine if this is a "Trap Round" (1 in 10 chance)
    // defined by: Fakes are enabled AND the RNG rolls a 0 AND we actually have fakes.
    bool triggerTrapRound =
        includeFake && fakePool.isNotEmpty && (_rng.nextInt(10) == 0);

    ViralMediaItem item1;
    ViralMediaItem item2;

    if (triggerTrapRound) {
      // --- TRAP ROUND LOGIC (1 Real vs 1 Fake) ---

      // Pick one random real item
      item1 = realPool[_rng.nextInt(realPool.length)];

      // Pick one random fake item
      item2 = fakePool[_rng.nextInt(fakePool.length)];
    } else {
      // --- NORMAL ROUND LOGIC (Real vs Real) ---

      // Shuffle real pool to get random items
      realPool.shuffle(_rng);
      item1 = realPool[0];
      item2 = realPool[1];

      // Prevent duplicates (Rare, but possible in small DBs)
      int attempts = 0;
      while (item1.id == item2.id && attempts < 10) {
        realPool.shuffle(_rng);
        item2 = realPool[1];
        attempts++;
      }
    }

    // 3. Return the pair (Shuffle again so Fake isn't always on the right)
    List<ViralMediaItem> finalPair = [item1, item2];
    finalPair.shuffle(_rng);

    return finalPair;
  }

  static List<ViralMediaItem> _getDummyErrorData() {
    return [
      const ViralMediaItem(
        id: 'err1',
        title: 'Error',
        description: 'Not enough data',
        popularityScore: 0,
        isFake: false,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
      const ViralMediaItem(
        id: 'err2',
        title: 'Error',
        description: 'Not enough data',
        popularityScore: 0,
        isFake: false,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
    ];
  }
}
