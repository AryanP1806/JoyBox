import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_card.dart';
import '../../widgets/party_button.dart';

import 'mafia_models.dart';
import 'mafia_elimination_screen.dart';

class MafiaVotingScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;

  const MafiaVotingScreen({
    super.key,
    required this.players,
    required this.config,
  });

  @override
  State<MafiaVotingScreen> createState() => _MafiaVotingScreenState();
}

class _MafiaVotingScreenState extends State<MafiaVotingScreen> {
  final Map<MafiaPlayer, int> votes = {};
  MafiaPlayer? selected;

  @override
  Widget build(BuildContext context) {
    final alive = widget.players.where((p) => p.isAlive).toList();

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Voting"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ MODE INDICATOR
            PartyCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  widget.config.secretVoting
                      ? "🕶️ SECRET VOTING"
                      : "👥 OPEN VOTING",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ✅ PLAYER LIST
            Expanded(
              child: ListView.builder(
                itemCount: alive.length,
                itemBuilder: (_, i) {
                  final p = alive[i];
                  final isSelected = selected == p;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = p;

                        if (!widget.config.secretVoting) {
                          votes[p] = (votes[p] ?? 0) + 1;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: isSelected ? PartyGradients.dare : null,
                        color: isSelected ? null : PartyColors.card,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.7,
                                  ),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.white70),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ✅ CONFIRM BUTTON
            PartyButton(
              text: "CONFIRM VOTE",
              gradient: PartyGradients.truth,
              onTap: () {
                if (selected == null) return;

                if (widget.config.secretVoting) {
                  votes[selected!] = (votes[selected!] ?? 0) + 1;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MafiaEliminationScreen(
                      players: widget.players,
                      votes: votes,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
