enum MediaCategory { movie, game, social }

enum MediaSourceType { staticData, tmdb, igdb }

enum ViralPlayMode {
  viralOnly, // user must tap the VIRAL one
  flopOnly, // user must tap the FLOP one
}

class ViralMediaItem {
  final String id;
  final String title;
  final String description;
  final bool isViral;
  final int popularityScore;
  final bool isFake;
  final MediaSourceType source;
  final MediaCategory category;

  const ViralMediaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isViral,
    required this.popularityScore,
    required this.isFake,
    required this.source,
    required this.category,
  });

  // -------------- ADD THIS GETTER --------------
  /// Helper to make the code readable.
  /// If it is NOT viral, it is a FLOP.
  bool get isFlop => !isViral;
}
