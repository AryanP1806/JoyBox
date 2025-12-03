import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../audio/sound_manager.dart';

import '../../theme/party_theme.dart';
import 'truth_dare_models.dart';
import 'truth_dare_setup_screen.dart';

class TruthDareResultsScreen extends StatefulWidget {
  final List<TruthDarePlayer> players;

  const TruthDareResultsScreen({super.key, required this.players});

  @override
  State<TruthDareResultsScreen> createState() => _TruthDareResultsScreenState();
}

class _TruthDareResultsScreenState extends State<TruthDareResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    )..play();
    SoundManager.playWin();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ HARD SAFETY: if somehow empty, force setup
    if (widget.players.isEmpty) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TruthDareSetupScreen()),
        );
      });
      return const Scaffold();
    }

    final sortedPlayers = [...widget.players]
      ..sort((a, b) => b.score.compareTo(a.score));

    final winner = sortedPlayers.first;

    return PopScope(
      canPop: false, // ✅ BLOCK SYSTEM BACK
      onPopInvoked: (_) {
        // ✅ ALWAYS GO TO SETUP, NEVER HOME
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TruthDareSetupScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: PartyColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false, // ✅ prevents auto back button
          backgroundColor: PartyColors.background,
          title: const Text("Results"),
        ),
        body: Stack(
          children: [
            // ✅ CONFETTI
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),

            // ✅ CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ WINNER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.9),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("🏆", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 6),
                        const Text(
                          "WINNER",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          winner.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Score: ${winner.score}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ LEADERBOARD
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedPlayers.length,
                      itemBuilder: (_, i) {
                        final p = sortedPlayers[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: PartyColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "#${i + 1}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(p.name)),
                              Text(
                                p.score.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ✅ PLAY AGAIN (SETUP ONLY)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TruthDareSetupScreen(),
                          ),
                        );
                      },
                      child: const Text("PLAY AGAIN"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
