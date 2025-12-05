import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final catIndex = prefs.getInt('viral_category') ?? 0;
      if (catIndex < MediaCategory.values.length) {
        selectedCategory = MediaCategory.values[catIndex];
      }

      fakeEnabled = prefs.getBool('viral_fakeEnabled') ?? true;
      partyMode = prefs.getBool('viral_partyMode') ?? true;
      timerEnabled = prefs.getBool('viral_timerEnabled') ?? true;
      timerSeconds = prefs.getInt('viral_timerSeconds') ?? 5;

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('viral_category', selectedCategory.index);
    await prefs.setBool('viral_fakeEnabled', fakeEnabled);
    await prefs.setBool('viral_partyMode', partyMode);
    await prefs.setBool('viral_timerEnabled', timerEnabled);
    await prefs.setInt('viral_timerSeconds', timerSeconds);
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
            "Guess which titles went more viral than other!\n\n"
            "🎬 CATEGORIES\n"
            "• Choose between Movies or Games.\n\n"
            "🤖 FAKE ROUNDS\n"
            "• AI generates fake titles mixed with real ones.\n"
            "• Can you spot the real viral hit?\n\n"
            "⚡ PANIC TIMER\n"
            "• Decide quickly before time runs out!\n\n",
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
        title: const Text(
          "SETUP GAME",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
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
                onPressed: () async {
                  await _saveSettings();

                  if (context.mounted) {
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
                  }
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
