import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../auth/auth_service.dart';
import 'quick_draw_models.dart';
import 'quick_draw_results.dart';

class QuickDrawGameScreen extends StatefulWidget {
  final QuickDrawConfig config;

  const QuickDrawGameScreen({super.key, required this.config});

  @override
  State<QuickDrawGameScreen> createState() => _QuickDrawGameScreenState();
}

class _QuickDrawGameScreenState extends State<QuickDrawGameScreen> {
  // Game State
  QuickDrawState _state = QuickDrawState.idle;
  int _currentRound = 1;
  final List<int> _reactionTimes = [];
  int _earlyTaps = 0;

  // Timers
  Timer? _waitTimer;
  Stopwatch _stopwatch = Stopwatch();
  final Random _rng = Random();

  // Audio
  final AudioPlayer _player = AudioPlayer();

  // Chaos Mode visuals
  Color _screenColor = Colors.black;
  String _centerText = "TAP TO START";
  IconData _centerIcon = Icons.touch_app;
  bool _isFakeOut = false;

  @override
  void dispose() {
    _waitTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // ---------------- GAME LOOP ----------------

  void _startRound() {
    setState(() {
      _state = QuickDrawState.waiting;
      _screenColor = const Color(0xFF1A1A1A); // Dark Grey waiting
      _centerText = "WAIT...";
      _centerIcon = Icons.hourglass_empty;
      _isFakeOut = false;
    });

    // 1. Calculate Random Delay (2s to 6s)
    int delayMs = 2000 + _rng.nextInt(4000);

    // 2. Chaos Mode Logic: Maybe do a fake-out?
    if (widget.config.mode == QuickDrawMode.chaos && _rng.nextBool()) {
      _scheduleFakeOut(delayMs);
    } else {
      _scheduleTrigger(delayMs);
    }
  }

  void _scheduleTrigger(int delayMs) {
    _waitTimer = Timer(Duration(milliseconds: delayMs), _trigger);
  }

  void _scheduleFakeOut(int realTriggerMs) {
    // Fake out happens BEFORE the real trigger
    int fakeTime = (realTriggerMs * 0.6).round();

    _waitTimer = Timer(Duration(milliseconds: fakeTime), () {
      if (!mounted || _state != QuickDrawState.waiting) return;

      setState(() {
        _isFakeOut = true;
        // Fake visual: Flash ORANGE (not green)
        _screenColor = Colors.orangeAccent;
        _centerText = "WAIT!";
      });

      // Reset to dark after 400ms, then trigger real one
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted || _state != QuickDrawState.waiting) return;
        setState(() {
          _screenColor = const Color(0xFF1A1A1A);
          _isFakeOut = false;
        });

        // Schedule the REAL trigger remaining time
        int remaining = realTriggerMs - fakeTime - 400;
        if (remaining < 500) remaining = 500; // Minimum safety buffer
        _waitTimer = Timer(Duration(milliseconds: remaining), _trigger);
      });
    });
  }

  void _trigger() async {
    if (!mounted || _state != QuickDrawState.waiting) return;

    _stopwatch.reset();
    _stopwatch.start();

    // Haptics & Sound
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100, amplitude: 255);
    }
    // _player.play(AssetSource('sounds/gunshot.mp3')); // Add sound later

    setState(() {
      _state = QuickDrawState.triggered;
      _screenColor = const Color(0xFF00FF00); // NEON GREEN
      _centerText = "TAP!";
      _centerIcon = Icons.flash_on;
    });
  }

  // ---------------- INTERACTION ----------------

  void _handleTap() {
    if (_state == QuickDrawState.idle) {
      _startRound();
      return;
    }

    if (_state == QuickDrawState.waiting) {
      _handleEarlyTap();
      return;
    }

    if (_state == QuickDrawState.triggered) {
      _handleSuccess();
      return;
    }

    // If 'won' or 'early', tap to go next
    if (_state == QuickDrawState.won || _state == QuickDrawState.early) {
      if (_currentRound < widget.config.totalRounds) {
        setState(() => _currentRound++);
        _startRound();
      } else {
        _finishGame();
      }
    }
  }

  void _handleEarlyTap() {
    _waitTimer?.cancel();
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 80);
    });

    setState(() {
      _state = QuickDrawState.early;
      _screenColor = Colors.redAccent;
      _centerText = "TOO EARLY!";
      _centerIcon = Icons.error_outline;
      _earlyTaps++;
    });
  }

  void _handleSuccess() {
    _stopwatch.stop();
    int reactionTime = _stopwatch.elapsedMilliseconds;
    _reactionTimes.add(reactionTime);

    setState(() {
      _state = QuickDrawState.won;
      _screenColor = Colors.cyanAccent;
      _centerText = "${reactionTime}ms";
      _centerIcon = Icons.check_circle;
    });
  }

  Future<void> _finishGame() async {
    // Calc stats
    int total = _reactionTimes.fold(0, (a, b) => a + b);
    int avg = _reactionTimes.isEmpty
        ? 0
        : (total / _reactionTimes.length).round();

    // Save to Firebase
    await AuthService().addGameHistory(
      gameName: "Quick Draw: ${widget.config.mode.name}",
      won: true, // Always "won" unless we add a fail condition
      details: {
        "avg_ms": avg,
        "best_ms": _reactionTimes.isEmpty ? 0 : _reactionTimes.reduce(min),
        "early_taps": _earlyTaps,
        "mode": widget.config.mode.name,
      },
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuickDrawResultsScreen(
          avgTime: avg,
          earlyTaps: _earlyTaps,
          bestTime: _reactionTimes.isEmpty ? 0 : _reactionTimes.reduce(min),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    // Determine text color based on background
    Color textColor =
        (_state == QuickDrawState.triggered || _state == QuickDrawState.won)
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) =>
            _handleTap(), // Instant response on touch DOWN, not UP
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50), // Ultra fast color switch
          color: _screenColor,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Info
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "ROUND $_currentRound / ${widget.config.totalRounds}",
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Center Visuals
              Icon(_centerIcon, size: 100, color: textColor),
              const SizedBox(height: 20),
              Text(
                _centerText,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              if (_state == QuickDrawState.won)
                Text(
                  "Tap to continue",
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),

              const Spacer(),

              // Bottom Hint
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _state == QuickDrawState.idle ? "TAP SCREEN TO BEGIN" : "",
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
