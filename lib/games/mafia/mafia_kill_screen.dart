import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../core/safe_nav.dart';

import 'mafia_models.dart';
import 'mafia_doctor_screen.dart';
import 'mafia_detective_screen.dart';
import 'mafia_night_result.dart';
import 'mafia_win_check.dart';

class MafiaKillScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;

  const MafiaKillScreen({
    super.key,
    required this.players,
    required this.config,
  });

  @override
  State<MafiaKillScreen> createState() => _MafiaKillScreenState();
}

class _MafiaKillScreenState extends State<MafiaKillScreen> {
  MafiaPlayer? selectedTarget;

  @override
  Widget build(BuildContext context) {
    final alive = widget.players.where((p) => p.isAlive).toList();
    if (alive.isEmpty) {
      // no one alive → just go to win check
      SafeNav.safeReplace(
        context,
        MafiaWinCheckScreen(players: widget.players),
      );
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Mafia Turn"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Only Mafia should see this screen.\n\nChoose someone to kill tonight.",
              style: TextStyle(
                color: PartyColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Player list
            Expanded(
              child: ListView.builder(
                itemCount: alive.length,
                itemBuilder: (_, i) {
                  final p = alive[i];
                  final isSelected = selectedTarget == p;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.red.withValues(alpha: 0.25)
                          : PartyColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: Colors.redAccent, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: PartyColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.redAccent)
                          : null,
                      onTap: () {
                        setState(() => selectedTarget = p);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ✅ NEVER nullable onTap
            PartyButton(
              text: "CONFIRM KILL",
              gradient: PartyGradients.dare,
              onTap: () {
                if (selectedTarget == null) return;

                final mafiaTarget = selectedTarget!;

                final doctorAlive = widget.players.any(
                  (p) => p.isAlive && p.role == MafiaRole.doctor,
                );

                final detectiveAlive = widget.players.any(
                  (p) => p.isAlive && p.role == MafiaRole.detective,
                );

                if (widget.config.hasDoctor && doctorAlive) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MafiaDoctorScreen(
                        players: widget.players,
                        config: widget.config,
                        mafiaTarget: mafiaTarget,
                      ),
                    ),
                  );
                } else if (widget.config.hasDetective && detectiveAlive) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MafiaDetectiveScreen(
                        players: widget.players,
                        config: widget.config,
                        mafiaTarget: mafiaTarget,
                        doctorSave: null,
                      ),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MafiaNightResultScreen(
                        players: widget.players,
                        config: widget.config,
                        mafiaTarget: mafiaTarget,
                        doctorSave: null,
                        detectiveCheck: null,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
