import 'package:flutter/material.dart';
import 'quick_draw_models.dart';
import 'quick_draw_game.dart';

class QuickDrawSetupScreen extends StatefulWidget {
  const QuickDrawSetupScreen({super.key});

  @override
  State<QuickDrawSetupScreen> createState() => _QuickDrawSetupScreenState();
}

class _QuickDrawSetupScreenState extends State<QuickDrawSetupScreen> {
  QuickDrawMode _selectedMode = QuickDrawMode.classic;
  int _rounds = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(Icons.flash_on, size: 80, color: Colors.cyanAccent),
                const SizedBox(height: 20),
                const Text(
                  "QUICK DRAW",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Courier', // Monospace looks cool/digital
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Reflex Test / Chaos Mode",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),

                // MODE SELECTOR
                _neonSelector(
                  "CLASSIC",
                  "Pure speed. Wait for Green.",
                  QuickDrawMode.classic,
                ),
                const SizedBox(height: 16),
                _neonSelector(
                  "CHAOS",
                  "Fake-outs, shakes, and panic.",
                  QuickDrawMode.chaos,
                ),

                const SizedBox(height: 40),

                // START BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    shadowColor: Colors.pinkAccent,
                    elevation: 10,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuickDrawGameScreen(
                          config: QuickDrawConfig(
                            mode: _selectedMode,
                            totalRounds: _rounds,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "INITIALIZE",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _neonSelector(String title, String subtitle, QuickDrawMode mode) {
    final isSelected = _selectedMode == mode;
    final color = isSelected ? Colors.cyanAccent : Colors.white24;

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.cyanAccent : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
