import 'package:flutter/material.dart';

class HeadsUpResultsScreen extends StatelessWidget {
  final int score;
  final int durationSeconds;
  final List<String> correctWords;
  final List<String> passedWords;
  final String packLabel;

  const HeadsUpResultsScreen({
    super.key,
    required this.score,
    required this.durationSeconds,
    required this.correctWords,
    required this.passedWords,
    required this.packLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Heads Up – Results")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "Pack: $packLabel",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Time: ${durationSeconds}s",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Score: $score",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (correctWords.isNotEmpty) ...[
                      const Text(
                        "Correct:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: correctWords
                            .map((w) => Chip(label: Text(w)))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (passedWords.isNotEmpty) ...[
                      const Text(
                        "Passed:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: passedWords
                            .map((w) => Chip(label: Text(w)))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Go back to setup screen
                Navigator.pop(context);
              },
              child: const Text("Play Again"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
