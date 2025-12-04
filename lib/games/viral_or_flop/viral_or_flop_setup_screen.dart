import 'package:flutter/material.dart';
import 'viral_or_flop_models.dart';
import 'viral_or_flop_game_screen.dart';

class ViralOrFlopSetupScreen extends StatefulWidget {
  const ViralOrFlopSetupScreen({super.key});

  @override
  State<ViralOrFlopSetupScreen> createState() => _ViralOrFlopSetupScreenState();
}

class _ViralOrFlopSetupScreenState extends State<ViralOrFlopSetupScreen> {
  MediaCategory selectedCategory = MediaCategory.movie;
  ViralPlayMode playMode = ViralPlayMode.viralOnly;

  bool fakeEnabled = true;
  bool partyMode = true;
  bool timerEnabled = true;
  int timerSeconds = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("VIRAL OR FLOP SETUP"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _panel(
              "TARGET MODE",
              Row(
                children: [
                  Expanded(
                    child: _modeChip(
                      "VIRAL",
                      Icons.trending_up,
                      playMode == ViralPlayMode.viralOnly,
                      () => setState(() => playMode = ViralPlayMode.viralOnly),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modeChip(
                      "FLOP",
                      Icons.trending_down,
                      playMode == ViralPlayMode.flopOnly,
                      () => setState(() => playMode = ViralPlayMode.flopOnly),
                    ),
                  ),
                ],
              ),
            ),
            _panel(
              "CATEGORY",
              Row(
                children: [
                  Expanded(
                    child: _modeChip(
                      "MOVIES",
                      Icons.movie,
                      selectedCategory == MediaCategory.movie,
                      () => setState(
                        () => selectedCategory = MediaCategory.movie,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modeChip(
                      "GAMES",
                      Icons.sports_esports,
                      selectedCategory == MediaCategory.game,
                      () =>
                          setState(() => selectedCategory = MediaCategory.game),
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
                    "AI-generated bait entries",
                    fakeEnabled,
                    (v) => setState(() => fakeEnabled = v),
                  ),
                  const Divider(color: Colors.white10),
                  _switchTile(
                    "Party Mode",
                    "Punishments enabled",
                    partyMode,
                    (v) => setState(() => partyMode = v),
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
                    "Limited decision time",
                    timerEnabled,
                    (v) => setState(() => timerEnabled = v),
                  ),
                  if (timerEnabled)
                    Row(
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
                onPressed: _startGame,
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
          playMode: playMode, // ✅ FIXED
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
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.black : Colors.white),
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.orange, // ✅ FIX
        ),
      ],
    );
  }
}
