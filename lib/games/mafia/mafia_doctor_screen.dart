import 'package:flutter/material.dart';
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

    // ✅ AUTO-SKIP IF DOCTOR DOES NOT EXIST OR IS DEAD
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

    // ✅ GO TO DETECTIVE IF ALIVE
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
    }
    // ✅ ELSE GO TO NIGHT RESULT
    else {
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

    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Turn")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Only Doctor should see this screen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ...alive.map(
            (p) => ListTile(
              title: Text(p.name),
              trailing: savedPlayer == p ? const Icon(Icons.check) : null,
              onTap: () => setState(() => savedPlayer = p),
            ),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () {
              final detectiveAlive = widget.players.any(
                (p) => p.isAlive && p.role == MafiaRole.detective,
              );

              // ✅ GO TO DETECTIVE IF ALIVE
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
              }
              // ✅ ELSE GO TO NIGHT RESULT
              else {
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
            child: const Text("Confirm Save"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
