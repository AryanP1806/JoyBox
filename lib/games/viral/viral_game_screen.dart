import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'viral_models.dart';
import 'viral_results_screen.dart';
import 'viral_engine.dart';
import '../../audio/sound_manager.dart';

class ViralGameScreen extends StatefulWidget {
  final MediaCategory category;
  final bool fakeEnabled;
  final bool partyMode;
  final bool timerEnabled;
  final int timerSeconds;

  const ViralGameScreen({
    super.key,
    required this.category,
    required this.fakeEnabled,
    required this.partyMode,
    required this.timerEnabled,
    required this.timerSeconds,
  });

  @override
  State<ViralGameScreen> createState() => _ViralGameScreenState();
}

class _ViralGameScreenState extends State<ViralGameScreen> {
  late ViralMediaItem _left;
  late ViralMediaItem _right;
  bool _isLoading = true;

  bool _locked = false;
  bool _reveal = false;
  String? _resultMessage;
  Color _resultColor = Colors.transparent;

  int _streak = 0;
  bool _immunity = false;

  Timer? _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextRound() {
    setState(() {
      _locked = false;
      _reveal = false;
      _isLoading = false;
      _resultMessage = null;
      _resultColor = Colors.transparent;
    });

    final pair = ViralEngine.getRandomPair(
      forceCategory: widget.category,
      includeFake: widget.fakeEnabled,
    );

    _left = pair[0];
    _right = pair[1];

    _timer?.cancel();
    if (widget.timerEnabled) {
      _startTimer();
    }
  }

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

  void _onCardTap(ViralMediaItem selected, ViralMediaItem other) {
    if (_locked) return;
    bool correct = selected.popularityScore >= other.popularityScore;
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
      _reveal = true;
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
    SoundManager.playWin();
    setState(() {
      _resultMessage = "CORRECT!";
      _resultColor = Colors.green.withValues(alpha: 0.25);
      _streak++;
      if (_streak == 5) _immunity = true;
    });

    Future.delayed(const Duration(milliseconds: 1600), _nextRound);
  }

  void _applyWrong({bool isFakeTrap = false, bool isTimeout = false}) {
    SoundManager.playFail();

    if (_immunity) {
      setState(() {
        _immunity = false;
        _resultMessage = "IMMUNITY SAVED YOU!";
        _resultColor = Colors.blueGrey.withValues(alpha: 0.25);
      });
      Future.delayed(const Duration(milliseconds: 1600), _nextRound);
      return;
    }

    String msg = "WRONG!";
    if (isFakeTrap) msg = "FAKE TRAP!";
    if (isTimeout) msg = "TIME UP!";

    setState(() {
      _resultMessage = msg;
      _resultColor = Colors.redAccent.withValues(alpha: 0.35);
    });

    if (widget.partyMode) {
      String partyMsg = isFakeTrap ? "DOUBLE DRINK 💀" : "DRINK 🍺";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            partyMsg,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(milliseconds: 2500),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    Future.delayed(
      const Duration(milliseconds: 1800),
      () => _endGame(finalScore: _streak),
    );
  }

  void _endGame({int? finalScore}) {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ViralResultsScreen(finalStreak: finalScore ?? _streak),
      ),
    );
  }

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
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGameCard(_left, () => _onCardTap(_left, _right)),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "VS",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildGameCard(_right, () => _onCardTap(_right, _left)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_reveal && _resultMessage != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    color: _resultColor,
                    alignment: Alignment.center,
                    child: Text(
                      _resultMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.black, blurRadius: 18)],
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

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 14,
        left: 20,
        right: 20,
      ),
      color: Colors.black,
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.timerEnabled && !_reveal)
            Text(
              "$_timeLeft",
              style: TextStyle(
                color: _timeLeft <= 2 ? Colors.red : Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_immunity)
            const Icon(Icons.shield_rounded, color: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildGameCard(ViralMediaItem item, VoidCallback onTap) {
    Color cardBorder = Colors.white12;
    Color cardBg = const Color(0xFF1E1E1E);

    if (_reveal) {
      bool isWinner =
          item.popularityScore >= _left.popularityScore &&
          item.popularityScore >= _right.popularityScore;

      if (isWinner) {
        cardBorder = Colors.green;
      } else {
        cardBorder = Colors.redAccent;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cardBg,
            border: Border.all(color: cardBorder, width: _reveal ? 3 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.category == MediaCategory.movie
                    ? Icons.movie
                    : Icons.gamepad,
                size: 50,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

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
                          color: Colors.orange,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.isFake)
                        const Text(
                          "(AI GENERATED)",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
                  child: Text(
                    item.description,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
