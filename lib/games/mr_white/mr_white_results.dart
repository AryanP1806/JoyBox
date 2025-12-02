import 'package:flutter/material.dart';
import 'mr_white_models.dart';

class MrWhiteResultsScreen extends StatelessWidget {
  final List<MrWhitePlayer> players;
  final MrWhiteGameConfig config;

  const MrWhiteResultsScreen({
    super.key,
    required this.players,
    required this.config,
  });

  int get aliveCivilians =>
      players.where((p) => p.role == "civilian" && p.isAlive).length;

  int get aliveSpecials =>
      players.where((p) => p.role != "civilian" && p.isAlive).length;

  bool get gameOver => aliveSpecials == 0 || aliveSpecials >= aliveCivilians;

  String get winner {
    if (!gameOver) return "NO WINNER YET";

    if (aliveSpecials == 0) {
      return "CIVILIANS WIN!";
    } else {
      return config.mode == MrWhiteMode.mrWhite
          ? "MR WHITE WINS!"
          : "UNDERCOVER WINS!";
    }
  }

  void applyScores() {
    if (!gameOver) return;

    if (aliveSpecials == 0) {
      for (var p in players) {
        if (p.role == "civilian") {
          p.score += 2;
        }
      }
    } else {
      for (var p in players) {
        if (p.role != "civilian") {
          p.score += 3;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    applyScores();

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
              const SizedBox(height: 16),

              // ✅ TITLE
              const Text(
                "ROUND RESULT",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ✅ WINNER BANNER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: gameOver
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFAAAAAA), Color(0xFF666666)],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  winner,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ✅ PLAYER SCOREBOARD
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
                          // Name + Status
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
                                  p.isAlive ? "Alive" : "Eliminated",
                                  style: TextStyle(
                                    color: p.isAlive
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Score
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

              // ✅ MAIN ACTION BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    if (!gameOver) {
                      Navigator.pop(context); // Next round
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            "FINAL ROLES",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: players
                                  .map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        "${p.name} → ${p.role.toUpperCase()}",
                                        style: TextStyle(
                                          color: p.role == "civilian"
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.popUntil(context, (r) => r.isFirst);
                              },
                              child: const Text(
                                "EXIT GAME",
                                style: TextStyle(color: Colors.amber),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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
                    child: Text(
                      gameOver ? "REVEAL ROLES & EXIT" : "NEXT ROUND",
                      style: const TextStyle(
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
