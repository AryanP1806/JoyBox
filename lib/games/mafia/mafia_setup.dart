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

  // ✅ HOW TO PLAY POPUP
  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("How to Play Mafia"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Mafia secretly kills one player each night."),
              SizedBox(height: 6),
              Text("• Doctor can save one player."),
              SizedBox(height: 6),
              Text("• Detective can investigate one player."),
              SizedBox(height: 6),
              Text("• Day phase: Everyone votes to eliminate one suspect."),
              SizedBox(height: 6),
              Text("• If all Mafia die → Civilians win."),
              SizedBox(height: 6),
              Text("• If Mafia equals Civilians → Mafia wins."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mafia Setup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHowToPlay,
          ),
        ],
      ),
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

            const SizedBox(height: 12),
            const Text("Player Names"),

            ...List.generate(playerCount, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: nameControllers[i],
                  decoration: InputDecoration(
                    hintText: "Player ${i + 1}",
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),

            const Divider(height: 36),

            const Text("Roles", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Row(
              children: [
                const Text("Mafia Count"),
                const SizedBox(width: 12),
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

            const Divider(height: 36),

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
