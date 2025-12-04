import 'package:flutter/material.dart';

import 'viral_or_flop_game_screen.dart';
import 'viral_or_flop_models.dart';

class ViralOrFlopSetupScreen extends StatefulWidget {
  const ViralOrFlopSetupScreen({super.key});

  @override
  State<ViralOrFlopSetupScreen> createState() => _ViralOrFlopSetupScreenState();
}

class _ViralOrFlopSetupScreenState extends State<ViralOrFlopSetupScreen> {
  // ✅ MODE SELECTION
  MediaCategory selectedCategory = MediaCategory.movie;

  bool fakeEnabled = true;
  bool partyMode = true;

  bool timerEnabled = true;
  int timerSeconds = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("VIRAL OR FLOP"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ✅ Back goes HOME correctly
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _panel(
              "MODE",
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _modeChip(
                    label: "MOVIES",
                    selected: selectedCategory == MediaCategory.movie,
                    onTap: () =>
                        setState(() => selectedCategory = MediaCategory.movie),
                  ),
                  _modeChip(
                    label: "GAMES",
                    selected: selectedCategory == MediaCategory.game,
                    onTap: () =>
                        setState(() => selectedCategory = MediaCategory.game),
                  ),
                ],
              ),
            ),

            _panel(
              "OPTIONS",
              Column(
                children: [
                  _switchTile(
                    title: "FAKE ROUNDS",
                    subtitle: "AI-generated trick questions",
                    value: fakeEnabled,
                    onChanged: (v) => setState(() => fakeEnabled = v),
                  ),
                  _switchTile(
                    title: "PARTY MODE",
                    subtitle: "Punishments & streak rewards",
                    value: partyMode,
                    onChanged: (v) => setState(() => partyMode = v),
                  ),
                ],
              ),
            ),

            _panel(
              "TIMER",
              Column(
                children: [
                  _switchTile(
                    title: "ROUND TIMER",
                    subtitle: "Force-panic decisions",
                    value: timerEnabled,
                    onChanged: (v) => setState(() => timerEnabled = v),
                  ),
                  if (timerEnabled)
                    Row(
                      children: [
                        const Text(
                          "Seconds",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Expanded(
                          child: Slider(
                            min: 2,
                            max: 6,
                            divisions: 4,
                            value: timerSeconds.toDouble(),
                            onChanged: (v) =>
                                setState(() => timerSeconds = v.toInt()),
                          ),
                        ),
                        Text(
                          "$timerSeconds",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: _startGame,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF512F), Color(0xFFF09819)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.orange, blurRadius: 18),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "START GAME",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ START GAME
  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViralOrFlopGameScreen(
          category: selectedCategory,
          fakeEnabled: fakeEnabled,
          partyMode: partyMode,
          timerEnabled: timerEnabled,
          timerSeconds: timerSeconds,
        ),
      ),
    );
  }

  // ✅ UI HELPERS

  Widget _panel(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _modeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                )
              : null,
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      activeColor: Colors.orangeAccent,
    );
  }
}
