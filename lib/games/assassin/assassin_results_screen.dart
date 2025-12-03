// lib/games/assassin/assassin_results_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../../core/safe_nav.dart';
import '../../theme/party_theme.dart';
import '../../widgets/party_card.dart';
import '../../widgets/party_button.dart';
import '../../audio/sound_manager.dart';

import 'assassin_models.dart';
import 'assassin_setup_screen.dart';

class AssassinResultsScreen extends StatefulWidget {
  final List<AssassinPlayer> players;
  final AssassinWinner winner;
  final AssassinGameConfig config; // ✅ keep last settings

  const AssassinResultsScreen({
    super.key,
    required this.players,
    required this.winner,
    required this.config,
  });

  @override
  State<AssassinResultsScreen> createState() => _AssassinResultsScreenState();
}

class _AssassinResultsScreenState extends State<AssassinResultsScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4))
      ..play();

    SoundManager.playWin();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }

    final assassin = widget.players.firstWhere(
      (p) => p.role == AssassinRole.assassin,
      orElse: () =>
          AssassinPlayer(name: "Unknown", role: AssassinRole.assassin),
    );

    final detective = widget.players.firstWhere(
      (p) => p.role == AssassinRole.detective,
      orElse: () =>
          AssassinPlayer(name: "Unknown", role: AssassinRole.detective),
    );

    final winnerText = widget.winner == AssassinWinner.civilians
        ? "CIVILIANS WIN!"
        : "ASSASSIN WINS!";

    final subText = widget.winner == AssassinWinner.civilians
        ? "Detective ${detective.name} exposed the Assassin."
        : "Assassin ${assassin.name} eliminated everyone.";

    return Scaffold(
      backgroundColor: PartyColors.background,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 32),
                PartyCard(
                  child: Column(
                    children: [
                      const Text("🏆", style: TextStyle(fontSize: 50)),
                      const SizedBox(height: 10),
                      Text(
                        winnerText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Roles",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.players.length,
                    itemBuilder: (_, i) {
                      final p = widget.players[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: PartyColors.card,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              _roleLabel(p.role),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _roleColor(p.role),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                PartyButton(
                  text: "PLAY AGAIN",
                  gradient: PartyGradients.truth,
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) =>
                            AssassinSetupScreen(lastConfig: widget.config),
                      ),
                      (route) => route.isFirst, // ✅ KEEP HOME ONLY
                    );
                  },
                ),

                const SizedBox(height: 10),
                PartyButton(
                  text: "BACK TO HOME",
                  gradient: PartyGradients.dare,
                  onTap: () => SafeNav.goHome(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(AssassinRole role) {
    switch (role) {
      case AssassinRole.assassin:
        return "ASSASSIN";
      case AssassinRole.detective:
        return "DETECTIVE";
      case AssassinRole.citizen:
        return "CIVILIAN";
    }
  }

  Color _roleColor(AssassinRole role) {
    switch (role) {
      case AssassinRole.assassin:
        return Colors.redAccent;
      case AssassinRole.detective:
        return Colors.cyanAccent;
      case AssassinRole.citizen:
        return Colors.greenAccent;
    }
  }
}
