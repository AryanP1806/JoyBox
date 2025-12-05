// lib/games/assassin/assassin_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- ADDED

import '../../core/safe_nav.dart';
import '../../theme/party_theme.dart';

import 'assassin_models.dart';
import 'assassin_role_reveal_screen.dart';

class AssassinSetupScreen extends StatefulWidget {
  /// If not null, we use this to prefill all UI (players, names, timer, etc.)
  final AssassinGameConfig? lastConfig;

  const AssassinSetupScreen({super.key, this.lastConfig});

  @override
  State<AssassinSetupScreen> createState() => _AssassinSetupScreenState();
}

class _AssassinSetupScreenState extends State<AssassinSetupScreen> {
  int _playerCount = 6;
  final int _minPlayers = 4;
  final int _maxPlayers = 15;

  int _assassinCount = 1;
  int _detectiveCount = 1;

  bool _backgroundMusic = true;

  // ✅ TIMER SETTINGS
  bool _timerEnabled = true;
  int _timerSeconds = 60;

  final List<TextEditingController> _nameControllers = [];
  bool _isLoading = true; // To prevent UI jump while loading prefs

  @override
  void initState() {
    super.initState();
    _loadSettings(); // ✅ Load Cached Settings on Init
  }

  // ✅ NEW: Load settings from Cache or Play Again config
  Future<void> _loadSettings() async {
    final last = widget.lastConfig;

    if (last != null) {
      // 1. Priority: "Play Again" data
      _applyConfig(last);
    } else {
      // 2. Fallback: Load from Local Storage (Offline Persistence)
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _playerCount = prefs.getInt('assassin_playerCount') ?? 6;
        _assassinCount = prefs.getInt('assassin_assassinCount') ?? 1;
        _detectiveCount = prefs.getInt('assassin_detectiveCount') ?? 1;
        _backgroundMusic = prefs.getBool('assassin_bgMusic') ?? true;
        _timerEnabled = prefs.getBool('assassin_timerEnabled') ?? true;
        _timerSeconds = prefs.getInt('assassin_timerSeconds') ?? 60;

        // Sync controllers first to ensure list size is correct
        _syncControllers();

        // Restore Names
        final savedNames = prefs.getStringList('assassin_playerNames') ?? [];
        for (
          var i = 0;
          i < _nameControllers.length && i < savedNames.length;
          i++
        ) {
          _nameControllers[i].text = savedNames[i];
        }
      });
    }

    setState(() => _isLoading = false);
  }

  void _applyConfig(AssassinGameConfig config) {
    setState(() {
      _playerCount = config.playerCount;
      _assassinCount = config.assassinCount;
      _detectiveCount = config.detectiveCount;
      _backgroundMusic = config.backgroundMusic;
      _timerEnabled = config.timerEnabled;
      _timerSeconds = config.timerSeconds.clamp(15, 180);

      _syncControllers();

      for (
        var i = 0;
        i < _nameControllers.length && i < config.playerNames.length;
        i++
      ) {
        _nameControllers[i].text = config.playerNames[i];
      }
    });
  }

  // ✅ NEW: Save settings to Local Storage
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('assassin_playerCount', _playerCount);
    await prefs.setInt('assassin_assassinCount', _assassinCount);
    await prefs.setInt('assassin_detectiveCount', _detectiveCount);
    await prefs.setBool('assassin_bgMusic', _backgroundMusic);
    await prefs.setBool('assassin_timerEnabled', _timerEnabled);
    await prefs.setInt('assassin_timerSeconds', _timerSeconds);

    // Save Names
    final names = _nameControllers.map((c) => c.text).toList();
    await prefs.setStringList('assassin_playerNames', names);
  }

  void _syncControllers() {
    // Grow or Shrink controller list to match player count
    while (_nameControllers.length > _playerCount) {
      _nameControllers.removeLast().dispose();
    }
    while (_nameControllers.length < _playerCount) {
      _nameControllers.add(TextEditingController());
    }

    // Safety checks for logic
    if (_assassinCount >= _playerCount) _assassinCount = 1;
    if (_detectiveCount >= _playerCount) _detectiveCount = 1;
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("How to Play", style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            "🗡️ Assassins try to eliminate others secretly by winking.\n"
            "🕵️ Detectives work to identify the assassins.\n"
            "🎭 Each player gets a role.\n"
            "⏱️ Optional timer for each round.\n"
            "🏆 Game ends when assassins are caught or equal others.\n",
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

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    if (_playerCount < _minPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("At least $_minPlayers players are required.")),
      );
      return;
    }

    if (_assassinCount + _detectiveCount >= _playerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid role distribution.")),
      );
      return;
    }

    // ✅ Cache settings before starting
    _saveSettings();

    final names = List.generate(_playerCount, (i) {
      final txt = _nameControllers[i].text.trim();
      return txt.isEmpty ? 'Player ${i + 1}' : txt;
    });

    final config = AssassinGameConfig(
      playerCount: _playerCount,
      playerNames: names,
      backgroundMusic: _backgroundMusic,
      assassinCount: _assassinCount,
      detectiveCount: _detectiveCount,
      timerEnabled: _timerEnabled,
      timerSeconds: _timerSeconds,
    );

    SafeNav.safePush(context, AssassinRoleRevealScreen(config: config));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: PartyColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: PartyColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020024), Color(0xFF090979), Color(0xFF00D4FF)],
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
                      "WINK ASSASSIN",
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
                      _panel(
                        title: "PLAYERS",
                        child: Column(
                          children: [
                            Text(
                              "$_playerCount Players",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Slider(
                              min: _minPlayers.toDouble(),
                              max: _maxPlayers.toDouble(),
                              divisions: _maxPlayers - _minPlayers,
                              value: _playerCount.toDouble(),
                              onChanged: (v) {
                                setState(() {
                                  _playerCount = v.toInt();
                                  _syncControllers();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "ROLES",
                        child: Column(
                          children: [
                            _dropdownRow(
                              "Assassins",
                              _assassinCount,
                              (v) => setState(() => _assassinCount = v),
                            ),
                            _dropdownRow(
                              "Detectives",
                              _detectiveCount,
                              (v) => setState(() => _detectiveCount = v),
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "PLAYER NAMES",
                        child: Column(
                          children: List.generate(_playerCount, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: TextField(
                                controller: _nameControllers[i],
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
                        title: "OPTIONS",
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _backgroundMusic,
                              onChanged: (v) =>
                                  setState(() => _backgroundMusic = v),
                              title: const Text(
                                "Background Music",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            // ✅ TIMER UI
                            SwitchListTile(
                              value: _timerEnabled,
                              onChanged: (v) =>
                                  setState(() => _timerEnabled = v),
                              title: const Text(
                                "Enable Timer",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            if (_timerEnabled)
                              Slider(
                                min: 15,
                                max: 180,
                                divisions: 11,
                                label: "$_timerSeconds sec",
                                value: _timerSeconds.toDouble(),
                                onChanged: (v) =>
                                    setState(() => _timerSeconds = v.toInt()),
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
                        colors: [Color(0xFF8B0000), Color(0xFFFF4500)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Text(
                      "START GAME",
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

  Widget _dropdownRow(String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        DropdownButton<int>(
          dropdownColor: Colors.black,
          value: value,
          items: List.generate(_playerCount - 1, (i) => i + 1)
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
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
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
