import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- ADDED

import 'mafia_models.dart';
import 'mafia_role_reveal.dart';
// import 'mafia_settings_cache.dart'; // <--- REMOVED

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

  bool _isLoading = true; // <--- To prevent UI jumping

  @override
  void initState() {
    super.initState();
    _loadSettings(); // ✅ Load settings on start
  }

  // ✅ NEW: Load cached settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerCount = prefs.getInt('mafia_playerCount') ?? 6;
      mafiaCount = prefs.getInt('mafia_mafiaCount') ?? 1;
      hasDoctor = prefs.getBool('mafia_hasDoctor') ?? true;
      hasDetective = prefs.getBool('mafia_hasDetective') ?? true;
      secretVoting = prefs.getBool('mafia_secretVoting') ?? false;
      timerEnabled = prefs.getBool('mafia_timerEnabled') ?? false;
      timerSeconds = prefs.getInt('mafia_timerSeconds') ?? 60;

      // Build controllers with correct length
      _syncControllers();

      // Restore names if present
      final cachedNames = prefs.getStringList('mafia_playerNames') ?? [];
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
    await prefs.setInt('mafia_playerCount', playerCount);
    await prefs.setInt('mafia_mafiaCount', mafiaCount);
    await prefs.setBool('mafia_hasDoctor', hasDoctor);
    await prefs.setBool('mafia_hasDetective', hasDetective);
    await prefs.setBool('mafia_secretVoting', secretVoting);
    await prefs.setBool('mafia_timerEnabled', timerEnabled);
    await prefs.setInt('mafia_timerSeconds', timerSeconds);

    // Save Names
    final names = nameControllers.map((c) => c.text).toList();
    await prefs.setStringList('mafia_playerNames', names);
  }

  void _syncControllers() {
    // shrink (dispose removed controllers)
    while (nameControllers.length > playerCount) {
      nameControllers.removeLast().dispose();
    }
    // grow
    while (nameControllers.length < playerCount) {
      nameControllers.add(TextEditingController());
    }

    // keep mafiaCount valid
    if (mafiaCount >= playerCount) {
      mafiaCount = 1;
    }
  }

  List<String> _buildFinalPlayerNames() {
    return List.generate(playerCount, (i) {
      final text = nameControllers[i].text.trim();
      return text.isEmpty ? "Player ${i + 1}" : text;
    });
  }

  Future<void> _startGame() async {
    if (mafiaCount >= playerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mafia must be LESS than total players")),
      );
      return;
    }

    // ✅ SAVE SETTINGS TO CACHE
    await _saveSettings();

    final names = _buildFinalPlayerNames();

    final config = MafiaGameConfig(
      players: names,
      mafiaCount: mafiaCount,
      hasDoctor: hasDoctor,
      hasDetective: hasDetective,
      secretVoting: secretVoting,
      timerEnabled: timerEnabled,
      timerSeconds: timerSeconds,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MafiaRoleRevealScreen(config: config),
        ),
      );
    }
  }

  // ✅ HOW TO PLAY POPUP
  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "How to Play Mafia",
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "🌙 NIGHT PHASE\n"
            "• Mafia secretly kills one player.\n"
            "• Doctor can save one player.\n"
            "• Detective can investigate one player.\n\n"
            "☀️ DAY PHASE\n"
            "• Everyone discusses.\n"
            "• Vote to eliminate one suspect.\n\n"
            "🏆 WIN CONDITIONS\n"
            "• If all Mafia die → Civilians win.\n"
            "• If Mafia equals Civilians → Mafia wins.\n",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
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
        backgroundColor: Color(0xFF020024),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020024), Color(0xFF790C0C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "MAFIA",
                      style: TextStyle(
                        letterSpacing: 4,
                        fontSize: 26,
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
                              min: 4,
                              max: 15,
                              divisions: 11,
                              value: playerCount.toDouble(),
                              onChanged: (v) {
                                setState(() {
                                  playerCount = v.toInt();
                                  _syncControllers();
                                });
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
                        title: "ROLES",
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Mafia Count",
                                  style: TextStyle(color: Colors.white),
                                ),
                                DropdownButton<int>(
                                  dropdownColor: Colors.black,
                                  value: mafiaCount,
                                  onChanged: (v) => setState(() {
                                    mafiaCount = v!;
                                    if (mafiaCount >= playerCount) {
                                      mafiaCount = 1;
                                    }
                                  }),
                                  items:
                                      List.generate(
                                            playerCount - 1,
                                            (i) => i + 1,
                                          )
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
                            _switch(
                              "Enable Doctor",
                              hasDoctor,
                              (v) => setState(() => hasDoctor = v),
                            ),
                            _switch(
                              "Enable Detective",
                              hasDetective,
                              (v) => setState(() => hasDetective = v),
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "GAME OPTIONS",
                        child: Column(
                          children: [
                            _switch(
                              "Secret Voting",
                              secretVoting,
                              (v) => setState(() => secretVoting = v),
                            ),
                            _switch(
                              "Enable Timer",
                              timerEnabled,
                              (v) => setState(() => timerEnabled = v),
                            ),
                            if (timerEnabled)
                              Slider(
                                value: timerSeconds.toDouble(),
                                min: 30,
                                max: 180,
                                divisions: 5,
                                label: "$timerSeconds sec",
                                onChanged: (v) =>
                                    setState(() => timerSeconds = v.toInt()),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // START BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Text(
                      "START MAFIA",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
