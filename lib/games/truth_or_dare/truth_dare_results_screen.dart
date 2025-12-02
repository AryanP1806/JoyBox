import 'package:flutter/material.dart';
import '../../theme/party_theme.dart';
import 'truth_dare_models.dart';
import 'truth_dare_setup_screen.dart';

class TruthDareResultsScreen extends StatelessWidget {
  final List<TruthDarePlayer> players;

  const TruthDareResultsScreen({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.first;

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Results"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🏆 WINNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: PartyGradients.neon,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    "🏆 WINNER 🏆",
                    style: TextStyle(
                      color: PartyColors.accentYellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    winner.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Score: ${winner.score}",
                    style: const TextStyle(
                      color: PartyColors.accentCyan,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 📊 LEADERBOARD
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Leaderboard",
                style: TextStyle(
                  color: PartyColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final p = sorted[i];
                  return Card(
                    color: PartyColors.card,
                    child: ListTile(
                      leading: Text(
                        "#${i + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
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
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// 🔄 PLAY AGAIN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: PartyColors.accentPink,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TruthDareSetupScreen(),
                    ),
                    (_) => false,
                  );
                },
                child: const Text("PLAY AGAIN", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
