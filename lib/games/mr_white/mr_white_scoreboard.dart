// lib/games/mr_white/mr_white_scoreboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- ADDED
import '../../auth/auth_service.dart'; // <--- ADDED
import 'mr_white_models.dart';
import 'mr_white_setup.dart';
import '../../core/safe_nav.dart';

class MrWhiteScoreBoardScreen extends StatefulWidget {
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

  @override
  State<MrWhiteScoreBoardScreen> createState() =>
      _MrWhiteScoreBoardScreenState();
}

class _MrWhiteScoreBoardScreenState extends State<MrWhiteScoreBoardScreen> {
  bool _scoresApplied = false;

  @override
  void initState() {
    super.initState();
    // ✅ Apply scores and save game when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scoresApplied) {
        _applyScores();
        _saveGame(); // <--- Trigger Save
        setState(() {
          _scoresApplied = true;
        });
      }
    });
  }

  String get winnerText {
    if (widget.mrWhiteGuessCorrect == true) {
      return "MR WHITE WINS BY GUESS!";
    }
    if (widget.mrWhiteGuessCorrect == false) {
      return "CIVILIANS WIN!";
    }
    if (widget.mrWhiteWonByNumbers) {
      return "MR WHITE WINS BY NUMBERS!";
    }
    if (widget.civiliansWon) {
      return "CIVILIANS WIN!";
    }
    return "ROUND COMPLETE";
  }

  // ✅ NEW: Save Game Logic
  Future<void> _saveGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Determine if Civilians won (User wins if Civilians win)
    bool civiliansWonGame = false;
    if (widget.mrWhiteGuessCorrect == false || widget.civiliansWon) {
      civiliansWonGame = true;
    }

    await AuthService().addGameHistory(
      gameName: "Mr. White",
      won: civiliansWonGame,
      details: {
        "winner": civiliansWonGame ? "Civilians" : "Mr. White",
        "win_reason": winnerText,
        "player_count": widget.players.length,
      },
    );

    await AuthService().updateGameStats(won: civiliansWonGame);
  }

  void _applyScores() {
    // Mr White wins (either by correct guess or by numbers)
    if (widget.mrWhiteGuessCorrect == true || widget.mrWhiteWonByNumbers) {
      for (var p in widget.players) {
        if (p.role == "mrwhite") p.score += 2;
      }
      return;
    }

    // Civilians win
    if (widget.mrWhiteGuessCorrect == false || widget.civiliansWon) {
      for (var p in widget.players) {
        if (p.role == "civilian") p.score += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
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

              // WINNER TITLE
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

              // FINAL ROLE + SCORE LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) {
                    final p = widget.players[index];
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

              // EXIT TO SETUP
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    // Reset round state
                    for (var p in widget.players) {
                      p.isAlive = true;
                      p.word = null;
                    }
                    Navigator.pop(context);
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
