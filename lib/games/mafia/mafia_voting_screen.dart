import 'package:flutter/material.dart';
import 'mafia_models.dart';
import 'mafia_elimination_screen.dart';

class MafiaVotingScreen extends StatefulWidget {
  final List<MafiaPlayer> players;
  final MafiaGameConfig config;

  const MafiaVotingScreen({
    super.key,
    required this.players,
    required this.config,
  });

  @override
  State<MafiaVotingScreen> createState() => _MafiaVotingScreenState();
}

class _MafiaVotingScreenState extends State<MafiaVotingScreen> {
  final Map<MafiaPlayer, int> votes = {};
  MafiaPlayer? selected;

  @override
  Widget build(BuildContext context) {
    final alive = widget.players.where((p) => p.isAlive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Voting")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            widget.config.secretVoting ? "Secret Voting" : "Open Voting",
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 20),

          ...alive.map(
            (p) => ListTile(
              title: Text(p.name),
              trailing: selected == p ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  selected = p;

                  if (!widget.config.secretVoting) {
                    votes[p] = (votes[p] ?? 0) + 1;
                  }
                });
              },
            ),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: selected == null
                ? null
                : () {
                    // ✅ For secret voting, we simulate 1-person device voting
                    if (widget.config.secretVoting) {
                      votes[selected!] = (votes[selected!] ?? 0) + 1;
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MafiaEliminationScreen(
                          players: widget.players,
                          votes: votes,
                        ),
                      ),
                    );
                  },
            child: const Text("Confirm Vote"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
