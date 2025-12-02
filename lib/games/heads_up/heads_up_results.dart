import 'package:flutter/material.dart';

class HeadsUpResultsScreen extends StatefulWidget {
  final int score;
  final int durationSeconds;
  final List<String> correctWords;
  final List<String> passedWords;
  final String packLabel;

  const HeadsUpResultsScreen({
    super.key,
    required this.score,
    required this.durationSeconds,
    required this.correctWords,
    required this.passedWords,
    required this.packLabel,
  });

  @override
  State<HeadsUpResultsScreen> createState() => _HeadsUpResultsScreenState();
}

class _HeadsUpResultsScreenState extends State<HeadsUpResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scoreAnim = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    );
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),

              // ✅ TITLE
              const Text(
                "ROUND COMPLETE",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 8),

              // ✅ PACK + TIME
              Text(
                "${widget.packLabel.toUpperCase()} • ${widget.durationSeconds}s",
                style: const TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 30),

              // ✅ ANIMATED SCORE
              ScaleTransition(
                scale: _scoreAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    "SCORE ${widget.score}",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ✅ RESULTS LIST
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _resultPanel(
                        title: "✅ CORRECT",
                        color: Colors.greenAccent,
                        words: widget.correctWords,
                      ),
                      const SizedBox(width: 12),
                      _resultPanel(
                        title: "⏭ PASSED",
                        color: Colors.orangeAccent,
                        words: widget.passedWords,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ✅ PLAY AGAIN BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "PLAY AGAIN",
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ REUSABLE PANEL WIDGET
  Widget _resultPanel({
    required String title,
    required Color color,
    required List<String> words,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: words.isEmpty
                  ? const Center(
                      child: Text(
                        "None",
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: words
                            .map(
                              (w) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: color),
                                ),
                                child: Text(
                                  w,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
