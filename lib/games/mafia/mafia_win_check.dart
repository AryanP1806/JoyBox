import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_kill_screen.dart';
import 'mafia_setup.dart';

class MafiaWinCheckScreen extends StatelessWidget {
  final List<MafiaPlayer> players;

  const MafiaWinCheckScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final aliveMafia = players
        .where((p) => p.isAlive && p.role == MafiaRole.mafia)
        .length;

    final aliveCivilians = players
        .where((p) => p.isAlive && p.role != MafiaRole.mafia)
        .length;

    String? winner;

    if (aliveMafia == 0) {
      winner = "CIVILIANS WIN!";
    } else if (aliveMafia >= aliveCivilians) {
      winner = "MAFIA WINS!";
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Game Status")),
      body: Center(
        child: winner != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    winner,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MafiaSetupScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("Back to Home"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Next Night", style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MafiaKillScreen(
                            players: players,
                            config: MafiaGameConfig(
                              players: players.map((e) => e.name).toList(),
                              mafiaCount: 1,
                              hasDoctor: true,
                              hasDetective: true,
                              secretVoting: false,
                              timerEnabled: false,
                              timerSeconds: 60,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text("Start Night"),
                  ),
                ],
              ),
      ),
    );
  }
}
