import 'package:flutter/material.dart';
import 'heads_up_models.dart';
import 'heads_up_game.dart';

class HeadsUpSetupScreen extends StatefulWidget {
  const HeadsUpSetupScreen({super.key});

  @override
  State<HeadsUpSetupScreen> createState() => _HeadsUpSetupScreenState();
}

class _HeadsUpSetupScreenState extends State<HeadsUpSetupScreen> {
  HeadsUpPack _selectedPack = HeadsUpPack.general;
  double _durationSlider = 60; // seconds

  @override
  Widget build(BuildContext context) {
    final durationInt = _durationSlider.round();

    return Scaffold(
      appBar: AppBar(title: const Text("Heads Up – Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 30),
            const Text(
              "Round Duration (seconds)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "$durationInt s",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
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
              child: const Text("Start Round"),
            ),
          ],
        ),
      ),
    );
  }
}
