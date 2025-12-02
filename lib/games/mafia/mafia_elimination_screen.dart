import 'dart:math';
import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';

import 'mafia_models.dart';
import 'mafia_win_check.dart';

class MafiaEliminationScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final Map<MafiaPlayer, int> votes;

  const MafiaEliminationScreen({
    super.key,
    required this.players,
    required this.votes,
  });

  @override
  State<MafiaEliminationScreen> createState() => _MafiaEliminationScreenState();
}

class _MafiaEliminationScreenState extends State<MafiaEliminationScreen>
    with SingleTickerProviderStateMixin {
  late MafiaPlayer eliminated;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // ✅ SAFE ELIMINATION LOGIC
    eliminated = widget.votes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    eliminated.isAlive = false;

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ DRAMATIC TITLE
            const Text(
              "ELIMINATED",
              style: TextStyle(
                fontSize: 26,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 30),

            // ✅ GLOWING ELIMINATION CARD
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(
                          alpha: 0.4 + (_glowController.value * 0.4),
                        ),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: PartyCard(
                child: Column(
                  children: [
                    Text(
                      eliminated.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      eliminated.role.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // ✅ CONTINUE BUTTON
            PartyButton(
              text: "CONTINUE",
              gradient: PartyGradients.truth,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MafiaWinCheckScreen(players: widget.players),
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
