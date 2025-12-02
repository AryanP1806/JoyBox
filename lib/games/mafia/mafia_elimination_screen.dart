import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_win_check.dart';

class MafiaEliminationScreen extends StatelessWidget {
  final List<MafiaPlayer> players;
  final Map<MafiaPlayer, int> votes;

  const MafiaEliminationScreen({
    super.key,
    required this.players,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    final eliminated = votes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    eliminated.isAlive = false;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              eliminated.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              eliminated.role.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MafiaWinCheckScreen(players: players),
                  ),
                );
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
