import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_setup.dart';
import '../../core/safe_nav.dart';

class MrWhiteScoreBoardScreen extends StatelessWidget {
  final List<MrWhitePlayer> players;
  final bool mrWhiteWonByNumbers;
  final bool civiliansWon;
  final bool? mrWhiteGuessCorrect;

  const MrWhiteScoreBoardScreen({
    super.key,
    required this.players,
    this.mrWhiteWonByNumbers = false,
    this.civiliansWon = false,
    this.mrWhiteGuessCorrect,
  });

  String get winnerText {
    if (mrWhiteGuessCorrect == true) {
      return "MR WHITE WINS BY GUESS!";
    }
    if (mrWhiteGuessCorrect == false) {
      return "CIVILIANS WIN!";
    }
    if (mrWhiteWonByNumbers) {
      return "MR WHITE WINS BY NUMBERS!";
    }
    if (civiliansWon) {
      return "CIVILIANS WIN!";
    }
    return "ROUND COMPLETE";
  }

  void applyScores() {
    // ✅ FINAL SCORING LOGIC (SAFE + NON-REPEATABLE)

    if (mrWhiteGuessCorrect == true || mrWhiteWonByNumbers) {
      for (var p in players) {
        if (p.role == "mrwhite") p.score += 2;
      }
    } else if (mrWhiteGuessCorrect == false || civiliansWon) {
      for (var p in players) {
        if (p.role == "civilian") p.score += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    applyScores();
    if (players.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000428), Color(0xFF004E92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ✅ WINNER TITLE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.9),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  winnerText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ FINAL ROLE + SCORE LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final p = players[index];
                    final isSpecial = p.role != "civilian";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.black.withValues(alpha: 0.45),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: isSpecial
                                ? Colors.redAccent.withValues(alpha: 0.3)
                                : Colors.greenAccent.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.role.toUpperCase(),
                                  style: TextStyle(
                                    color: p.role == "civilian"
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const Text(
                                "SCORE",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                p.score.toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ✅ EXIT TO SETUP (NO MORE EMPTY WORD CRASH)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    // ✅ SAFE RESET
                    for (var p in players) {
                      p.isAlive = true;
                      p.word = null;
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MrWhiteSetupScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withValues(alpha: 0.9),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Text(
                      "BACK TO SETUP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
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
}
