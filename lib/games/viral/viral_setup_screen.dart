import 'package:flutter/material.dart';
import 'viral_models.dart';

import 'viral_game_screen.dart';

// ==========================================
// SETUP SCREEN
// ==========================================
class ViralScreen extends StatefulWidget {
  const ViralScreen({super.key});

  @override
  State<ViralScreen> createState() => _ViralScreenState();
}

class _ViralScreenState extends State<ViralScreen> {
  MediaCategory selectedCategory = MediaCategory.movie;
  bool fakeEnabled = true;
  bool partyMode = true;
  bool timerEnabled = true;
  int timerSeconds = 5; // Defaulted to 5 for sanity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "SETUP GAME",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _panel(
              "CATEGORY",
              Row(
                children: [
                  Expanded(
                    child: _modeChip(
                      "MOVIES",
                      Icons.movie,
                      selectedCategory == MediaCategory.movie,
                      () {
                        setState(() => selectedCategory = MediaCategory.movie);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modeChip(
                      "GAMES",
                      Icons.sports_esports,
                      selectedCategory == MediaCategory.game,
                      () {
                        setState(() => selectedCategory = MediaCategory.game);
                      },
                    ),
                  ),
                ],
              ),
            ),
            _panel(
              "MODIFIERS",
              Column(
                children: [
                  _switchTile(
                    "Fake Rounds",
                    "Include AI-generated baits",
                    fakeEnabled,
                    (v) {
                      setState(() => fakeEnabled = v);
                    },
                  ),
                  const Divider(color: Colors.white10),
                  _switchTile(
                    "Party Mode",
                    "Punishments & Effects",
                    partyMode,
                    (v) {
                      setState(() => partyMode = v);
                    },
                  ),
                ],
              ),
            ),
            _panel(
              "DIFFICULTY",
              Column(
                children: [
                  _switchTile(
                    "Panic Timer",
                    "Limit decision time",
                    timerEnabled,
                    (v) {
                      setState(() => timerEnabled = v);
                    },
                  ),
                  if (timerEnabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            "Time:",
                            style: TextStyle(color: Colors.white54),
                          ),
                          Expanded(
                            child: Slider(
                              value: timerSeconds.toDouble(),
                              min: 2,
                              max: 10,
                              divisions: 8,
                              activeColor: Colors.orange,
                              onChanged: (v) =>
                                  setState(() => timerSeconds = v.toInt()),
                            ),
                          ),
                          Text(
                            "${timerSeconds}s",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViralGameScreen(
                        category: selectedCategory,
                        fakeEnabled: fakeEnabled,
                        partyMode: partyMode,
                        timerEnabled: timerEnabled,
                        timerSeconds: timerSeconds,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "START GAME",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _modeChip(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.orange : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.orange : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.black : Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.orange),
      ],
    );
  }
}

// ==========================================
// RESULTS SCREEN
// ==========================================
class ViralResultsScreen extends StatelessWidget {
  final int finalStreak;
  const ViralResultsScreen({super.key, required this.finalStreak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "GAME OVER",
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              const Text("FINAL STREAK", style: TextStyle(color: Colors.white)),
              Text(
                "$finalStreak",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 80,
                  height: 1,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "BACK TO SETUP",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
