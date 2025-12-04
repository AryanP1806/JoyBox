import 'dart:math';
import 'viral_or_flop_models.dart';
import 'viral_or_flop_static_db.dart';

final Random _rng = Random();

class ViralOrFlopEngine {
  static List<ViralMediaItem> getRandomPair({
    bool includeFake = false,
    MediaCategory? forceCategory,
  }) {
    List<ViralMediaItem> pool = List.from(staticViralDatabase);

    if (!includeFake) {
      pool.removeWhere((item) => item.isFake);
    }

    if (forceCategory != null) {
      pool.removeWhere((item) => item.category != forceCategory);
    }

    pool.shuffle(_rng);

    return [pool[0], pool[1]];
  }

  static bool isFirstMoreViral(ViralMediaItem a, ViralMediaItem b) {
    return a.popularityScore > b.popularityScore;
  }
}
