import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure intl is in pubspec.yaml

// This provides ViralMediaItem and MediaCategory
import 'viral_or_flop_models.dart';

// This provides the result screen
import 'viral_or_flop_results_screen.dart';

// This provides the LOGIC class (ViralOrFlopEngine)
import 'viral_or_flop_engine.dart';

class ViralOrFlopGameScreen extends StatefulWidget {
  final MediaCategory category;
  final bool fakeEnabled;
  final bool partyMode;
  final bool timerEnabled;
  final int timerSeconds;
  final ViralPlayMode playMode;

  const ViralOrFlopGameScreen({
    super.key,
    required this.category,
    required this.fakeEnabled,
    required this.partyMode,
    required this.timerEnabled,
    required this.timerSeconds,
    required this.playMode,
  });

  @override
  State<ViralOrFlopGameScreen> createState() => _ViralOrFlopGameScreenState();
}

class _ViralOrFlopGameScreenState extends State<ViralOrFlopGameScreen> {
  late ViralMediaItem _left;
  late ViralMediaItem _right;

  // Score State
  int _streak = 0;
  bool _immunity = false;

  // Game Loop State
  Timer? _timer;
  int _timeLeft = 0;
  bool _locked = false;
  bool _isLoading = true;

  // Reveal Animation State
  bool _reveal = false; // Controls score visibility
  String? _resultMessage; // "Correct!", "Wrong!", etc.
  Color _resultColor = Colors.transparent; // Overlay background color

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Wait for the widget to build before starting the round logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nextRound();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------- NEXT ROUND ----------------

  void _nextRound() {
    setState(() {
      _locked = false;
      _reveal = false; // Reset reveal state
      _resultMessage = null;
      _resultColor = Colors.transparent;
      _isLoading = false;
    });

    final pair = ViralOrFlopEngine.getRandomPair(
      forceCategory: widget.category,
      includeFake: widget.fakeEnabled,
      playMode: widget.playMode,
    );

    if (pair.isEmpty) {
      setState(() => _isLoading = false); // Stop loading

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No items found for ${widget.category.name}! Add data to DB.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    _left = pair[0];
    _right = pair[1];

    _timer?.cancel();
    if (widget.timerEnabled) {
      _startTimer();
    }
  }

  // ---------------- TIMER ----------------

  void _startTimer() {
    _timeLeft = widget.timerSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

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
    _handleRoundEnd(isTimeout: true);
  }

  // ---------------- TAP & LOGIC ----------------

  void _onCardTap(ViralMediaItem selected) {
    if (_locked) return;

    // Determine correctness based on mode
    bool isTarget = widget.playMode == ViralPlayMode.viralOnly
        ? selected.isViral
        : selected.isFlop;

    // You lose if it's NOT the target OR if it IS the target but is FAKE
    bool correct = isTarget && !selected.isFake;

    _handleRoundEnd(correct: correct, selected: selected);
  }

  void _handleRoundEnd({
    bool correct = false,
    bool isTimeout = false,
    ViralMediaItem? selected,
  }) {
    _timer?.cancel();
    setState(() {
      _locked = true;
      _reveal = true; // SHOW THE SCORES
    });

    if (isTimeout) {
      _applyWrong(isTimeout: true);
    } else if (correct) {
      _applyCorrect();
    } else {
      _applyWrong(isFakeTrap: selected?.isFake ?? false);
    }
  }

  void _applyCorrect() {
    setState(() {
      _resultMessage = "CORRECT!";
      _resultColor = Colors.green.withValues(alpha: 0.2);
      _streak++;
      if (_streak == 5) _immunity = true;
    });

    // Delay to let user see numbers
    Future.delayed(const Duration(milliseconds: 2000), _nextRound);
  }

  void _applyWrong({bool isFakeTrap = false, bool isTimeout = false}) {
    // Immunity Check
    if (_immunity) {
      setState(() {
        _immunity = false;
        _resultMessage = "SAVED BY IMMUNITY!";
        _resultColor = Colors.blue.withValues(alpha: 0.2);
      });
      Future.delayed(const Duration(milliseconds: 2000), _nextRound);
      return;
    }

    // Determine Message
    String msg = "WRONG!";
    if (isFakeTrap) msg = "IT'S A FAKE!";
    if (isTimeout) msg = "TOO SLOW!";

    setState(() {
      _resultMessage = msg;
      _resultColor = Colors.red.withValues(alpha: 0.3);
    });

    // Party Mode Punishments
    if (widget.partyMode) {
      String partyMsg = "DRINK! 🍺";
      if (isFakeTrap) partyMsg = "DOUBLE DRINK! 💀";
      if (isTimeout) partyMsg = "DRINK! ⏳";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            partyMsg,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(milliseconds: 2500),
        ),
      );
    }

    Future.delayed(
      const Duration(milliseconds: 2000),
      () => _endGame(finalScore: _streak),
    );
  }

  void _endGame({int? finalScore}) {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ViralOrFlopResultsScreen(finalStreak: finalScore ?? _streak),
      ),
    );
  }

  // ---------------- UI BUILDERS ----------------

  String _formatNumber(int num) {
    if (num == 0) return "FAKE / 0";
    final formatter = NumberFormat('#,###');
    return formatter.format(num);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                _statusBar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildGameCard(
                        _left,
                        () => _onCardTap(_left),
                        Colors.blue,
                      ),
                      _buildVsIndicator(),
                      _buildGameCard(
                        _right,
                        () => _onCardTap(_right),
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // RESULT OVERLAY
            if (_reveal && _resultMessage != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: _resultColor,
                    alignment: Alignment.center,
                    child: Text(
                      _resultMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 12,
        left: 20,
        right: 20,
      ),
      color: Colors.white10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                "$_streak",
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Only show timer if not revealing answers
          if (widget.timerEnabled && !_reveal)
            Text(
              "⏳ $_timeLeft",
              style: TextStyle(
                color: _timeLeft <= 2 ? Colors.red : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

          if (_immunity)
            const Row(
              children: [
                Text(
                  "🛡 IMMUNE",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVsIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "VS",
        style: TextStyle(
          color: Colors.white24,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildGameCard(ViralMediaItem item, VoidCallback onTap, Color accent) {
    Color cardBorder = accent.withValues(alpha: 0.3);
    Color cardBg = accent.withValues(alpha: 0.05);

    // --- REVEAL COLOR LOGIC ---
    if (_reveal) {
      // Determine if this card matches the game mode criteria
      bool matchesMode = widget.playMode == ViralPlayMode.viralOnly
          ? item.isViral
          : item.isFlop;

      if (item.isFake) {
        // Fakes are bad
        cardBorder = Colors.redAccent;
        cardBg = Colors.red.withValues(alpha: 0.1);
      } else if (matchesMode) {
        // Correct Answer
        cardBorder = Colors.green;
        cardBg = Colors.green.withValues(alpha: 0.1);
      } else {
        // Neutral / Wrong
        cardBorder = Colors.grey.withValues(alpha: 0.2);
        cardBg = Colors.black;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: cardBg,
            gradient: _reveal
                ? null
                : LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.25),
                      accent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(color: cardBorder, width: _reveal ? 4 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.category == MediaCategory.movie
                    ? Icons.movie
                    : Icons.gamepad,
                size: 32,
                color: Colors.white70,
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // --- REVEAL CONTENT ---
              if (_reveal)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      const Text(
                        "POPULARITY",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        _formatNumber(item.popularityScore),
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.isFake)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            "⚠️ AI FAKE ⚠️",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
