import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_card.dart';
import '../../widgets/party_button.dart';
import '../../core/safe_nav.dart';

import 'mafia_models.dart';
import 'mafia_day_phase.dart';
import 'mafia_win_check.dart';

class MafiaNightResultScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;
  final MafiaPlayer mafiaTarget;
  final MafiaPlayer? doctorSave;
  final MafiaPlayer? detectiveCheck;

  const MafiaNightResultScreen({
    super.key,
    required this.players,
    required this.config,
    required this.mafiaTarget,
    required this.doctorSave,
    required this.detectiveCheck,
  });

  @override
  State<MafiaNightResultScreen> createState() => _MafiaNightResultScreenState();
}

class _MafiaNightResultScreenState extends State<MafiaNightResultScreen> {
  late String resultText;
  bool mafiaWon = false;

  @override
  void initState() {
    super.initState();
    _resolveNight();
  }

  void _resolveNight() {
    if (widget.mafiaTarget == widget.doctorSave) {
      resultText =
          "🩺 ${widget.mafiaTarget.name} was attacked\nbut SAVED by the Doctor!";
    } else {
      widget.mafiaTarget.isAlive = false;
      resultText = "💀 ${widget.mafiaTarget.name} was KILLED by the Mafia!";
    }

    final aliveMafia = widget.players
        .where((p) => p.isAlive && p.role == MafiaRole.mafia)
        .length;

    final aliveCivilians = widget.players
        .where((p) => p.isAlive && p.role != MafiaRole.mafia)
        .length;

    mafiaWon = aliveMafia >= aliveCivilians;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Night Result"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ✅ MAIN RESULT CARD
            PartyCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      resultText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    if (widget.detectiveCheck != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        "🕵️ Detective Result",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${widget.detectiveCheck!.name} is "
                        "${widget.detectiveCheck!.role == MafiaRole.mafia ? "✅ MAFIA" : "❌ NOT MAFIA"}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ✅ CONTINUE BUTTON
            PartyButton(
              text: "CONTINUE",
              gradient: PartyGradients.truth,
              onTap: () {
                if (mafiaWon) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MafiaWinCheckScreen(players: widget.players),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MafiaDayPhaseScreen(
                        players: widget.players,
                        config: widget.config,
                        nightResultText: resultText,
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
