import 'package:flutter/material.dart';
import '../../theme/party_theme.dart';
import 'most_likely_models.dart';
import 'most_likely_setup_screen.dart';

class MostLikelyResultsScreen extends StatelessWidget {
  final List<MostLikelyPlayer> players;

  const MostLikelyResultsScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.first;

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Final Results"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "🏆 Winner: ${winner.name}",
              style: const TextStyle(
                fontSize: 26,
                color: PartyColors.accentYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final p = sorted[i];
                  return ListTile(
                    title: Text(
                      p.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      p.score.toString(),
                      style: const TextStyle(
                        color: PartyColors.accentPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
  onPressed: () {
    Navigator.pop(context); // Go back to Game
    // Navigator.pop(context); // Go back to Setup
    
  },
  child: const Text("PLAY AGAIN"),
),

          ],
        ),
      ),
    );
  }
}
