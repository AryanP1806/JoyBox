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

  late List<String> localCustomWords;
  final Set<String> selectedPacks = {};

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
      "French Fries",
      "Cake",
      "Chocolate",
      "Pani Puri",
      "Momos",
      "Sushi",
      "Vada Pav",
      "Butter Chicken",
      "Popcorn",
      "Shawarma",
      "Dosa",
      "Cheesecake",
      "Black Coffee",
    ],
    "Places": [
      "Goa",
      "Hospital",
      "Police Station",
      "Public Toilet",
      "Gym",
      "Cinema Hall",
      "Graveyard",
      "Museum",
      "Metro Station",
      "Hostel",
      "Mumbai",
      "Delhi",
      "Paris",
      "New York",
      "London",
      "Airport",
      "Beach",
      "Mall",
      "Temple",
      "School",
    ],
    "Animals": [
      "Tiger",
      "Lion",
      "Elephant",
      "Dog",
      "Cat",
      "Horse",
      "Monkey",
      "Shark",
      "Snake",
      "Panda",
      "Giraffe",
      "Kangaroo",
      "Sloth",
      "Gorilla",
      "Mosquito",
      "Dinosaur",
      "Penguin",
      "Cockroach",
      "Peacock",
      "Platypus",
    ],
    "Superheroes": [
      "Batman",
      "Superman",
      "Spiderman",
      "Ironman",
      "Hulk",
      "Thor",
      "Flash",
      "Wolverine",
      "Deadpool",
      "Doctor Strange",
    ],
    "Famous People": [
      "Virat Kohli",
      "Elon Musk",
      "Cristiano Ronaldo",
      "Messi",
      "Narendra Modi",
      "Bill Gates",
      "Shah Rukh Khan",
      "Taylor Swift",
      "The Rock",
      "Michael Jackson",
      "Albert Einstein",
      "Kim Kardashian",
      "Donald Trump",
      "Dhoni",
      "Deepika Padukone",
      "Bean",
      "Hitler",
    ],
    "Video Games": [
      "GTA",
      "Minecraft",
      "PUBG",
      "Valorant",
      "Call of Duty",
      "FIFA",
      "Among Us",
      "Clash of Clans",
    ],
    "Anime": [
      "Naruto",
      "One Piece",
      "Attack on Titan",
      "Death Note",
      "Dragon Ball",
      "Demon Slayer",
      "Jujutsu Kaisen",
    ],
    "Friends Series": [
      "Ross",
      "Rachel",
      "Monica",
      "Chandler",
      "Joey",
      "Phoebe",
    ],
    "Adult (Party Safe)": [
      "Dating",
      "Breakup",
      "Crush",
      "Ex",
      "Flirting",
      "One-Night Stand",
      "Red Flag",
      "Situationship",
      "Walk of Shame",
      "Friends with Benefits",
      "Third Wheel",
      "Catfish",
      "Toxic Ex",
      "Drunk Texting",
      "Ghosting",
      "Love Triangle",
    ],
    "Movies": [
      "Inception",
      "Titanic",
      "Avatar",
      "The Dark Knight",
      "Forrest Gump",
      "The Godfather",
      "Pulp Fiction",
      "The Shawshank Redemption",
      "Jurassic Park",
      "The Avengers",
    ],
    "Adult (Explicit)": [
      "Orgasm",
      "Threesome",
      "BDSM",
      "Role Play",
      "Striptease",
      "Voyeurism",
      "Exhibitionism",
      "Dirty Talk",
      "Cunnilingus",
      "Fingering",
      "69 Position",
      "Spanking",
      "Sexting",
      "Lap Dance",
      "Edging",
      "Golden Shower",
      "Anal Play",
      "Domination",
      "Submission",
      "Mutual Masturbation",
    ],
    "Sports": [
      "Football",
      "Cricket",
      "Basketball",
      "Tennis",
      "Swimming",
      "Running",
      "Cycling",
      "Wrestling",
      "Boxing",
      "Badminton",
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

  List<String> buildFinalWordPool() {
    final List<String> finalPool = [];

    for (final pack in selectedPacks) {
      finalPool.addAll(wordPacks[pack]!);
    }

    if (widget.config.useCustomWords) {
      finalPool.addAll(localCustomWords);
    }

    return finalPool;
  }

  void proceed() {
    final finalPool = buildFinalWordPool();

    if (finalPool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one word pack!")),
      );
      return;
    }

    final selectedWord = finalPool[Random().nextInt(finalPool.length)];

    Navigator.push(
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
      appBar: AppBar(title: const Text("Select Word Packs")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose Word Packs (Multiple Allowed)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: wordPacks.keys.map((packName) {
                  final isSelected = selectedPacks.contains(packName);
                  return CheckboxListTile(
                    title: Text(packName),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        val!
                            ? selectedPacks.add(packName)
                            : selectedPacks.remove(packName);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            if (useCustom) ...[
              const Divider(),
              const Text("Custom Words"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customWordController,
                      decoration: const InputDecoration(
                        labelText: "Add Custom Word",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: addCustomWord,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  itemCount: localCustomWords.length,
                  itemBuilder: (ctx, i) =>
                      ListTile(title: Text(localCustomWords[i])),
                ),
              ),
            ],

            const SizedBox(height: 10),

            ElevatedButton(onPressed: proceed, child: const Text("START GAME")),
          ],
        ),
      ),
    );
  }
}
