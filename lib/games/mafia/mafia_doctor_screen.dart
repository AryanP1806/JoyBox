import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';

import 'mafia_models.dart';
import 'mafia_detective_screen.dart';
import 'mafia_night_result.dart';

class MafiaDoctorScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;
  final MafiaPlayer mafiaTarget;

  const MafiaDoctorScreen({
    super.key,
    required this.players,
    required this.config,
    required this.mafiaTarget,
  });

  @override
  State<MafiaDoctorScreen> createState() => _MafiaDoctorScreenState();
}

class _MafiaDoctorScreenState extends State<MafiaDoctorScreen> {
  MafiaPlayer? savedPlayer;

  @override
  void initState() {
    super.initState();

    final doctorAlive = widget.players.any(
      (p) => p.isAlive && p.role == MafiaRole.doctor,
    );

    if (!widget.config.hasDoctor || !doctorAlive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _skipDoctor();
      });
    }
  }

  void _skipDoctor() {
    final detectiveAlive = widget.players.any(
      (p) => p.isAlive && p.role == MafiaRole.detective,
    );

    if (widget.config.hasDetective && detectiveAlive) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MafiaDetectiveScreen(
            players: widget.players,
            config: widget.config,
            mafiaTarget: widget.mafiaTarget,
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
            mafiaTarget: widget.mafiaTarget,
            doctorSave: null,
            detectiveCheck: null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alive = widget.players.where((p) => p.isAlive).toList();
    if (alive.isEmpty) {
      _skipDoctor(); // or _skipDetective();
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Doctor Turn"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Only Doctor should see this screen.\n\nChoose one player to save tonight.",
              style: TextStyle(
                color: PartyColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: alive.length,
                itemBuilder: (_, i) {
                  final p = alive[i];
                  final isSelected = savedPlayer == p;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withValues(alpha: 0.25)
                          : PartyColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: Colors.greenAccent, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.favorite,
                        color: Colors.greenAccent,
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: PartyColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.greenAccent)
                          : null,
                      onTap: () {
                        setState(() => savedPlayer = p);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            PartyButton(
              text: "CONFIRM SAVE",
              gradient: PartyGradients.truth,
              onTap: () {
                final detectiveAlive = widget.players.any(
                  (p) => p.isAlive && p.role == MafiaRole.detective,
                );

                if (widget.config.hasDetective && detectiveAlive) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MafiaDetectiveScreen(
                        players: widget.players,
                        config: widget.config,
                        mafiaTarget: widget.mafiaTarget,
                        doctorSave: savedPlayer,
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
                        mafiaTarget: widget.mafiaTarget,
                        doctorSave: savedPlayer,
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
