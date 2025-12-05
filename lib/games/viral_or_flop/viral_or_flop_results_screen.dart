import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- ADDED
import '../../auth/auth_service.dart'; // <--- ADDED

class ViralOrFlopResultsScreen extends StatefulWidget {
  final int finalStreak;

  const ViralOrFlopResultsScreen({super.key, required this.finalStreak});

  @override
  State<ViralOrFlopResultsScreen> createState() =>
      _ViralOrFlopResultsScreenState();
}

class _ViralOrFlopResultsScreenState extends State<ViralOrFlopResultsScreen> {
  String get _rank {
    if (widget.finalStreak >= 7) return "💀 LEGEND";
    if (widget.finalStreak >= 5) return "🛡 IMMUNE BEAST";
    if (widget.finalStreak >= 3) return "🔥 HOT STREAK";
    return "🙂 ROOKIE";
  }

  String get _message {
    if (widget.finalStreak >= 7) {
      return "Everyone else drinks tonight 😈";
    } else if (widget.finalStreak >= 5) {
      return "You skipped punishment like a boss 🛡";
    } else if (widget.finalStreak >= 3) {
      return "You're heating up 🔥";
    } else {
      return "Warm up round 😅";
    }
  }

  @override
  void initState() {
    super.initState();
    // ✅ Trigger Save Logic on load
    _saveGame();
  }

  // ✅ NEW: Save Logic
  Future<void> _saveGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Logic: If you get a high enough streak (Immune Beast 5+),
    // you "won" against the odds.
    final bool isWin = widget.finalStreak >= 5;

    await AuthService().addGameHistory(
      gameName: "Viral or Flop",
      won: isWin,
      details: {
        "streak": widget.finalStreak,
        "rank": _rank,
        "outcome": _message,
      },
    );

    await AuthService().updateGameStats(won: isWin);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ✅ BLOCK back button completely (no re-entry into game)
      canPop: false,
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
                    "🔥 FINAL STREAK: ${widget.finalStreak}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ✅ SAFE BACK TO SETUP (NO GAME STACK LEFT)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // ✅ This is now safe because GameScreen uses pushReplacement
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
