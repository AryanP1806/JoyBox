import 'dart:async';
import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_role_reveal.dart';
import '../../core/safe_nav.dart';

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
      if (!mounted) return;

      setState(() => timeLeft--);

      if (timeLeft <= 0) {
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
    if (votes.isEmpty) return;

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
    if (alive.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Discussion & Voting")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // ✅ TIMER BAR
          if (widget.config.timerEnabled && !votingStarted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    "Discussion Time: $timeLeft s",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: timeLeft / widget.config.timerSeconds,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // ✅ START VOTING BUTTON
          if (!votingStarted)
            Padding(
              padding: const EdgeInsets.all(14),
              child: GestureDetector(
                onTap: startVoting,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF512F), Color(0xFFF09819)],
                    ),
                  ),
                  child: const Text(
                    "START VOTING",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

          // ✅ PLAYER LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: alive.length,
              itemBuilder: (context, index) {
                final p = alive[index];
                final realIndex = widget.players.indexOf(p);
                final voteCount = votes[realIndex] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (votingStarted)
                        GestureDetector(
                          onTap: () => castVote(realIndex),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                              ),
                            ),
                            child: Text(
                              widget.config.secretVoting
                                  ? "VOTE"
                                  : "VOTE ($voteCount)",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        const Text(
                          "ALIVE",
                          style: TextStyle(color: Colors.white54),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ FINISH VOTING
          if (votingStarted)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: finishVoting,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    ),
                  ),
                  child: const Text(
                    "FINISH VOTING",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
