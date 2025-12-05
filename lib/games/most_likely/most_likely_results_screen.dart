import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- ADDED
import '../../auth/auth_service.dart'; // <--- ADDED
import '../../theme/party_theme.dart';
import 'most_likely_models.dart';

class MostLikelyResultsScreen extends StatefulWidget {
  final List<MostLikelyPlayer> players;

  const MostLikelyResultsScreen({super.key, required this.players});

  @override
  State<MostLikelyResultsScreen> createState() =>
      _MostLikelyResultsScreenState();
}

class _MostLikelyResultsScreenState extends State<MostLikelyResultsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Trigger save when results load
    _saveGame();
  }

  // ✅ SAVE LOGIC
  Future<void> _saveGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Calculate stats again for the database
    final sorted = [...widget.players]
      ..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.first;

    // 2. Save to History
    await AuthService().addGameHistory(
      gameName: "Most Likely To",
      won: true, // In this party game, completing it counts as a "win"
      details: {
        "winner": winner.name,
        "top_score": winner.score,
        "player_count": widget.players.length,
      },
    );

    // 3. Update Profile Stats
    await AuthService().updateGameStats(won: true);
  }

  @override
  Widget build(BuildContext context) {
    // Sort players for display
    final sorted = [...widget.players]
      ..sort((a, b) => b.score.compareTo(a.score));
    final winner = sorted.first;

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: const Text("Final Results"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🏆 WINNER DISPLAY
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PartyColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PartyColors.accentYellow.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PartyColors.accentYellow.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "🏆 WINNER 🏆",
                    style: TextStyle(color: Colors.white54, letterSpacing: 2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    winner.name,
                    style: const TextStyle(
                      fontSize: 32,
                      color: PartyColors.accentYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${winner.score} Votes",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.white24),

            // 📋 LEADERBOARD
            Expanded(
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final p = sorted[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: PartyColors.accentPink.withOpacity(0.2),
                      child: Text(
                        "#${i + 1}",
                        style: const TextStyle(
                          color: PartyColors.accentPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    trailing: Text(
                      p.score.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  );
                },
              ),
            ),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PartyColors.accentPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // Pop twice to go back to Setup, or once for Game
                  Navigator.pop(context);
                },
                child: const Text(
                  "PLAY AGAIN",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
