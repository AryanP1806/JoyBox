import 'dart:math';
import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_reveal.dart';

class MrWhiteWordSelectScreen extends StatefulWidget {
  final MrWhiteGameConfig config;

  const MrWhiteWordSelectScreen({super.key, required this.config});

  @override
  State<MrWhiteWordSelectScreen> createState() =>
      _MrWhiteWordSelectScreenState();
}

class _MrWhiteWordSelectScreenState extends State<MrWhiteWordSelectScreen> {
  final TextEditingController customWordController = TextEditingController();

  final Set<String> selectedPacks = {};
  late List<String> localCustomWords;

  // ✅ WORD PACKS
  final Map<String, List<String>> wordPacks = {
    "Foods": [
      "Pizza",
      "Burger",
      "Pasta",
      "Biryani",
      "Noodles",
      "Ice Cream",
      "Sandwich",
      "Cake",
      "Chocolate",
      "Momos",
      "Dosa",
      "Popcorn",
    ],
    "Places": [
      "Goa",
      "Hospital",
      "Airport",
      "Beach",
      "Mall",
      "Temple",
      "School",
      "Gym",
      "Cinema",
      "Graveyard",
    ],
    "Animals": [
      "Tiger",
      "Lion",
      "Elephant",
      "Dog",
      "Cat",
      "Snake",
      "Panda",
      "Shark",
      "Monkey",
      "Cockroach",
    ],
    "Superheroes": [
      "Batman",
      "Superman",
      "Spiderman",
      "Ironman",
      "Thor",
      "Hulk",
      "Deadpool",
      "Flash",
    ],
    "Sports": [
      "Cricket",
      "Football",
      "Badminton",
      "Boxing",
      "Wrestling",
      "Basketball",
      "Tennis",
      "Swimming",
    ],
    "Adults (Party Safe)": [
      "Dating",
      "Flirting",
      "Breakup",
      "Crush",
      "Ghosting",
      "Situationship",
      "Red Flag",
      "Drunk Text",
    ],
  };

  @override
  void initState() {
    super.initState();
    localCustomWords = List.from(widget.config.customWords);
  }

  void addCustomWord() {
    final word = customWordController.text.trim();
    if (word.isEmpty) return;

    setState(() {
      localCustomWords.add(word);
      customWordController.clear();
    });
  }

  void removeCustomWord(String word) {
    setState(() => localCustomWords.remove(word));
  }

  List<String> buildFinalWordPool() {
    final List<String> finalPool = [];

    for (final pack in selectedPacks) {
      finalPool.addAll(wordPacks[pack]!);
    }

    if (widget.config.useCustomWords) {
      finalPool.addAll(localCustomWords);
    }

    return finalPool.toSet().toList(); // ✅ NO DUPLICATES
  }

  void proceed() {
    final finalPool = buildFinalWordPool();

    if (finalPool.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least 2 words to start.")),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MrWhiteRevealScreen(
          config: MrWhiteGameConfig(
            playerCount: widget.config.playerCount,
            mode: widget.config.mode,
            specialCount: widget.config.specialCount,
            useCustomWords: widget.config.useCustomWords,
            timerEnabled: widget.config.timerEnabled,
            timerSeconds: widget.config.timerSeconds,
            secretVoting: widget.config.secretVoting,
            playerNames: widget.config.playerNames,
            customWords: finalPool,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useCustom = widget.config.useCustomWords;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Select Word Packs")),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // ✅ PACK SELECTION
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text(
                  "Choose Categories",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),

                ...wordPacks.keys.map((pack) {
                  final selected = selectedPacks.contains(pack);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected
                            ? selectedPacks.remove(pack)
                            : selectedPacks.add(pack);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF222222), Color(0xFF111111)],
                              ),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        pack,
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

                if (useCustom) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "Custom Words",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customWordController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Add Custom Word",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: addCustomWord,
                        icon: const Icon(Icons.add, color: Colors.orange),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: localCustomWords.map((w) {
                      return Chip(
                        label: Text(w),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => removeCustomWord(w),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ✅ START BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: GestureDetector(
              onTap: proceed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                  ),
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
    );
  }
}
