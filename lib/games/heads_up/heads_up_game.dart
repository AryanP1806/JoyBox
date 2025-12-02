import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'heads_up_models.dart';
import 'heads_up_results.dart';

enum HeadsUpTilt { neutral, correct, pass }

class HeadsUpGameScreen extends StatefulWidget {
  final HeadsUpConfig config;

  const HeadsUpGameScreen({super.key, required this.config});

  @override
  State<HeadsUpGameScreen> createState() => _HeadsUpGameScreenState();
}

class _HeadsUpGameScreenState extends State<HeadsUpGameScreen> {
  late List<String> _wordPool;
  String? _currentWord;

  int _score = 0;
  int _timeLeft = 0;

  Timer? _timer;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  HeadsUpTilt _currentTilt = HeadsUpTilt.neutral;
  bool _cooldown = false;

  // ✅ ACCUMULATED ROTATION (THIS IS THE KEY)
  double _rotationAccumulator = 0;

  final List<String> _correctWords = [];
  final List<String> _passedWords = [];

  @override
  void initState() {
    super.initState();

    // ✅ FORCE LANDSCAPE MODE
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _timeLeft = widget.config.durationSeconds;
    _wordPool = widget.config.getShuffledWords();

    _nextWord();
    _startTimer();
    _startGyroscope();
  }

  // ---------------- TIMER ----------------

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          t.cancel();
          _endGame();
        }
      });
    });
  }

  // ---------------- GYROSCOPE ----------------

  void _startGyroscope() {
    _gyroSub = gyroscopeEvents.listen((event) {
      final tilt = _classifyTilt(event);
      _handleTilt(tilt);
    });
  }

  // ✅ REAL ROTATIONAL TILT DETECTION
  HeadsUpTilt _classifyTilt(GyroscopeEvent e) {
    // Rotation around X axis = forward/back forehead tilt
    const double rotationThreshold = 1.4;

    // ✅ Integrate rotation over time
    _rotationAccumulator += e.x;

    // ✅ HARD LIMITS
    if (_rotationAccumulator > rotationThreshold) {
      _rotationAccumulator = 0;
      return HeadsUpTilt.correct; // forward tilt
    } else if (_rotationAccumulator < -rotationThreshold) {
      _rotationAccumulator = 0;
      return HeadsUpTilt.pass; // backward tilt
    } else {
      return HeadsUpTilt.neutral;
    }
  }

  void _handleTilt(HeadsUpTilt newTilt) {
    if (_cooldown) return;

    if (_currentTilt == HeadsUpTilt.neutral &&
        (newTilt == HeadsUpTilt.correct || newTilt == HeadsUpTilt.pass)) {
      _cooldown = true;

      if (newTilt == HeadsUpTilt.correct) {
        _onCorrect();
      } else {
        _onPass();
      }

      // ✅ STRONG COOLDOWN – NO DOUBLE TRIGGERS
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _cooldown = false;
      });
    }

    _currentTilt = newTilt;
  }

  // ---------------- GAME ACTIONS ----------------

  void _onCorrect() {
    if (_currentWord != null) {
      _correctWords.add(_currentWord!);
      _score++;
    }
    _nextWord();
  }

  void _onPass() {
    if (_currentWord != null) {
      _passedWords.add(_currentWord!);
    }
    _nextWord();
  }

  void _nextWord() {
    if (_wordPool.isEmpty) {
      _wordPool = widget.config.getShuffledWords();
    }

    setState(() {
      _currentWord = _wordPool.removeLast();
    });
  }

  void _endGame() {
    _timer?.cancel();
    _gyroSub?.cancel();

    // ✅ RESTORE NORMAL ORIENTATION
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HeadsUpResultsScreen(
          score: _score,
          durationSeconds: widget.config.durationSeconds,
          correctWords: _correctWords,
          passedWords: _passedWords,
          packLabel: widget.config.pack.label,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gyroSub?.cancel();

    // ✅ SAFETY RESET
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final word = _currentWord ?? "Ready";

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ TOP BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Time: $_timeLeft",
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  "Score: $_score",
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ],
            ),

            // ✅ WORD CENTER
            Expanded(
              child: Center(
                child: Text(
                  word,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ✅ INSTRUCTIONS
            const Text(
              "Tilt FORWARD = CORRECT\nTilt BACKWARD = PASS",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),

            const SizedBox(height: 10),

            // ✅ BACKUP BUTTONS (ALWAYS KEEP THESE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _onPass, child: const Text("Pass")),
                ElevatedButton(
                  onPressed: _onCorrect,
                  child: const Text("Correct"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
