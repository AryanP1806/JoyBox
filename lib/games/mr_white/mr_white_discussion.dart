import 'dart:async';
import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_role_reveal.dart';

class MrWhiteDiscussionScreen extends StatefulWidget {
  final List<MrWhitePlayer> players;
  final MrWhiteGameConfig config;

  const MrWhiteDiscussionScreen({
    super.key,
    required this.players,
    required this.config,
  });

  @override
  State<MrWhiteDiscussionScreen> createState() =>
      _MrWhiteDiscussionScreenState();
}

class _MrWhiteDiscussionScreenState extends State<MrWhiteDiscussionScreen> {
  final Map<int, int> votes = {};
  bool votingStarted = false;
  late int timeLeft;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timeLeft = widget.config.timerSeconds;
    if (widget.config.timerEnabled) startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = widget.config.timerSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => timeLeft--);
      if (timeLeft == 0) {
        t.cancel();
        startVoting();
      }
    });
  }

  void startVoting() {
    setState(() {
      votingStarted = true;
      votes.clear();
    });
  }

  void castVote(int index) {
    if (!votingStarted) return;
    setState(() {
      votes[index] = (votes[index] ?? 0) + 1;
    });
  }

  void finishVoting() {
    int maxVotes = -1;
    int eliminatedIndex = -1;

    votes.forEach((k, v) {
      if (v > maxVotes) {
        maxVotes = v;
        eliminatedIndex = k;
      }
    });

    if (eliminatedIndex == -1) return;

    final eliminatedPlayer = widget.players[eliminatedIndex];
    eliminatedPlayer.isAlive = false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MrWhiteRoleRevealScreen(
          eliminatedPlayer: eliminatedPlayer,
          players: widget.players,
          config: widget.config,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alive = widget.players.where((p) => p.isAlive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Discussion & Voting")),
      body: Column(
        children: [
          if (widget.config.timerEnabled && !votingStarted)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text("Time Left: $timeLeft sec"),
            ),

          if (!votingStarted)
            ElevatedButton(
              onPressed: startVoting,
              child: const Text("Start Voting"),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: alive.length,
              itemBuilder: (context, index) {
                final p = alive[index];
                final realIndex = widget.players.indexOf(p);

                return ListTile(
                  title: Text(p.name),
                  trailing: votingStarted
                      ? ElevatedButton(
                          onPressed: () => castVote(realIndex),
                          child: widget.config.secretVoting
                              ? const Text("Vote")
                              : Text("Vote (${votes[realIndex] ?? 0})"),
                        )
                      : const Text("Alive"),
                );
              },
            ),
          ),

          if (votingStarted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: finishVoting,
                child: const Text("Finish Voting"),
              ),
            ),
        ],
      ),
    );
  }
}
