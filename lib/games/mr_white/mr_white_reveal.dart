import 'dart:math';
import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_discussion.dart';

class MrWhiteRevealScreen extends StatefulWidget {
  final MrWhiteGameConfig config;

  const MrWhiteRevealScreen({super.key, required this.config});

  @override
  State<MrWhiteRevealScreen> createState() => _MrWhiteRevealScreenState();
}

class _MrWhiteRevealScreenState extends State<MrWhiteRevealScreen> {
  late List<MrWhitePlayer> players;
  int currentIndex = 0;
  bool revealed = false;

  @override
  void initState() {
    super.initState();
    players = _generatePlayers();
  }

  List<MrWhitePlayer> _generatePlayers() {
    final rand = Random();
    final names = widget.config.playerNames;

    // ✅ SAFETY CHECK — NO MORE SILENT FALLBACK TO OLD WORDS
    if (widget.config.customWords.isEmpty) {
      throw Exception(
        "No custom words provided! Old default words are no longer allowed.",
      );
    }

    // Step 1: Assign all as civilian first
    List<String> roles = List.filled(widget.config.playerCount, "civilian");

    int added = 0;
    while (added < widget.config.specialCount) {
      final i = rand.nextInt(widget.config.playerCount);
      if (roles[i] == "civilian") {
        roles[i] = widget.config.mode == MrWhiteMode.mrWhite
            ? "mrwhite"
            : "undercover";
        added++;
      }
    }

    // ✅ ONLY USE NEW CUSTOM WORDS — NO HARDCODED LIST ANYMORE
    final List<String> words = List.from(widget.config.customWords);

    final mainWord = words[rand.nextInt(words.length)];

    String similarWord = mainWord;
    if (widget.config.mode == MrWhiteMode.undercover && words.length > 1) {
      do {
        similarWord = words[rand.nextInt(words.length)];
      } while (similarWord == mainWord);
    }

    return List.generate(widget.config.playerCount, (i) {
      if (roles[i] == "mrwhite") {
        return MrWhitePlayer(name: names[i], role: "mrwhite");
      } else if (roles[i] == "undercover") {
        return MrWhitePlayer(
          name: names[i],
          role: "undercover",
          word: similarWord,
        );
      } else {
        return MrWhitePlayer(name: names[i], role: "civilian", word: mainWord);
      }
    });
  }

  void _next(BuildContext context) {
    if (currentIndex >= players.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MrWhiteDiscussionScreen(players: players, config: widget.config),
        ),
      );
    } else {
      setState(() {
        revealed = false;
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = players[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Role Reveal")),
      body: Center(
        child: revealed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Role: ${player.role.toUpperCase()}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    player.word == null
                        ? "You have NO WORD"
                        : "Your word: ${player.word}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _next(context),
                    child: Text(
                      currentIndex == players.length - 1
                          ? "Start Game"
                          : "Next Player",
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () => setState(() => revealed = true),
                child: Text("Give phone to ${player.name}"),
              ),
      ),
    );
  }
}
