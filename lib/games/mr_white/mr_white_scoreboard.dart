import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_reveal.dart';

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
    if (mrWhiteWonByNumbers) {
      return "MR WHITE WINS BY NUMBERS!";
    }
    if (civiliansWon) {
      return "CIVILIANS WIN!";
    }
    return "ROUND COMPLETE";
  }

  void applyScores() {
    // ✅ YOUR FINAL SCORING RULES

    if (mrWhiteGuessCorrect == true || mrWhiteWonByNumbers) {
      for (var p in players) {
        if (p.role == "mrwhite") p.score += 1;
        if (p.role == "civilian" && p.isAlive) p.score += 1;
      }
    } else if (civiliansWon) {
      for (var p in players) {
        if (p.role == "civilian" && p.isAlive) p.score += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    applyScores();

    return Scaffold(
      appBar: AppBar(title: const Text("Round Result")),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ✅ BIG WINNER DISPLAY AT TOP
          Text(
            winnerText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const Divider(height: 32, thickness: 2),

          const Text("Final Roles & Scores", style: TextStyle(fontSize: 20)),

          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final p = players[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text("Role: ${p.role.toUpperCase()}"),
                  trailing: Text("Score: ${p.score}"),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              // ✅ RESET FOR NEXT ROUND (KEEP PLAYERS + SCORES)
              for (var p in players) {
                p.isAlive = true;
                p.word = null;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MrWhiteRevealScreen(
                    config: MrWhiteGameConfig(
                      playerCount: players.length,
                      mode: MrWhiteMode.mrWhite,
                      specialCount: players
                          .where((p) => p.role != "civilian")
                          .length,
                      useCustomWords: false,
                      timerEnabled: false,
                      timerSeconds: 60,
                      secretVoting: false,
                      playerNames: players.map((e) => e.name).toList(),
                      customWords: const [],
                    ),
                  ),
                ),
              );
            },
            child: const Text("START NEXT ROUND"),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
