import 'dart:math';
import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';

import 'most_likely_models.dart';
import 'most_likely_packs.dart';
import 'most_likely_results_screen.dart';

class MostLikelyGameScreen extends StatefulWidget {
  final MostLikelyGameConfig config;

  const MostLikelyGameScreen({super.key, required this.config});

  @override
  State<MostLikelyGameScreen> createState() => _MostLikelyGameScreenState();
}

class _MostLikelyGameScreenState extends State<MostLikelyGameScreen> {
  late List<MostLikelyPlayer> players;
  late List<String> questionPool;

  int currentRound = 1;
  int currentVoterIndex = 0;

  String currentQuestion = "";
  Map<int, int> votes = {}; // playerIndex -> voteCount

  bool revealPhase = false;

  @override
  void initState() {
    super.initState();

    players = widget.config.playerNames
        .map((n) => MostLikelyPlayer(name: n))
        .toList();

    questionPool = MostLikelyPacks.buildQuestionPool(widget.config.packs);

    questionPool.shuffle(Random());

    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    if (questionPool.isEmpty) return;

    setState(() {
      currentQuestion = questionPool.removeLast();
      votes.clear();
      revealPhase = false;
      currentVoterIndex = 0;
    });
  }

  bool get isLastRound {
    if (widget.config.endCondition == MostLikelyEndCondition.fixedRounds) {
      return currentRound >= (widget.config.totalRounds ?? 1);
    }
    return false;
  }

  // ---------------- VOTING ----------------

  void _voteFor(int votedIndex) {
    final voterIndex = currentVoterIndex;

    if (!widget.config.allowSelfVote && voterIndex == votedIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't vote for yourself")),
      );
      return;
    }

    setState(() {
      votes[votedIndex] = (votes[votedIndex] ?? 0) + 1;

      currentVoterIndex++;

      if (currentVoterIndex >= players.length) {
        revealPhase = true;
        _applyScoring();
      }
    });
  }

  // ---------------- SCORING ----------------

  void _applyScoring() {
    if (widget.config.scoringMode == MostLikelyScoringMode.none) return;

    int maxVotes = 0;
    int winningIndex = 0;

    votes.forEach((player, count) {
      if (count > maxVotes) {
        maxVotes = count;
        winningIndex = player;
      }
    });

    if (widget.config.scoringMode == MostLikelyScoringMode.winnerGetsPoint) {
      players[winningIndex].score += 1;
    }

    if (widget.config.scoringMode == MostLikelyScoringMode.loserGetsPoint) {
      players[winningIndex].score += 1;
    }
  }

  // ---------------- NEXT ROUND ----------------

  void _nextRound() {
    if (isLastRound) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MostLikelyResultsScreen(players: players),
        ),
      );
      return;
    }

    setState(() {
      currentRound++;
      _loadNextQuestion();
    });
  }

  String get punishmentLabel {
    switch (widget.config.punishmentMode) {
      case MostLikelyPunishmentMode.truth:
        return "TRUTH";
      case MostLikelyPunishmentMode.dare:
        return "DARE";
      case MostLikelyPunishmentMode.drink:
        return "DRINK";
      case MostLikelyPunishmentMode.custom:
        return "CUSTOM";
      default:
        return "NONE";
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty || (questionPool.isEmpty && currentQuestion.isEmpty)) {
      return const Scaffold(body: Center(child: Text("Game data missing")));
    }

    // REMOVED: final currentVoter = players[currentVoterIndex];
    // This line caused the crash because it ran even when voting was finished.

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,
        title: Text("Round $currentRound"),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MostLikelyResultsScreen(players: players),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PartyCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  currentQuestion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (!revealPhase) ...[
              // SAFE ACCESS HERE: because we are inside !revealPhase
              Text(
                "Voter: ${players[currentVoterIndex].name}",
                style: const TextStyle(
                  color: PartyColors.accentYellow,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: players.length,
                  itemBuilder: (_, i) {
                    final target = players[i];
                    return PartyButton(
                      text: target.name,
                      gradient: PartyGradients.truth,
                      onTap: () => _voteFor(i),
                    );
                  },
                ),
              ),
            ],

            if (revealPhase) ...[
              const SizedBox(height: 16),
              const Text(
                "RESULT",
                style: TextStyle(
                  color: PartyColors.accentPink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ...votes.entries.map((e) {
                return Text(
                  "${players[e.key].name} → ${e.value} votes",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                );
              }),

              const SizedBox(height: 20),

              if (widget.config.punishmentMode != MostLikelyPunishmentMode.none)
                PartyCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Punishment: $punishmentLabel",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              PartyButton(
                text: isLastRound ? "VIEW FINAL RESULTS" : "NEXT ROUND",
                gradient: PartyGradients.dare,
                onTap: _nextRound,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
