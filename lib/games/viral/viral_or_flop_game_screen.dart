import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'viral_or_flop_models.dart';
import 'viral_or_flop_results_screen.dart';

class ViralOrFlopGameScreen extends StatefulWidget {
  final MediaCategory category;
  final bool fakeEnabled;
  final bool partyMode;
  final bool timerEnabled;
  final int timerSeconds;

  const ViralOrFlopGameScreen({
    super.key,
    required this.category,
    required this.fakeEnabled,
    required this.partyMode,
    required this.timerEnabled,
    required this.timerSeconds,
  });

  @override
  State<ViralOrFlopGameScreen> createState() => _ViralOrFlopGameScreenState();
}

class _ViralOrFlopGameScreenState extends State<ViralOrFlopGameScreen> {
  final Random _random = Random();

  late List<ViralMediaItem> _database;
  late ViralMediaItem _left;
  late ViralMediaItem _right;

  int _streak = 0;
  bool _immunity = false;

  Timer? _timer;
  int _timeLeft = 0;

  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _loadDatabase();
    _nextRound();
  }

  // ---------------- DATABASE (STATIC TEXT ONLY) ----------------

  void _loadDatabase() {
    _database = [
      ViralMediaItem(
        id: 'movie_1',
        title: "Interstellar",
        description: "Sci-fi epic",
        popularityScore: 920000,
        isFake: false,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
      ViralMediaItem(
        id: 'movie_2',
        title: "Morbius",
        description: "It's Morbin' time",
        popularityScore: 180000,
        isFake: false,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
      ViralMediaItem(
        id: 'movie_3',
        title: "Fake AI Movie",
        description: "Generated nonsense",
        popularityScore: 999999,
        isFake: true,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
      ViralMediaItem(
        id: 'movie_4',
        title: "Minecraft",
        description: "Block survival",
        popularityScore: 1200000,
        isFake: false,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
      ViralMediaItem(
        id: 'movie_5',
        title: "Unknown Indie",
        description: "Nobody played",
        popularityScore: 1500,
        isFake: false,
        source: MediaSourceType.staticData,
        category: MediaCategory.movie,
      ),
    ];
  }

  // ---------------- ROUND LOADER ----------------

  void _nextRound() {
    _locked = false;
    _timer?.cancel();

    _left = _database[_random.nextInt(_database.length)];
    _right = _database[_random.nextInt(_database.length)];

    while (_left == _right) {
      _right = _database[_random.nextInt(_database.length)];
    }

    if (widget.fakeEnabled &&
        _random.nextBool() &&
        !_left.isFake &&
        !_right.isFake) {
      _right = _database.firstWhere((e) => e.isFake, orElse: () => _right);
    }

    if (widget.timerEnabled) {
      _startTimer();
    }

    setState(() {});
  }

  // ---------------- TIMER ----------------

  void _startTimer() {
    _timeLeft = widget.timerSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) {
        t.cancel();
        _handleTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleTimeout() {
    if (_locked) return;
    _locked = true;

    _applyWrong();
    Future.delayed(const Duration(seconds: 1), _nextRound);
  }

  // ---------------- TAP LOGIC ----------------

  void _select(ViralMediaItem chosen, ViralMediaItem other) {
    if (_locked) return;
    _locked = true;
    _timer?.cancel();

    final correct =
        chosen.popularityScore >= other.popularityScore && !chosen.isFake;

    if (correct) {
      _applyCorrect();
    } else {
      _applyWrong(fake: chosen.isFake);
    }

    Future.delayed(const Duration(seconds: 1), _nextRound);
  }

  void _applyCorrect() {
    _streak++;

    if (_streak == 5) _immunity = true;

    setState(() {});
  }

  void _applyWrong({bool fake = false}) {
    if (_immunity) {
      _immunity = false;
      return;
    }

    _streak = 0;

    if (widget.partyMode) {
      // 💀 punishment is applied by UI toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fake ? "DOUBLE PUNISHMENT! 💀" : "DRINK / DARE / TRUTH!",
          ),
        ),
      );
    }

    setState(() {});
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ✅ Prevent broken backstack
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("VIRAL OR FLOP"),
          actions: [
            IconButton(icon: const Icon(Icons.stop), onPressed: _endGame),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _topBar(),
              const SizedBox(height: 20),
              _card(_left, () => _select(_left, _right)),
              const SizedBox(height: 12),
              _card(_right, () => _select(_right, _left)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "🔥 Streak: $_streak",
          style: const TextStyle(color: Colors.orange, fontSize: 18),
        ),
        if (widget.timerEnabled)
          Text("⏳ $_timeLeft", style: const TextStyle(color: Colors.white)),
        if (_immunity)
          const Text("🛡 IMMUNE", style: TextStyle(color: Colors.green)),
      ],
    );
  }

  Widget _card(ViralMediaItem item, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF232526), Color(0xFF414345)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- END GAME ----------------

  void _endGame() {
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ViralOrFlopResultsScreen(finalStreak: _streak),
      ),
    );
  }
}
