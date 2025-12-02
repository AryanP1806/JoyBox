import 'package:flutter/material.dart';
import 'mafia_models.dart';

class MafiaNightPhaseScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;

  const MafiaNightPhaseScreen({
    super.key,
    required this.players,
    required this.config,
  });

  @override
  State<MafiaNightPhaseScreen> createState() => _MafiaNightPhaseScreenState();
}

class _MafiaNightPhaseScreenState extends State<MafiaNightPhaseScreen> {
  MafiaPlayer? mafiaTarget;
  MafiaPlayer? doctorSave;
  MafiaPlayer? detectiveCheck;

  void _applyNightActions() {
    // ✅ Mafia kills
    if (mafiaTarget != null && mafiaTarget != doctorSave) {
      mafiaTarget!.isAlive = false;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final alivePlayers = widget.players.where((p) => p.isAlive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Night Phase")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Mafia Select Kill", style: TextStyle(fontSize: 18)),
          ...alivePlayers.map(
            (p) => ListTile(
              title: Text(p.name),
              trailing: mafiaTarget == p ? const Icon(Icons.check) : null,
              onTap: () => setState(() => mafiaTarget = p),
            ),
          ),

          if (widget.config.hasDoctor) ...[
            const Divider(height: 30),
            const Text("Doctor Save", style: TextStyle(fontSize: 18)),
            ...alivePlayers.map(
              (p) => ListTile(
                title: Text(p.name),
                trailing: doctorSave == p ? const Icon(Icons.check) : null,
                onTap: () => setState(() => doctorSave = p),
              ),
            ),
          ],

          if (widget.config.hasDetective) ...[
            const Divider(height: 30),
            const Text("Detective Investigate", style: TextStyle(fontSize: 18)),
            ...alivePlayers.map(
              (p) => ListTile(
                title: Text(p.name),
                trailing: detectiveCheck == p ? const Icon(Icons.check) : null,
                onTap: () => setState(() => detectiveCheck = p),
              ),
            ),
          ],

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _applyNightActions,
            child: const Text("End Night"),
          ),
        ],
      ),
    );
  }
}
