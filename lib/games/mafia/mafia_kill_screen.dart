import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_doctor_screen.dart';
import 'mafia_detective_screen.dart';
import 'mafia_night_result.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text("Mafia Turn")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Only Mafia should see this screen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ...alive.map(
            (p) => ListTile(
              title: Text(p.name),
              trailing: selectedTarget == p ? const Icon(Icons.check) : null,
              onTap: () => setState(() => selectedTarget = p),
            ),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: selectedTarget == null
                ? null
                : () {
                    final doctorAlive = widget.players.any(
                      (p) => p.isAlive && p.role == MafiaRole.doctor,
                    );

                    final detectiveAlive = widget.players.any(
                      (p) => p.isAlive && p.role == MafiaRole.detective,
                    );

                    // ✅ GO TO DOCTOR ONLY IF ENABLED + ALIVE
                    if (widget.config.hasDoctor && doctorAlive) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MafiaDoctorScreen(
                            players: widget.players,
                            config: widget.config,
                            mafiaTarget: selectedTarget!,
                          ),
                        ),
                      );
                    }
                    // ✅ ELSE GO TO DETECTIVE ONLY IF ENABLED + ALIVE
                    else if (widget.config.hasDetective && detectiveAlive) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MafiaDetectiveScreen(
                            players: widget.players,
                            config: widget.config,
                            mafiaTarget: selectedTarget!,
                            doctorSave: null,
                          ),
                        ),
                      );
                    }
                    // ✅ ELSE SKIP DIRECTLY TO NIGHT RESULT
                    else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MafiaNightResultScreen(
                            players: widget.players,
                            config: widget.config,
                            mafiaTarget: selectedTarget!,
                            doctorSave: null,
                            detectiveCheck: null,
                          ),
                        ),
                      );
                    }
                  },
            child: const Text("Confirm Kill"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
