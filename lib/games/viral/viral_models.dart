import 'dart:math';

// ==========================================
// 1. MODELS
// ==========================================

enum MediaSourceType { staticData, tmdb, igdb, aiGenerated }

enum MediaCategory { movie, game }

class ViralMediaItem {
  final String id;
  final String title;
  final String description;
  final int popularityScore;
  final bool isFake;
  final MediaSourceType source;
  final MediaCategory category;

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
