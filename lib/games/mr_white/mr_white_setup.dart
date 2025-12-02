import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_word_select.dart';

class MrWhiteSetupScreen extends StatefulWidget {
  const MrWhiteSetupScreen({super.key});

  @override
  State<MrWhiteSetupScreen> createState() => _MrWhiteSetupScreenState();
}

class _MrWhiteSetupScreenState extends State<MrWhiteSetupScreen> {
  int playerCount = 3;
  int specialCount = 1;
  bool useCustomWords = false;
  bool timerEnabled = false;
  bool secretVoting = false;
  int timerSeconds = 60;

  final List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    updateControllers();
  }

  void updateControllers() {
    nameControllers.clear();
    for (int i = 0; i < playerCount; i++) {
      nameControllers.add(TextEditingController());
    }
  }

  void startGame() {
    final names = <String>[];

    for (int i = 0; i < nameControllers.length; i++) {
      final text = nameControllers[i].text.trim();
      names.add(text.isEmpty ? "Player ${i + 1}" : text);
    }

    final config = MrWhiteGameConfig(
      playerCount: playerCount,
      mode: MrWhiteMode.mrWhite,
      specialCount: specialCount,
      useCustomWords: useCustomWords,
      timerEnabled: timerEnabled,
      timerSeconds: timerSeconds, // ✅ FIXED
      secretVoting: secretVoting, // ✅ FIXED
      playerNames: names,
      customWords: const [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MrWhiteWordSelectScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mr White Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Players (3–15)"),
            Slider(
              min: 3,
              max: 15,
              divisions: 12,
              value: playerCount.toDouble(),
              label: playerCount.toString(),
              onChanged: (v) {
                setState(() {
                  playerCount = v.toInt();
                  updateControllers();
                });
              },
            ),

            const SizedBox(height: 10),
            const Text("Mr White / Undercover Count (1–5)"),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: specialCount.toDouble(),
              label: specialCount.toString(),
              onChanged: (v) {
                setState(() => specialCount = v.toInt());
              },
            ),

            const Divider(),

            const Text("Player Names"),
            ...nameControllers.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: c,
                  decoration: const InputDecoration(
                    hintText: "Leave empty for auto name",
                  ),
                ),
              ),
            ),

            const Divider(),

            SwitchListTile(
              title: const Text("Use Custom Words"),
              value: useCustomWords,
              onChanged: (v) => setState(() => useCustomWords = v),
            ),

            SwitchListTile(
              title: const Text("Enable Timer"),
              value: timerEnabled,
              onChanged: (v) => setState(() => timerEnabled = v),
            ),

            if (timerEnabled)
              DropdownButton<int>(
                value: timerSeconds,
                items: const [
                  DropdownMenuItem(value: 30, child: Text("30 sec")),
                  DropdownMenuItem(value: 60, child: Text("60 sec")),
                  DropdownMenuItem(value: 90, child: Text("90 sec")),
                ],
                onChanged: (v) => setState(() => timerSeconds = v!),
              ),

            SwitchListTile(
              title: const Text("Secret Voting"),
              value: secretVoting,
              onChanged: (v) => setState(() => secretVoting = v),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: startGame,
              child: const Text("Start Game"),
            ),
          ],
        ),
      ),
    );
  }
}
