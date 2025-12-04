import 'package:flutter/material.dart';

class ViralOrFlopResultsScreen extends StatelessWidget {
  final int finalStreak;

  const ViralOrFlopResultsScreen({super.key, required this.finalStreak});

  String get _rank {
    if (finalStreak >= 7) return "💀 LEGEND";
    if (finalStreak >= 5) return "🛡 IMMUNE BEAST";
    if (finalStreak >= 3) return "🔥 HOT STREAK";
    return "🙂 ROOKIE";
  }

  String get _message {
    if (finalStreak >= 7) {
      return "Everyone else drinks tonight 😈";
    } else if (finalStreak >= 5) {
      return "You skipped punishment like a boss 🛡";
    } else if (finalStreak >= 3) {
      return "You're heating up 🔥";
    } else {
      return "Warm up round 😅";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ✅ Prevent jumping back into game
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "GAME OVER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _rank,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF512F), Color(0xFFF09819)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.orange, blurRadius: 16),
                    ],
                  ),
                  child: Text(
                    "🔥 FINAL STREAK: $finalStreak",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ✅ BACK TO SETUP
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // ✅ Goes back cleanly
                  },
                  child: const Text(
                    "BACK TO SETUP",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
