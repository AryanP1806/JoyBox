import 'package:flutter/material.dart';

import '../../settings/app_settings.dart';
import 'most_likely_models.dart';
import 'most_likely_packs.dart';
import 'most_likely_settings_cache.dart';
import 'most_likely_game_screen.dart';

class MostLikelySetupScreen extends StatefulWidget {
  const MostLikelySetupScreen({super.key});

  @override
  State<MostLikelySetupScreen> createState() => _MostLikelySetupScreenState();
}

class _MostLikelySetupScreenState extends State<MostLikelySetupScreen> {
  static const int _minPlayers = 2;
  static const int _maxPlayers = 15;

  int playerCount = 4;
  final List<TextEditingController> _nameControllers = [];

  List<MostLikelyPack> selectedPacks = [MostLikelyPack.clean];

  MostLikelyVotingMode votingMode = MostLikelyVotingMode.phonePass;
  MostLikelyScoringMode scoringMode = MostLikelyScoringMode.winnerGetsPoint;
  MostLikelyPunishmentMode punishmentMode = MostLikelyPunishmentMode.none;

  bool allowSelfVote = false;

  MostLikelyEndCondition endCondition = MostLikelyEndCondition.manualStop;
  int totalRounds = 10;

  @override
  void initState() {
    super.initState();
    _syncControllers();
    _restoreFromCache();
  }

  void _syncControllers() {
    while (_nameControllers.length > playerCount) {
      _nameControllers.removeLast().dispose();
    }
    while (_nameControllers.length < playerCount) {
      _nameControllers.add(TextEditingController());
    }
  }

  void _restoreFromCache() {
    final adultEnabled = AppSettings.instance.adultEnabled;

    if (MostLikelySettingsCache.playerCount != null) {
      final v = MostLikelySettingsCache.playerCount!;
      if (v >= _minPlayers && v <= _maxPlayers) {
        playerCount = v;
      }
    }

    _syncControllers();

    final cachedNames = MostLikelySettingsCache.playerNames;
    if (cachedNames != null && cachedNames.isNotEmpty) {
      for (
        int i = 0;
        i < _nameControllers.length && i < cachedNames.length;
        i++
      ) {
        _nameControllers[i].text = cachedNames[i];
      }
    }

    var cachedPacks = MostLikelySettingsCache.getCachedPacks();
    if (!adultEnabled) {
      cachedPacks = cachedPacks.where((p) => !p.isAdult).toList();
    }
    if (cachedPacks.isNotEmpty) selectedPacks = cachedPacks;

    final vm = MostLikelySettingsCache.votingModeIndex;
    final sm = MostLikelySettingsCache.scoringModeIndex;
    final pm = MostLikelySettingsCache.punishmentModeIndex;

    if (vm != null) votingMode = MostLikelyVotingMode.values[vm];
    if (sm != null) scoringMode = MostLikelyScoringMode.values[sm];
    if (pm != null) {
      punishmentMode = MostLikelyPunishmentMode.values[pm];
    }

    allowSelfVote = MostLikelySettingsCache.allowSelfVote ?? false;

    if (MostLikelySettingsCache.endCondition != null) {
      endCondition = MostLikelySettingsCache.endCondition!;
    }

    if (MostLikelySettingsCache.totalRounds != null &&
        MostLikelySettingsCache.totalRounds! > 0) {
      totalRounds = MostLikelySettingsCache.totalRounds!;
    }
  }

  void _startGame() {
    final adultEnabled = AppSettings.instance.adultEnabled;

    final packsEffective = adultEnabled
        ? selectedPacks
        : selectedPacks.where((p) => !p.isAdult).toList();

    // final names = List.generate(playerCount, (i) {
    //   final t = _nameControllers[i].text.trim();
    //   return t; // ✅ return t.isEmpty ? "Player ${i + 1}" : t;
    // });
    final names = List.generate(playerCount, (i) {
      return _nameControllers[i].text.trim(); // ✅ only real input saved
    });

    final config = MostLikelyGameConfig(
      playerNames: names,
      packs: packsEffective,
      votingMode: votingMode,
      scoringMode: scoringMode,
      punishmentMode: punishmentMode,
      allowSelfVote: allowSelfVote,
      endCondition: endCondition,
      totalRounds: endCondition == MostLikelyEndCondition.fixedRounds
          ? totalRounds
          : null,
    );

    MostLikelySettingsCache.save(
      playerCountValue: playerCount,
      playerNamesValue: names,
      packs: packsEffective,
      votingMode: votingMode,
      scoringMode: scoringMode,
      punishmentMode: punishmentMode,
      allowSelfVoteValue: allowSelfVote,
      endConditionValue: endCondition,
      totalRoundsValue: endCondition == MostLikelyEndCondition.fixedRounds
          ? totalRounds
          : null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MostLikelyGameScreen(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adultEnabled = AppSettings.instance.adultEnabled;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 14),
                    const Text(
                      "WHO'S MOST LIKELY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.black,
                            title: const Text(
                              "How To Play",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "1. Read the question\n"
                              "2. Vote for the most likely person\n"
                              "3. See who got most votes\n"
                              "4. Apply punishment if enabled\n"
                              "5. Continue till game ends",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
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
                        "PLAYERS: $playerCount",
                        Slider(
                          min: _minPlayers.toDouble(),
                          max: _maxPlayers.toDouble(),
                          divisions: _maxPlayers - _minPlayers,
                          value: playerCount.toDouble(),
                          onChanged: (v) {
                            setState(() {
                              playerCount = v.toInt();
                              _syncControllers();
                            });
                          },
                        ),
                      ),

                      _panel(
                        "NAMES",
                        Column(
                          children: List.generate(
                            playerCount,
                            (i) => Padding(
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
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      _panel(
                        "PACKS",
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: MostLikelyPack.values
                              .where((p) {
                                if (!adultEnabled && p.isAdult) return false;
                                return true;
                              })
                              .map((pack) {
                                return FilterChip(
                                  label: Text(
                                    pack.label,
                                    style: TextStyle(
                                      color: selectedPacks.contains(pack)
                                          ? Colors.black
                                          : Colors.white, // ✅ FIXED VISIBILITY
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: selectedPacks.contains(pack),
                                  onSelected: (v) {
                                    setState(() {
                                      if (v) {
                                        selectedPacks.add(pack);
                                      } else {
                                        if (selectedPacks.length > 1) {
                                          selectedPacks.remove(pack);
                                        }
                                      }
                                    });
                                  },
                                  selectedColor: Colors.cyanAccent,
                                  backgroundColor: Colors.grey.shade800,
                                  checkmarkColor: Colors.black,
                                );
                              })
                              .toList(),
                        ),
                      ),

                      _panel(
                        "MODES",
                        Column(
                          children: [
                            _dropdown(
                              "Voting",
                              votingMode,
                              MostLikelyVotingMode.values,
                              (v) => setState(() => votingMode = v),
                            ),
                            _dropdown(
                              "Scoring",
                              scoringMode,
                              MostLikelyScoringMode.values,
                              (v) => setState(() => scoringMode = v),
                            ),
                            _dropdown(
                              "Punishment",
                              punishmentMode,
                              MostLikelyPunishmentMode.values,
                              (v) => setState(() => punishmentMode = v),
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        "SETTINGS",
                        Column(
                          children: [
                            SwitchListTile(
                              value: allowSelfVote,
                              onChanged: (v) =>
                                  setState(() => allowSelfVote = v),
                              title: const Text(
                                "Allow Self Vote",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            _dropdown(
                              "End Condition",
                              endCondition,
                              MostLikelyEndCondition.values,
                              (v) => setState(() => endCondition = v),
                            ),
                            if (endCondition ==
                                MostLikelyEndCondition.fixedRounds)
                              Column(
                                children: [
                                  Slider(
                                    min: 5,
                                    max: 50,
                                    divisions: 45,
                                    value: totalRounds.toDouble(),
                                    onChanged: (v) =>
                                        setState(() => totalRounds = v.toInt()),
                                  ),
                                  Text(
                                    "$totalRounds Rounds",
                                    style: const TextStyle(color: Colors.white),
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
                padding: const EdgeInsets.all(18),
                child: GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          letterSpacing: 1,
                        ),
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

  Widget _panel(String title, Widget child) {
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
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _dropdown<T>(
    String label,
    T value,
    List<T> items,
    void Function(T) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        DropdownButton<T>(
          dropdownColor: Colors.black,
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
