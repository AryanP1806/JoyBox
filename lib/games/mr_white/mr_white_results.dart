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
    if (!gameOver) return "No Winner Yet";

    if (aliveSpecials == 0) {
      return "Civilians Win!";
    } else {
      return config.mode == MrWhiteMode.mrWhite
          ? "Mr White Wins!"
          : "Undercover Wins!";
    }
  }

  void applyScores() {
    if (!gameOver) return;

    if (aliveSpecials == 0) {
      for (var p in players) {
        if (p.role == "civilian") p.score += 2;
      }
    } else {
      for (var p in players) {
        if (p.role != "civilian") p.score += 3;
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
          Text(
            winner,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final p = players[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(p.isAlive ? "Alive" : "Eliminated"),
                  trailing: Text("Score: ${p.score}"),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (!gameOver) {
                Navigator.pop(context);
              } else {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Final Roles"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: players
                          .map(
                            (p) => Text("${p.name} → ${p.role.toUpperCase()}"),
                          )
                          .toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.popUntil(context, (r) => r.isFirst);
                        },
                        child: const Text("Exit"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(gameOver ? "Reveal Roles & Exit" : "Next Round"),
          ),
        ],
      ),
    );
  }
}
