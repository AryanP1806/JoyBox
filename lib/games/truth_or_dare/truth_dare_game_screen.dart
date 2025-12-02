import 'dart:math';
import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';
import '../../audio/sound_manager.dart';

import 'truth_dare_models.dart';
import 'truth_dare_packs.dart';
import 'truth_dare_results_screen.dart';

class TruthDareGameScreen extends StatefulWidget {
  final TruthDareGameConfig config;

  const TruthDareGameScreen({super.key, required this.config});

  @override
  State<TruthDareGameScreen> createState() => _TruthDareGameScreenState();
}

class _TruthDareGameScreenState extends State<TruthDareGameScreen>
    with SingleTickerProviderStateMixin {
  late List<TruthDarePlayer> players;
  late List<int> _shuffleBag;
  int currentPlayerIndex = 0;

  TruthDareQuestion? currentQuestion;
  TruthOrDareChoice? currentChoice;

  List<TruthDareQuestion> truthList = [];
  List<TruthDareQuestion> dareList = [];
  bool loadingPacks = true;

  final rand = Random();

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    players = List.generate(
      widget.config.playerCount,
      (i) => TruthDarePlayer(name: widget.config.playerNames[i]),
    );

    _shuffleBag = List.generate(players.length, (i) => i)..shuffle(rand);

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);

    _loadPacks();
    _selectNextPlayer();
  }

  Future<void> _loadPacks() async {
    truthList = List.from(
      await TruthDarePacks.getTruths(widget.config.category),
    );
    dareList = List.from(await TruthDarePacks.getDares(widget.config.category));

    if (truthList.isEmpty) {
      truthList.add(
        TruthDareQuestion(
          text: "No truths added yet.",
          type: TruthOrDareChoice.truth,
          category: widget.config.category,
        ),
      );
    }

    if (dareList.isEmpty) {
      dareList.add(
        TruthDareQuestion(
          text: "No dares added yet.",
          type: TruthOrDareChoice.dare,
          category: widget.config.category,
        ),
      );
    }

    setState(() => loadingPacks = false);
  }

  void _selectNextPlayer() {
    if (_shuffleBag.isEmpty) {
      _shuffleBag = List.generate(players.length, (i) => i)..shuffle(rand);
    }

    setState(() {
      currentPlayerIndex = _shuffleBag.removeAt(0);
      currentQuestion = null;
      currentChoice = null;
    });

    _flipController.reset();
  }

  TruthDarePlayer get currentPlayer => players[currentPlayerIndex];

  void _pickTruth() {
    SoundManager.playTap();
    currentChoice = TruthOrDareChoice.truth;
    currentQuestion = truthList[rand.nextInt(truthList.length)];
    _flipController.forward();
    setState(() {});
  }

  void _pickDare() {
    SoundManager.playTap();
    currentChoice = TruthOrDareChoice.dare;
    currentQuestion = dareList[rand.nextInt(dareList.length)];
    _flipController.forward();
    setState(() {});
  }

  void _failed() {
    SoundManager.playFail();
    setState(() {
      currentPlayer.score -= 1;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _selectNextPlayer();
    });
  }

  void _confirmCompleted() {
    SoundManager.playWin();
    setState(() {
      currentPlayer.score += 1; // FORCE SCORE WITHOUT MODE CHECK
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _selectNextPlayer();
    });
  }

  void _skip() {
    _selectNextPlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingPacks) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final player = currentPlayer;
    // Text(
    //   "Score: ${player.score}",
    //   style: const TextStyle(
    //     color: PartyColors.accentYellow,
    //     fontSize: 18,
    //     fontWeight: FontWeight.bold,
    //   ),
    // );

    return Scaffold(
      backgroundColor: PartyColors.background,
      appBar: AppBar(
        backgroundColor: PartyColors.background,

        title: const Text("Truth or Dare"),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TruthDareResultsScreen(players: players),
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
            Text(
              "It's ${player.name}'s Turn",
              style: const TextStyle(
                color: PartyColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Score: ${player.score}",
              style: const TextStyle(
                color: PartyColors.accentYellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedBuilder(
              animation: _flipAnimation,
              builder: (_, child) {
                final angle = _flipAnimation.value * pi;

                final isBack = angle > pi / 2;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: isBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(pi),
                          child: child,
                        )
                      : child,
                );
              },
              child: PartyCard(
                child: Center(
                  child: currentQuestion == null
                      ? const Text(
                          "Choose Truth or Dare",
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        )
                      : Text(
                          currentQuestion!.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            if (currentQuestion == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PartyButton(
                    text: "TRUTH",
                    gradient: PartyGradients.truth,
                    onTap: _pickTruth,
                  ),
                  PartyButton(
                    text: "DARE",
                    gradient: PartyGradients.dare,
                    onTap: _pickDare,
                  ),
                ],
              ),

            if (currentQuestion != null) const SizedBox(height: 30),

            if (currentQuestion != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PartyButton(
                    text: "DONE",
                    gradient: PartyGradients.truth,
                    onTap: _confirmCompleted,
                  ),
                  // PartyButton(
                  //   text: "FAILED",
                  //   gradient: PartyGradients.dare,
                  //   onTap: _skip,
                  // ),
                  PartyButton(
                    text: "FAILED",
                    gradient: PartyGradients.dare,
                    onTap: _failed,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
