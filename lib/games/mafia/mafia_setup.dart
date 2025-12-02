import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_role_reveal.dart';

class MafiaSetupScreen extends StatefulWidget {
  const MafiaSetupScreen({super.key});

  @override
  State<MafiaSetupScreen> createState() => _MafiaSetupScreenState();
}

class _MafiaSetupScreenState extends State<MafiaSetupScreen> {
  int playerCount = 6;
  final List<TextEditingController> nameControllers = [];

  int mafiaCount = 1;
  bool hasDoctor = true;
  bool hasDetective = true;

  bool secretVoting = false;
  bool timerEnabled = false;
  int timerSeconds = 60;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    while (nameControllers.length < playerCount) {
      nameControllers.add(TextEditingController());
    }
    while (nameControllers.length > playerCount) {
      nameControllers.removeLast();
    }
  }

  List<String> _buildFinalPlayerNames() {
    return List.generate(playerCount, (i) {
      final text = nameControllers[i].text.trim();
      return text.isEmpty ? "Player ${i + 1}" : text;
    });
  }

  void _startGame() {
    if (mafiaCount >= playerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mafia must be LESS than total players")),
      );
      return;
    }

    final config = MafiaGameConfig(
      players: _buildFinalPlayerNames(),
      mafiaCount: mafiaCount,
      hasDoctor: hasDoctor,
      hasDetective: hasDetective,
      secretVoting: secretVoting,
      timerEnabled: timerEnabled,
      timerSeconds: timerSeconds,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MafiaRoleRevealScreen(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mafia Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Number of Players", style: TextStyle(fontSize: 18)),

            Slider(
              value: playerCount.toDouble(),
              min: 4,
              max: 15,
              divisions: 11,
              label: playerCount.toString(),
              onChanged: (v) {
                setState(() {
                  playerCount = v.toInt();
                  if (mafiaCount >= playerCount) mafiaCount = 1;
                  _syncControllers();
                });
              },
            ),

            const SizedBox(height: 10),
            const Text("Optional Player Names"),

            ...List.generate(playerCount, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: nameControllers[i],
                  decoration: InputDecoration(hintText: "Player ${i + 1}"),
                ),
              );
            }),

            const Divider(height: 30),

            const Text("Roles", style: TextStyle(fontSize: 18)),

            Row(
              children: [
                const Text("Mafia Count"),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: mafiaCount,
                  onChanged: (v) => setState(() => mafiaCount = v!),
                  items: List.generate(playerCount - 1, (i) => i + 1)
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString()),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),

            SwitchListTile(
              value: hasDoctor,
              onChanged: (v) => setState(() => hasDoctor = v),
              title: const Text("Enable Doctor"),
            ),

            SwitchListTile(
              value: hasDetective,
              onChanged: (v) => setState(() => hasDetective = v),
              title: const Text("Enable Detective"),
            ),

            const Divider(height: 30),

            const Text("Game Settings", style: TextStyle(fontSize: 18)),

            SwitchListTile(
              value: secretVoting,
              onChanged: (v) => setState(() => secretVoting = v),
              title: const Text("Secret Voting"),
            ),

            SwitchListTile(
              value: timerEnabled,
              onChanged: (v) => setState(() => timerEnabled = v),
              title: const Text("Enable Timer"),
            ),

            if (timerEnabled)
              Slider(
                value: timerSeconds.toDouble(),
                min: 30,
                max: 180,
                divisions: 5,
                label: "$timerSeconds sec",
                onChanged: (v) => setState(() => timerSeconds = v.toInt()),
              ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Text("START MAFIA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
