import 'package:flutter/material.dart';
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

    // ✅ AUTO-SKIP IF DETECTIVE DOES NOT EXIST OR IS DEAD
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

    return Scaffold(
      appBar: AppBar(title: const Text("Detective Turn")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Only Detective should see this screen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ...alive.map(
            (p) => ListTile(
              title: Text(p.name),
              trailing: investigated == p ? const Icon(Icons.check) : null,
              onTap: () => setState(() => investigated = p),
            ),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () {
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
            child: const Text("Confirm Investigation"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
