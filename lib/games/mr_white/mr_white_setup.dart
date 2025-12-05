import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- ADDED
// import '../../core/safe_nav.dart';
// import 'mr_white_settings_cache.dart'; // <--- REMOVED

import 'mr_white_models.dart';
import 'mr_white_word_select.dart';

class MrWhiteSetupScreen extends StatefulWidget {
  const MrWhiteSetupScreen({super.key});

  @override
  State<MrWhiteSetupScreen> createState() => _MrWhiteSetupScreenState();
}

class _MrWhiteSetupScreenState extends State<MrWhiteSetupScreen> {
  // ✅ Default Values
  int playerCount = 3;
  int specialCount = 1;

  MrWhiteMode selectedMode = MrWhiteMode.mrWhite;

  bool useCustomWords = false;
  bool timerEnabled = false;
  int timerSeconds = 60;
  bool secretVoting = false;

  final List<TextEditingController> nameControllers = [];
  bool _isLoading = true; // <--- To prevent UI jump

  @override
  void initState() {
    super.initState();
    _loadSettings(); // ✅ Load settings on start
  }

  // ✅ NEW: Load cached settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerCount = prefs.getInt('mr_playerCount') ?? 3;
      specialCount = prefs.getInt('mr_specialCount') ?? 1;

      final modeIndex = prefs.getInt('mr_mode') ?? 0;
      if (modeIndex < MrWhiteMode.values.length) {
        selectedMode = MrWhiteMode.values[modeIndex];
      }

      useCustomWords = prefs.getBool('mr_useCustomWords') ?? false;
      timerEnabled = prefs.getBool('mr_timerEnabled') ?? false;
      timerSeconds = prefs.getInt('mr_timerSeconds') ?? 60;
      secretVoting = prefs.getBool('mr_secretVoting') ?? false;

      // Sync controllers first
      updateControllers();

      // Restore names
      final cachedNames = prefs.getStringList('mr_playerNames') ?? [];
      for (
        int i = 0;
        i < nameControllers.length && i < cachedNames.length;
        i++
      ) {
        nameControllers[i].text = cachedNames[i];
      }

      _isLoading = false;
    });
  }

  // ✅ NEW: Save settings before playing
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('mr_playerCount', playerCount);
    await prefs.setInt('mr_specialCount', specialCount);
    await prefs.setInt('mr_mode', selectedMode.index);
    await prefs.setBool('mr_useCustomWords', useCustomWords);
    await prefs.setBool('mr_timerEnabled', timerEnabled);
    await prefs.setInt('mr_timerSeconds', timerSeconds);
    await prefs.setBool('mr_secretVoting', secretVoting);

    // Save names
    final names = nameControllers.map((c) => c.text).toList();
    await prefs.setStringList('mr_playerNames', names);
  }

  void updateControllers() {
    // ✅ When slider changes, preserve names when possible.
    while (nameControllers.length > playerCount) {
      nameControllers.removeLast().dispose();
    }
    while (nameControllers.length < playerCount) {
      nameControllers.add(TextEditingController());
    }

    if (specialCount >= playerCount) {
      specialCount = 1;
    }
  }

  // ✅ HOW TO PLAY
  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("How to Play", style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            "🎭 GAME MODES\n"
            "• Mr White Mode → One player has NO word.\n"
            "• Undercover Mode → One player has a SIMILAR word.\n\n"
            "🗣️ HOW TO PLAY\n"
            "1. Everyone gives ONE hint.\n"
            "2. Discuss and find the impostor.\n"
            "3. Vote to eliminate.\n\n"
            "🏆 WIN CONDITIONS\n"
            "• Civilians win if special player is eliminated.\n"
            "• Special player wins if they survive till the end.\n\n"
            "⚠️ RULES\n"
            "• Do NOT say the word directly.\n"
            "• One hint per round.\n"
            "• Bluff smart if you are special.\n",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  Future<void> startGame() async {
    final names = <String>[];

    for (int i = 0; i < nameControllers.length; i++) {
      final text = nameControllers[i].text.trim();
      names.add(text.isEmpty ? "Player ${i + 1}" : text);
    }

    // ✅ SAVE CURRENT SETTINGS TO CACHE
    await _saveSettings();

    final config = MrWhiteGameConfig(
      playerCount: playerCount,
      mode: selectedMode,
      specialCount: specialCount,
      useCustomWords: useCustomWords,
      timerEnabled: timerEnabled,
      timerSeconds: timerSeconds,
      secretVoting: secretVoting,
      playerNames: names,
      customWords: const [],
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MrWhiteWordSelectScreen(config: config),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final c in nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF000428),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000428), Color(0xFF004E92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ✅ HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "MR WHITE ",
                      style: TextStyle(
                        letterSpacing: 3,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _showHowToPlay,
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ MODE SELECTION
                      _panel(
                        title: "GAME MODE",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ChoiceChip(
                              label: const Text("MR WHITE"),
                              selected: selectedMode == MrWhiteMode.mrWhite,
                              onSelected: (_) {
                                setState(() {
                                  selectedMode = MrWhiteMode.mrWhite;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text("UNDERCOVER"),
                              selected: selectedMode == MrWhiteMode.undercover,
                              onSelected: (_) {
                                setState(() {
                                  selectedMode = MrWhiteMode.undercover;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "PLAYERS",
                        child: Column(
                          children: [
                            Text(
                              "$playerCount Players",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Slider(
                              min: 3,
                              max: 15,
                              divisions: 12,
                              value: playerCount.toDouble(),
                              onChanged: (v) {
                                setState(() {
                                  playerCount = v.toInt();
                                  updateControllers();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "SPECIAL PLAYERS",
                        child: Column(
                          children: [
                            Text(
                              "$specialCount Special Players",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Slider(
                              min: 1,
                              max: 5,
                              divisions: 4,
                              value: specialCount.toDouble(),
                              onChanged: (v) {
                                setState(() => specialCount = v.toInt());
                              },
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "PLAYER NAMES",
                        child: Column(
                          children: List.generate(playerCount, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: TextField(
                                controller: nameControllers[i],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Player ${i + 1}",
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black26,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      _panel(
                        title: "GAME OPTIONS",
                        child: Column(
                          children: [
                            _switch(
                              "Use Custom Words",
                              useCustomWords,
                              (v) => setState(() => useCustomWords = v),
                            ),
                            _switch(
                              "Enable Timer",
                              timerEnabled,
                              (v) => setState(() => timerEnabled = v),
                            ),
                            if (timerEnabled)
                              DropdownButton<int>(
                                dropdownColor: Colors.black,
                                value: timerSeconds,
                                items: const [
                                  DropdownMenuItem(
                                    value: 30,
                                    child: Text("30 sec"),
                                  ),
                                  DropdownMenuItem(
                                    value: 60,
                                    child: Text("60 sec"),
                                  ),
                                  DropdownMenuItem(
                                    value: 90,
                                    child: Text("90 sec"),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => timerSeconds = v!),
                              ),
                            _switch(
                              "Secret Voting",
                              secretVoting,
                              (v) => setState(() => secretVoting = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ START BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: GestureDetector(
                  onTap: startGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withValues(alpha: 0.9),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Text(
                      "START GAME",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _switch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
