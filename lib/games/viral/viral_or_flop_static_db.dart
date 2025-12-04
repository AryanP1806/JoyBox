import 'viral_or_flop_models.dart';

final List<ViralMediaItem> staticViralDatabase = [
  // 🎬 MOVIES — VIRAL
  const ViralMediaItem(
    id: "movie_1",
    title: "Avengers: Endgame",
    description: "Marvel's biggest crossover event.",
    popularityScore: 980,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.movie,
  ),

  const ViralMediaItem(
    id: "movie_2",
    title: "Joker",
    description: "A dark psychological take on a classic villain.",
    popularityScore: 880,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.movie,
  ),

  const ViralMediaItem(
    id: "movie_3",
    title: "Dune",
    description: "Sci-fi epic about power, destiny, and deserts.",
    popularityScore: 740,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.movie,
  ),

  // 🎬 MOVIES — FLOP
  const ViralMediaItem(
    id: "movie_4",
    title: "Morbius",
    description: "Spider-universe antihero experiment.",
    popularityScore: 220,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.movie,
  ),

  const ViralMediaItem(
    id: "movie_5",
    title: "Cats",
    description: "Musical with… unforgettable CGI.",
    popularityScore: 180,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.movie,
  ),

  // 🎮 GAMES — VIRAL
  const ViralMediaItem(
    id: "game_1",
    title: "GTA V",
    description: "Open world crime sandbox.",
    popularityScore: 970,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.game,
  ),

  const ViralMediaItem(
    id: "game_2",
    title: "Minecraft",
    description: "Block-based survival creativity.",
    popularityScore: 990,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.game,
  ),

  // 🎮 GAMES — FLOP
  const ViralMediaItem(
    id: "game_3",
    title: "Babylon’s Fall",
    description: "Live-service fantasy combat game.",
    popularityScore: 150,
    isFake: false,
    source: MediaSourceType.staticData,
    category: MediaCategory.game,
  ),

  // 🤥 FAKE / AI BAIT
  const ViralMediaItem(
    id: "fake_1",
    title: "Avengers 5: Doom War",
    description: "Unannounced Marvel movie rumor.",
    popularityScore: 0,
    isFake: true,
    source: MediaSourceType.aiGenerated,
    category: MediaCategory.movie,
  ),
];
