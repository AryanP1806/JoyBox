import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- ADDED

import 'heads_up_models.dart';
import 'heads_up_game.dart';
import '../../settings/app_settings.dart';

class HeadsUpSetupScreen extends StatefulWidget {
  const HeadsUpSetupScreen({super.key});

  @override
  State<HeadsUpSetupScreen> createState() => _HeadsUpSetupScreenState();
}

class _HeadsUpSetupScreenState extends State<HeadsUpSetupScreen> {
  HeadsUpPack _selectedPack = HeadsUpPack.values.first;
  double _durationSlider = 60;
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
      // Load Duration
      _durationSlider = prefs.getDouble('heads_up_duration') ?? 60;

      // Load Pack (by index)
      final packIndex = prefs.getInt('heads_up_pack_index') ?? 0;
      if (packIndex < HeadsUpPack.values.length) {
        _selectedPack = HeadsUpPack.values[packIndex];
      }

      _isLoading = false;
    });
  }

  // ✅ NEW: Save settings before playing
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('heads_up_duration', _durationSlider);
    await prefs.setInt('heads_up_pack_index', _selectedPack.index);
  }

  // ✅ SAFE DESCRIPTION FOR ANY ENUM
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

  // ✅ HOW TO PLAY
  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "How to Play Heads Up",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "📱 Hold phone on forehead\n"
          "🗣 Others describe the word\n"
          "⬇ Tilt DOWN = Correct\n"
          "⬆ Tilt UP = Pass\n"
          "⏱ Game ends when timer runs out\n",
          style: TextStyle(color: Colors.white70, height: 1.6),
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141E30),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final durationInt = _durationSlider.round();
    final allowedPacks = HeadsUpPack.values.where((pack) {
      if (pack == HeadsUpPack.adult) {
        return AppSettings.instance.adultEnabled; // ✅ HARD GATE
      }
      return true;
    }).toList();

    // ✅ SAFETY: If cached value was adult but now disabled
    if (!AppSettings.instance.adultEnabled &&
        _selectedPack == HeadsUpPack.adult) {
      _selectedPack = HeadsUpPack.general;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ✅ HEADER WITH INFO BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "HEADS UP",
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

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ PACK PANEL
                      _panel(
                        title: "WORD PACK",
                        child: Column(
                          children: [
                            DropdownButton<HeadsUpPack>(
                              dropdownColor: Colors.black,
                              isExpanded: true,
                              value: _selectedPack,
                              items: allowedPacks
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        p.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _selectedPack = v);
                              },
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _getPackDescription(_selectedPack),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ TIMER PANEL
                      _panel(
                        title: "ROUND TIMER",
                        child: Column(
                          children: [
                            Text(
                              "$durationInt Seconds",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Slider(
                              min: 30,
                              max: 120,
                              divisions: 9,
                              value: _durationSlider,
                              onChanged: (v) {
                                setState(() => _durationSlider = v);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ✅ NEON START BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: GestureDetector(
                  onTap: () async {
                    // ✅ 1. Save Settings
                    await _saveSettings();

                    final config = HeadsUpConfig(
                      pack: _selectedPack,
                      durationSeconds: durationInt,
                    );

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HeadsUpGameScreen(config: config),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F260), Color(0xFF0575E6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.9),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Text(
                      "START ROUND",
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

  // ✅ PREMIUM PANEL (MATCHES MR WHITE)
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
}
