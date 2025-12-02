import 'package:flutter/material.dart';
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
  String resultText = "";

  @override
  void initState() {
    super.initState();
    _resolveNight();
  }

  void _resolveNight() {
    if (widget.mafiaTarget == widget.doctorSave) {
      resultText =
          "${widget.mafiaTarget.name} was attacked but SAVED by the Doctor!";
    } else {
      widget.mafiaTarget.isAlive = false;
      resultText = "${widget.mafiaTarget.name} was KILLED by the Mafia.";
    }

    // ✅ IMMEDIATE WIN CHECK AFTER NIGHT
    final aliveMafia = widget.players
        .where((p) => p.isAlive && p.role == MafiaRole.mafia)
        .length;

    final aliveCivilians = widget.players
        .where((p) => p.isAlive && p.role != MafiaRole.mafia)
        .length;

    if (aliveMafia >= aliveCivilians) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MafiaWinCheckScreen(players: widget.players),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detective = widget.players.firstWhere(
      (p) => p.role == MafiaRole.detective,
      orElse: () => MafiaPlayer(name: "None", role: MafiaRole.civilian),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Night Result")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              resultText,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (widget.detectiveCheck != null &&
                detective.role == MafiaRole.detective)
              Text(
                "Detective Result:\n${widget.detectiveCheck!.name} is ${widget.detectiveCheck!.role == MafiaRole.mafia ? "MAFIA" : "NOT MAFIA"}",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
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
              },
              child: const Text("Continue to Day"),
            ),
          ],
        ),
      ),
    );
  }
}
