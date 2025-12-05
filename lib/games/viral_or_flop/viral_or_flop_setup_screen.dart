import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final catIndex = prefs.getInt('vof_category') ?? 0;
      if (catIndex < MediaCategory.values.length) {
        selectedCategory = MediaCategory.values[catIndex];
      }

      final modeIndex = prefs.getInt('vof_playMode') ?? 0;
      if (modeIndex < ViralPlayMode.values.length) {
        playMode = ViralPlayMode.values[modeIndex];
      }

      fakeEnabled = prefs.getBool('vof_fakeEnabled') ?? true;
      partyMode = prefs.getBool('vof_partyMode') ?? true;
      timerEnabled = prefs.getBool('vof_timerEnabled') ?? true;
      timerSeconds = prefs.getInt('vof_timerSeconds') ?? 5;

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vof_category', selectedCategory.index);
    await prefs.setInt('vof_playMode', playMode.index);
    await prefs.setBool('vof_fakeEnabled', fakeEnabled);
    await prefs.setBool('vof_partyMode', partyMode);
    await prefs.setBool('vof_timerEnabled', timerEnabled);
    await prefs.setInt('vof_timerSeconds', timerSeconds);
  }

  // ✅ HOW TO PLAY DIALOG
  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "How to Play",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "📈 VIRAL MODE\n"
            "• Guess which movie/game was more popular.\n"
            "• Higher score/box office wins.\n\n"
            "📉 FLOP MODE\n"
            "• Guess which one failed harder.\n"
            "• Lower score wins.\n\n"
            "⚡ PANIC TIMER\n"
            "• You only have a few seconds to decide!\n\n"
            "😈 PARTY MODE\n"
            "• Losers might have to do a dare!",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("VIRAL OR FLOP"),
        actions: [
          // ✅ ADDED INFO BUTTON
          IconButton(
            onPressed: _showHowToPlay,
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
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

  Future<void> _startGame() async {
    await _saveSettings();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViralOrFlopGameScreen(
            category: selectedCategory,
            fakeEnabled: fakeEnabled,
            partyMode: partyMode,
            timerEnabled: timerEnabled,
            timerSeconds: timerSeconds,
            playMode: playMode,
          ),
        ),
      );
    }
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
          activeThumbColor: Colors.orange,
        ),
      ],
    );
  }
}
