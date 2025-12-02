import 'package:flutter/material.dart';
import '../games/mr_white/mr_white_setup.dart';
import '../games/mafia/mafia_setup.dart';
import '../games/heads_up/heads_up_setup.dart';
import '../games/truth_or_dare/truth_dare_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {"title": "Mr White", "screen": const MrWhiteSetupScreen()},
      {"title": "Mafia", "screen": const MafiaSetupScreen()},
      {"title": "Truth & Dare", "screen": const TruthDareSetupScreen()},
      {"title": "Heads Up", "screen": const HeadsUpSetupScreen()},
      {"title": "Dumb Charades", "screen": null},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Party Moderator"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final game = games[index];
            return GestureDetector(
              onTap: () {
                if (game["screen"] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => game["screen"] as Widget),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Coming Soon")));
                }
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    game["title"] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
