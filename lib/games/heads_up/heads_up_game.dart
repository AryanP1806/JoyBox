import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../core/safe_nav.dart';
import '../../widgets/pulse_timer_text.dart';
// Assuming these exist in your project structure
import 'heads_up_models.dart';
import 'heads_up_results.dart';

enum HeadsUpTilt { neutral, correct, pass }

class HeadsUpGameScreen extends StatefulWidget {
  final HeadsUpConfig config;

  const HeadsUpGameScreen({super.key, required this.config});

  @override
  State<HeadsUpGameScreen> createState() => _HeadsUpGameScreenState();
}

class _HeadsUpGameScreenState extends State<HeadsUpGameScreen>
    with SingleTickerProviderStateMixin {
  late List<String> _wordPool;
  String? _currentWord;

  int _score = 0;
  int _timeLeft = 0;

  Timer? _timer;

  // CHANGED: Using Accelerometer instead of Gyroscope
  StreamSubscription<AccelerometerEvent>? _accelSub;

  HeadsUpTilt _currentTilt = HeadsUpTilt.neutral;
  bool _cooldown = false;

  final List<String> _correctWords = [];
  final List<String> _passedWords = [];

  late AnimationController _cardAnim;
  late Animation<double> _scaleAnim;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Lock to landscape for the game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnim = Tween(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut));

    _timeLeft = widget.config.durationSeconds;
    _wordPool = List<String>.from(widget.config.getShuffledWords());
    if (_wordPool.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No words in this pack.")));
        SafeNav.goHome(context);
      });
      return;
    }
    _wordPool.shuffle();
    _nextWord();
    _startTimer();
    _startAccelerometer(); // CHANGED: Start the new sensor logic
  }

  // ---------------- TIMER ----------------

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          t.cancel();
          Vibration.hasVibrator().then((has) {
            if (has == true) Vibration.vibrate(duration: 160);
          });
          Vibration.hasVibrator().then((has) {
            if (has == true) Vibration.vibrate(duration: 160);
          });
          _endGame();
        }
      });
    });
  }

  // ---------------- ACCELEROMETER (Gravity) ----------------
  // This replaces the entire Gyroscope section.

  void _startAccelerometer() {
    _accelSub = accelerometerEvents.listen((event) {
      final tilt = _classifyTilt(event);
      _handleTilt(tilt);
    });
  }

  HeadsUpTilt _classifyTilt(AccelerometerEvent e) {
    // Z-axis detects if the screen is facing Up (Sky) or Down (Floor).
    // ~9.8 is facing up, -9.8 is facing down, 0 is vertical.
    // We use a threshold of 7.0 to ensure a clear, intentional tilt (~45 degrees).

    const double threshold = 7.0;

    if (e.z < -threshold) {
      // Screen facing floor -> Correct
      return HeadsUpTilt.correct;
    } else if (e.z > threshold) {
      // Screen facing ceiling -> Pass
      return HeadsUpTilt.pass;
    } else {
      return HeadsUpTilt.neutral;
    }
  }

  void _handleTilt(HeadsUpTilt newTilt) {
    if (_cooldown) return;

    // Trigger only when moving FROM neutral TO a state (prevents accidental double triggers)
    if (_currentTilt == HeadsUpTilt.neutral &&
        (newTilt == HeadsUpTilt.correct || newTilt == HeadsUpTilt.pass)) {
      _cooldown = true;

      if (newTilt == HeadsUpTilt.correct) {
        _onCorrect();
      } else {
        _onPass();
      }

      // Short delay to prevent rapid-fire triggering while bringing phone back up
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _cooldown = false;
        }
      });
    }

    _currentTilt = newTilt;
  }

  // ---------------- GAME ACTIONS ----------------

  void _onCorrect() {
    // 1. Logic updates FIRST
    if (_currentWord != null) {
      _correctWords.add(_currentWord!);
      _score++;
    }

    // 2. Visual updates immediately (UI feels responsive)
    _nextWord();
    _cardAnim.forward().then((_) => _cardAnim.reverse());

    // 3. Audio/Haptics in BACKGROUND (No 'await')
    _player.play(AssetSource("sounds/correct.mp3"));
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 80);
    });
  }

  void _onPass() {
    // 1. Logic
    if (_currentWord != null) {
      _passedWords.add(_currentWord!);
    }

    // 2. Visuals
    _nextWord();

    // 3. Audio/Haptics (No 'await')
    _player.play(AssetSource("sounds/pass.mp3"));
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 40);
    });
  }

  void _nextWord() {
    // Refill pool if empty
    if (_wordPool.length <= 1) {
      _wordPool = List<String>.from(widget.config.getShuffledWords());
      _wordPool.shuffle();
    }

    setState(() {
      _currentWord = _wordPool.removeLast();
    });
  }

  void _endGame() {
    _timer?.cancel();
    _accelSub?.cancel();

    // Reset orientation
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
    _accelSub?.cancel(); // Cancel the accelerometer subscription
    _cardAnim.dispose();
    _player.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // ---------------- PREMIUM UI ----------------

  @override
  Widget build(BuildContext context) {
    final word = _currentWord ?? "READY";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0F2027)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            // ✅ NEON TOP BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // _neonText("⏳ $_timeLeft"), _neonText("🔥 $_score"),
                PulseTimerText(text: "⏳$_timeLeft", color: Colors.cyanAccent),
                PulseTimerText(text: "🔥$_score", color: Colors.cyanAccent),
              ],
            ),

            const Spacer(),

            // ✅ ANIMATED WORD CARD
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: double.infinity, // Ensure full width usage
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.cyan, blurRadius: 25),
                  ],
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  word,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48, // Slightly larger for better visibility
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const Spacer(),

            const Text(
              "TILT DOWN = ✅   /   TILT UP = ❌",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            // ✅ BACKUP BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _gameButton("PASS", Colors.redAccent, _onPass),
                _gameButton("CORRECT", Colors.greenAccent, _onCorrect),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _neonText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.cyanAccent,
        shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
      ),
    );
  }

  Widget _gameButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
