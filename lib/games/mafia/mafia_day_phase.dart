import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_card.dart';
import '../../widgets/party_button.dart';

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
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Day Phase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ NIGHT RESULT CARD
            PartyCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  nightResultText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ ALIVE PLAYERS HEADER
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alive Players",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PartyColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ ALIVE PLAYER LIST
            Expanded(
              child: ListView.builder(
                itemCount: alive.length,
                itemBuilder: (_, i) {
                  final p = alive[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: PartyColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ✅ START VOTING BUTTON
            PartyButton(
              text: "START VOTING",
              gradient: PartyGradients.dare,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MafiaVotingScreen(players: players, config: config),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
