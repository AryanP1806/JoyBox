import 'package:flutter/material.dart';

import '../../settings/app_settings.dart'; // ✅ ADDED
import 'truth_dare_models.dart';
import 'truth_dare_game_screen.dart';
import 'truth_dare_custom_words_screen.dart';
import 'truth_dare_settings_cache.dart';

class TruthDareSetupScreen extends StatefulWidget {
  const TruthDareSetupScreen({super.key});

  @override
  State<TruthDareSetupScreen> createState() => _TruthDareSetupScreenState();
}

class _TruthDareSetupScreenState extends State<TruthDareSetupScreen> {
  int playerCount = 2;
  final int maxPlayers = 15;

  final List<TextEditingController> _nameControllers = List.generate(
    15,
    (_) => TextEditingController(),
  );

  TruthDareCategory category = TruthDareCategory.friends;
  TurnSelectionMode turnMode = TurnSelectionMode.random;
  ScoringMode scoringMode = ScoringMode.casual;
  SkipBehavior skipBehavior = SkipBehavior.penalty;

  bool allowSwitch = true;
  bool limitSkips = false;
  int maxSkipsPerPlayer = 2;

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("How to Play", style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Text(
            "🤔 Choose Truth or Dare\n"
            "👥 Players take turns\n"
            "✅ Answer truthfully or complete the dare\n"
            // "🔄 Switch after each question\n"
            "🔄 Switch players if allowed\n"
            "⏳ Game ends when all questions are answered\n"
            "🏆 Score points for each completed task\n"
            "🚫 Skips may incur penalties\n"
            "🎉 Have fun and be respectful!",
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
  void initState() {
    super.initState();
    _restoreFromCache();
  }

  void _restoreFromCache() {
    playerCount = TruthDareSettingsCache.playerCount ?? playerCount;

    if (TruthDareSettingsCache.categoryIndex != null) {
      final cachedCategory =
          TruthDareCategory.values[TruthDareSettingsCache.categoryIndex!];

      // ✅ BLOCK ADULT IF DISABLED
      if (cachedCategory != TruthDareCategory.adult ||
          AppSettings.instance.adultEnabled) {
        category = cachedCategory;
      }

      turnMode =
          TurnSelectionMode.values[TruthDareSettingsCache.turnModeIndex!];
      scoringMode =
          ScoringMode.values[TruthDareSettingsCache.scoringModeIndex!];
      skipBehavior =
          SkipBehavior.values[TruthDareSettingsCache.skipBehaviorIndex!];
    }

    allowSwitch = TruthDareSettingsCache.allowSwitch ?? allowSwitch;
    limitSkips = TruthDareSettingsCache.limitSkips ?? limitSkips;
    maxSkipsPerPlayer =
        TruthDareSettingsCache.maxSkipsPerPlayer ?? maxSkipsPerPlayer;

    final cachedNames = TruthDareSettingsCache.playerNames;
    if (cachedNames != null) {
      for (int i = 0; i < cachedNames.length; i++) {
        _nameControllers[i].text = cachedNames[i];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final names = List.generate(playerCount, (i) {
      final txt = _nameControllers[i].text.trim();
      return txt.isEmpty ? 'Player ${i + 1}' : txt;
    });

    TruthDareSettingsCache.save(
      playerCount: playerCount,
      playerNames: names,
      categoryIndex: category.index,
      turnModeIndex: turnMode.index,
      scoringModeIndex: scoringMode.index,
      skipBehaviorIndex: skipBehavior.index,
      allowSwitch: allowSwitch,
      limitSkips: limitSkips,
      maxSkipsPerPlayer: maxSkipsPerPlayer,
    );

    final config = TruthDareGameConfig(
      playerCount: playerCount,
      playerNames: names,
      category: category,
      turnSelectionMode: turnMode,
      scoringMode: scoringMode,
      skipBehavior: skipBehavior,
      allowSwitchAfterQuestion: allowSwitch,
      limitSkips: limitSkips,
      maxSkipsPerPlayer: maxSkipsPerPlayer,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TruthDareGameScreen(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FILTER CATEGORY LIST BY ADULT MODE
    final allowedCategories = TruthDareCategory.values.where((c) {
      if (c == TruthDareCategory.adult) {
        return AppSettings.instance.adultEnabled;
      }
      return true;
    }).toList();

    // ✅ FORCED SAFETY IF ADULT WAS PREVIOUSLY SELECTED
    if (!allowedCategories.contains(category)) {
      category = TruthDareCategory.friends;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF23074D), Color(0xFFCC5333)],
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
                      "TRUTH OR DARE",
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
                              "$playerCount Players",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Slider(
                              min: 2,
                              max: maxPlayers.toDouble(),
                              divisions: 13,
                              value: playerCount.toDouble(),
                              onChanged: (v) =>
                                  setState(() => playerCount = v.toInt()),
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
                        title: "GAME MODE",
                        child: Column(
                          children: [
                            _dropdown(
                              "Category",
                              category,
                              allowedCategories, // ✅ FILTERED
                              (v) => setState(() => category = v),
                            ),
                            if (category == TruthDareCategory.custom)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit Custom Words"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TruthDareCustomWordsScreen(),
                                    ),
                                  );
                                },
                              ),
                            _dropdown(
                              "Turn Mode",
                              turnMode,
                              TurnSelectionMode.values,
                              (v) => setState(() => turnMode = v),
                            ),
                            _dropdown(
                              "Scoring Mode",
                              scoringMode,
                              ScoringMode.values,
                              (v) => setState(() => scoringMode = v),
                            ),
                            _dropdown(
                              "Skip Mode",
                              skipBehavior,
                              SkipBehavior.values,
                              (v) => setState(() => skipBehavior = v),
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: "OPTIONS",
                        child: Column(
                          children: [
                            _switch(
                              "Allow Switch",
                              allowSwitch,
                              (v) => setState(() => allowSwitch = v),
                            ),
                            _switch(
                              "Limit Skips",
                              limitSkips,
                              (v) => setState(() => limitSkips = v),
                            ),
                            if (limitSkips)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Max Skips",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: maxSkipsPerPlayer > 1
                                            ? () => setState(
                                                () => maxSkipsPerPlayer--,
                                              )
                                            : null,
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text(
                                        "$maxSkipsPerPlayer",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            setState(() => maxSkipsPerPlayer++),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                        colors: [Color(0xFF3A1C71), Color(0xFFD76D77)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withValues(alpha: 0.9),
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

  Widget _dropdown<T>(
    String label,
    T value,
    List<T> items,
    Function(T) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        DropdownButton<T>(
          dropdownColor: Colors.black,
          value: value,
          onChanged: (v) => onChanged(v!),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.toString().split('.').last.toUpperCase()),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
