import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_final_guess.dart';
import 'mr_white_scoreboard.dart';
import 'mr_white_discussion.dart';

class MrWhiteRoleRevealScreen extends StatelessWidget {
  final MrWhitePlayer eliminatedPlayer;
  final List<MrWhitePlayer> players;
  final MrWhiteGameConfig config;

  const MrWhiteRoleRevealScreen({
    super.key,
    required this.eliminatedPlayer,
    required this.players,
    required this.config,
  });

  int get aliveCivilians =>
      players.where((p) => p.role == "civilian" && p.isAlive).length;

  int get aliveSpecial =>
      players.where((p) => p.role != "civilian" && p.isAlive).length;

  void _continue(BuildContext context) {
    final isMrWhite = eliminatedPlayer.role == "mrwhite";

    // If Mr White eliminated → final guess
    if (isMrWhite) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MrWhiteFinalGuessScreen(players: players),
        ),
      );
      return;
    }

    // Auto win conditions
    if (aliveSpecial >= aliveCivilians) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MrWhiteScoreBoardScreen(
            players: players,
            mrWhiteWonByNumbers: true,
          ),
        ),
      );
      return;
    }

    if (aliveSpecial == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MrWhiteScoreBoardScreen(players: players, civiliansWon: true),
        ),
      );
      return;
    }

    // Otherwise next round: back to Discussion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MrWhiteDiscussionScreen(players: players, config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleText = eliminatedPlayer.role.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eliminatedPlayer.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 26),
                ),
                const SizedBox(height: 16),
                Text(
                  roleText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: eliminatedPlayer.role == "civilian"
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "was eliminated!",
                  style: TextStyle(color: Colors.white54, fontSize: 20),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _continue(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text("CONTINUE", style: TextStyle(fontSize: 18)),
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
