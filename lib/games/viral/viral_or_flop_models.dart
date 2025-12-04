enum MediaSourceType {
  staticData, // Phase 1
  tmdb, // Phase 2
  igdb, // Phase 3
  aiGenerated, // Fake rounds
}

enum MediaCategory { movie, game }

class ViralMediaItem {
  final String id; // static id, tmdb id, igdb id
  final String title; // Movie/Game title
  final String description; // Short text description (SAFE)
  final int popularityScore; // Hidden from player
  final bool isFake; // Fake AI round
  final MediaSourceType source; // static/tmdb/igdb/ai
  final MediaCategory category; // movie/game

  const ViralMediaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.popularityScore,
    required this.isFake,
    required this.source,
    required this.category,
  });
}
