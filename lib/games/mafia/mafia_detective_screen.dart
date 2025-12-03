import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';

import 'mafia_models.dart';
import 'mafia_night_result.dart';

class MafiaDetectiveScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;
  final MafiaPlayer mafiaTarget;
  final MafiaPlayer? doctorSave;

  const MafiaDetectiveScreen({
    super.key,
    required this.players,
    required this.config,
    required this.mafiaTarget,
    required this.doctorSave,
  });

  @override
  State<MafiaDetectiveScreen> createState() => _MafiaDetectiveScreenState();
}

class _MafiaDetectiveScreenState extends State<MafiaDetectiveScreen> {
  MafiaPlayer? investigated;

  @override
  void initState() {
    super.initState();

    final detectiveAlive = widget.players.any(
      (p) => p.isAlive && p.role == MafiaRole.detective,
    );

    if (!widget.config.hasDetective || !detectiveAlive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _skipDetective();
      });
    }
  }

  void _skipDetective() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MafiaNightResultScreen(
          players: widget.players,
          config: widget.config,
          mafiaTarget: widget.mafiaTarget,
          doctorSave: widget.doctorSave,
          detectiveCheck: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alive = widget.players.where((p) => p.isAlive).toList();
    if (alive.isEmpty) {
      _skipDetective(); // or _skipDetective();
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Detective Turn"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Only Detective should see this screen.\n\nPick one player to investigate.",
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
                  final isSelected = investigated == p;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyan.withValues(alpha: 0.25)
                          : PartyColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: Colors.cyanAccent, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.search,
                        color: Colors.cyanAccent,
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: PartyColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.cyanAccent)
                          : null,
                      onTap: () {
                        setState(() => investigated = p);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            PartyButton(
              text: "CONFIRM INVESTIGATION",
              gradient: PartyGradients.dare,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MafiaNightResultScreen(
                      players: widget.players,
                      config: widget.config,
                      mafiaTarget: widget.mafiaTarget,
                      doctorSave: widget.doctorSave,
                      detectiveCheck: investigated,
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
