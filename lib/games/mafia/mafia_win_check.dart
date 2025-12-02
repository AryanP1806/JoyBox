import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';

import 'mafia_models.dart';
import 'mafia_kill_screen.dart';
import 'mafia_setup.dart';

class MafiaWinCheckScreen extends StatefulWidget {
  final List<MafiaPlayer> players;

  const MafiaWinCheckScreen({super.key, required this.players});

  @override
  State<MafiaWinCheckScreen> createState() => _MafiaWinCheckScreenState();
}

class _MafiaWinCheckScreenState extends State<MafiaWinCheckScreen>
    with SingleTickerProviderStateMixin {
  late int aliveMafia;
  late int aliveCivilians;
  String? winnerText;

  late AnimationController _glowController;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    aliveMafia = widget.players
        .where((p) => p.isAlive && p.role == MafiaRole.mafia)
        .length;

    aliveCivilians = widget.players
        .where((p) => p.isAlive && p.role != MafiaRole.mafia)
        .length;

    if (aliveMafia == 0) {
      winnerText = "CIVILIANS WIN";
    } else if (aliveMafia >= aliveCivilians) {
      winnerText = "MAFIA WINS";
    }

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // ✅ PLAY WIN SOUND ONLY IF GAME ENDED
    if (winnerText != null) {
      _player.play(AssetSource('sounds/win.mp3'));
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PartyColors.background,
      body: Center(
        child: winnerText != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ NEON TROPHY
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PartyColors.accentPink.withValues(
                                alpha: 0.4 + (_glowController.value * 0.4),
                              ),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: const Text("🏆", style: TextStyle(fontSize: 80)),
                  ),

                  const SizedBox(height: 30),

                  PartyCard(
                    child: Column(
                      children: [
                        Text(
                          winnerText!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          winnerText!.contains("MAFIA")
                              ? "Deception wins the night."
                              : "Justice prevails.",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  PartyButton(
                    text: "BACK TO HOME",
                    gradient: PartyGradients.truth,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MafiaSetupScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Next Night",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  PartyButton(
                    text: "START NIGHT",
                    gradient: PartyGradients.dare,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MafiaKillScreen(
                            players: widget.players,
                            config: MafiaGameConfig(
                              players: widget.players
                                  .map((e) => e.name)
                                  .toList(),
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
                  ),
                ],
              ),
      ),
    );
  }
}
