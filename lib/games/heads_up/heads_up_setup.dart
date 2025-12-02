import 'package:flutter/material.dart';
import 'heads_up_models.dart';
import 'heads_up_game.dart';

class HeadsUpSetupScreen extends StatefulWidget {
  const HeadsUpSetupScreen({super.key});

  @override
  State<HeadsUpSetupScreen> createState() => _HeadsUpSetupScreenState();
}

class _HeadsUpSetupScreenState extends State<HeadsUpSetupScreen> {
  HeadsUpPack _selectedPack = HeadsUpPack.values.first;
  double _durationSlider = 60; // seconds

  // ✅ AUTO DESCRIPTION — SAFE FOR ANY ENUM
  String _getPackDescription(HeadsUpPack pack) {
    switch (pack.name) {
      case "general":
        return "Everyday fun words for everyone.";
      case "movies":
        return "Guess famous movies and characters.";
      case "animals":
        return "Wild and domestic animals.";
      default:
        return "Fun surprise pack.";
    }
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("How to Play Heads Up"),
        content: const Text(
          "• Hold the phone on your forehead\n"
          "• Others describe the word\n"
          "• Tilt DOWN = Correct\n"
          "• Tilt UP = Pass\n"
          "• Score increases automatically\n"
          "• Game ends when timer runs out",
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
    final durationInt = _durationSlider.round();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Heads Up – Setup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHowToPlay,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            const Text(
              "Choose Pack",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            DropdownButton<HeadsUpPack>(
              isExpanded: true,
              value: _selectedPack,
              items: HeadsUpPack.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedPack = value);
              },
            ),

            const SizedBox(height: 8),

            Text(
              _getPackDescription(_selectedPack),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            const Text(
              "Round Duration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              "$durationInt seconds",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Slider(
              min: 30,
              max: 120,
              divisions: 9,
              value: _durationSlider,
              label: "$durationInt s",
              onChanged: (v) {
                setState(() => _durationSlider = v);
              },
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                final config = HeadsUpConfig(
                  pack: _selectedPack,
                  durationSeconds: durationInt,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HeadsUpGameScreen(config: config),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("START ROUND", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
