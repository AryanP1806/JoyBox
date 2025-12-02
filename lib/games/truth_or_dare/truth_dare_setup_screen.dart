import 'package:flutter/material.dart';

import 'truth_dare_models.dart';
import 'truth_dare_game_screen.dart';
import 'truth_dare_custom_words_screen.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Truth or Dare Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ------------ PLAYER COUNT ------------
            Row(
              children: [
                const Text(
                  "Players:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: playerCount > 2
                      ? () => setState(() => playerCount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text("$playerCount", style: const TextStyle(fontSize: 18)),
                IconButton(
                  onPressed: playerCount < maxPlayers
                      ? () => setState(() => playerCount++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ------------ PLAYER NAMES ------------
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Player Names (optional)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playerCount,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TextField(
                    controller: _nameControllers[i],
                    decoration: InputDecoration(
                      hintText: "Player ${i + 1}",
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ------------ CATEGORY ------------
            _buildDropdown<TruthDareCategory>(
              title: "Category",
              value: category,
              items: TruthDareCategory.values,
              labelBuilder: (c) => c.name.toUpperCase(),
              onChanged: (v) => setState(() => category = v),
            ),

            // ✅ CUSTOM WORDS BUTTON
            if (category == TruthDareCategory.custom)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Custom Truth & Dare"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TruthDareCustomWordsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ------------ TURN MODE ------------
            _buildDropdown<TurnSelectionMode>(
              title: "Turn Selection",
              value: turnMode,
              items: TurnSelectionMode.values,
              labelBuilder: (m) =>
                  m == TurnSelectionMode.random ? "RANDOM" : "SPIN BOTTLE",
              onChanged: (v) => setState(() => turnMode = v),
            ),

            const SizedBox(height: 12),

            // ------------ SCORING MODE ------------
            _buildDropdown<ScoringMode>(
              title: "Scoring Mode",
              value: scoringMode,
              items: ScoringMode.values,
              labelBuilder: (s) =>
                  s == ScoringMode.casual ? "CASUAL" : "POINTS",
              onChanged: (v) => setState(() => scoringMode = v),
            ),

            const SizedBox(height: 12),

            // ------------ SKIP BEHAVIOR ------------
            _buildDropdown<SkipBehavior>(
              title: "Skip Behavior",
              value: skipBehavior,
              items: SkipBehavior.values,
              labelBuilder: (s) {
                switch (s) {
                  case SkipBehavior.penalty:
                    return "PENALTY";
                  case SkipBehavior.forcedDare:
                    return "FORCED DARE";
                  case SkipBehavior.disabled:
                    return "DISABLED";
                }
              },
              onChanged: (v) => setState(() => skipBehavior = v),
            ),

            const SizedBox(height: 12),

            // ------------ SWITCH ALLOW ------------
            SwitchListTile(
              title: const Text("Allow Switch (Truth ↔ Dare)"),
              value: allowSwitch,
              onChanged: (v) => setState(() => allowSwitch = v),
            ),

            // ------------ LIMIT SKIPS ------------
            SwitchListTile(
              title: const Text("Limit Skips Per Player"),
              value: limitSkips,
              onChanged: (v) => setState(() => limitSkips = v),
            ),

            if (limitSkips) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text("Max Skips:"),
                  const Spacer(),
                  IconButton(
                    onPressed: maxSkipsPerPlayer > 1
                        ? () => setState(() => maxSkipsPerPlayer--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text("$maxSkipsPerPlayer"),
                  IconButton(
                    onPressed: () => setState(() => maxSkipsPerPlayer++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ------------ START BUTTON ------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("START GAME", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String title,
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(labelBuilder(e)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
