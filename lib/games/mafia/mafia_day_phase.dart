import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_voting_screen.dart';

class MafiaDayPhaseScreen extends StatelessWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;
  final String nightResultText;

  const MafiaDayPhaseScreen({
    super.key,
    required this.players,
    required this.config,
    required this.nightResultText,
  });

  @override
  Widget build(BuildContext context) {
    final alive = players.where((p) => p.isAlive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Day Phase")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              nightResultText,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),
            const Text("Alive Players", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            ...alive.map((p) => ListTile(title: Text(p.name))),

            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MafiaVotingScreen(players: players, config: config),
                  ),
                );
              },
              child: const Text("Start Voting"),
            ),
          ],
        ),
      ),
    );
  }
}
