import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';
import '../../core/safe_nav.dart';
import 'mafia_settings_cache.dart';
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

    // ✅ Basic safety: if somehow empty, just bail out in build()
    aliveMafia = widget.players
        .where((p) => p.isAlive && p.role == MafiaRole.mafia)
        .length;

    aliveCivilians = widget.players
        .where((p) => p.isAlive && p.role != MafiaRole.mafia)
        .length;

    if (aliveMafia == 0) {
      winnerText = "CIVILIANS WIN";
    } else if (aliveMafia >= aliveCivilians && aliveCivilians > 0) {
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
    // ✅ Hard safety: if something went wrong and list is empty, go home
    if (widget.players.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: PartyColors.background,
      body: Center(
        child: winnerText != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🏆 NEON TROPHY
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
                          textAlign: TextAlign.center,
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
                          textAlign: TextAlign.center,
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
                      // SafeNav.goHome(context);
                      Navigator.pop(context);
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const MafiaSetupScreen(),
                      //   ),
                      //   (route) => false,
                      // );
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
                      final names = widget.players.map((p) => p.name).toList();

                      final mafiaCount = widget.players
                          .where((p) => p.role == MafiaRole.mafia)
                          .length;

                      final hasDoctor = widget.players.any(
                        (p) => p.role == MafiaRole.doctor,
                      );
                      final hasDetective = widget.players.any(
                        (p) => p.role == MafiaRole.detective,
                      );

                      // ✅ pull options from cache, fall back to sensible defaults
                      final secretVoting =
                          MafiaSettingsCache.secretVoting ?? false;
                      final timerEnabled =
                          MafiaSettingsCache.timerEnabled ?? false;
                      final timerSeconds =
                          MafiaSettingsCache.timerSeconds ?? 60;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MafiaKillScreen(
                            players: widget.players,
                            config: MafiaGameConfig(
                              players: names,
                              mafiaCount: mafiaCount.clamp(1, names.length - 1),
                              hasDoctor: hasDoctor,
                              hasDetective: hasDetective,
                              secretVoting: secretVoting,
                              timerEnabled: timerEnabled,
                              timerSeconds: timerSeconds,
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
