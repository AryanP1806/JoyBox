import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- ADDED

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';
import '../../core/safe_nav.dart';
import '../../auth/auth_service.dart'; // <--- ADDED
import 'mafia_settings_cache.dart';
import 'mafia_models.dart';
import 'mafia_kill_screen.dart';
// import 'mafia_setup.dart';

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
    } else if (aliveMafia >= aliveCivilians && aliveCivilians > 0) {
      winnerText = "MAFIA WINS";
    }

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    if (winnerText != null) {
      _player.play(AssetSource('sounds/win.mp3'));

      // ✅ TRIGGER SAVE WHEN GAME ENDS
      _saveGame();
    }
  }

  // ✅ NEW: Save Logic
  Future<void> _saveGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bool civiliansWon = winnerText == "CIVILIANS WIN";

    // Count stats
    final totalPlayers = widget.players.length;
    final survivors = widget.players.where((p) => p.isAlive).length;
    final deadCount = totalPlayers - survivors;

    await AuthService().addGameHistory(
      gameName: "Mafia",
      won:
          civiliansWon, // You count as "winning" if Civilians win (co-op style)
      details: {
        "winner": civiliansWon ? "Civilians" : "Mafia",
        "total_players": totalPlayers,
        "survivors": survivors,
        "casualties": deadCount,
        "mafia_alive": aliveMafia,
      },
    );

    await AuthService().updateGameStats(won: civiliansWon);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Navigator.pop(context);
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
