import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_scoreboard.dart';

class MrWhiteFinalGuessScreen extends StatefulWidget {
  final List<MrWhitePlayer> players;

  const MrWhiteFinalGuessScreen({super.key, required this.players});

  @override
  State<MrWhiteFinalGuessScreen> createState() =>
      _MrWhiteFinalGuessScreenState();
}

class _MrWhiteFinalGuessScreenState extends State<MrWhiteFinalGuessScreen> {
  final TextEditingController guessController = TextEditingController();

  late String correctWord;

  @override
  void initState() {
    super.initState();
    correctWord = widget.players.firstWhere((p) => p.role == "civilian").word!;
  }

  void submitGuess() {
    final guess = guessController.text.trim().toLowerCase();
    final isCorrect = guess == correctWord.toLowerCase();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MrWhiteScoreBoardScreen(
          players: widget.players,
          mrWhiteGuessCorrect: isCorrect,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Final Guess")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Mr White, enter your final guess:",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: guessController,
              decoration: const InputDecoration(labelText: "Your Guess"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitGuess,
              child: const Text("Submit Guess"),
            ),
          ],
        ),
      ),
    );
  }
}
