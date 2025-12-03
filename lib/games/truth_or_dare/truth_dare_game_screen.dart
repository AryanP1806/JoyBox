import 'dart:math';
import 'package:flutter/material.dart';

import '../../theme/party_theme.dart';
import '../../widgets/party_button.dart';
import '../../widgets/party_card.dart';
import '../../audio/sound_manager.dart';
import '../../widgets/physics_spin_bottle.dart';

import 'truth_dare_models.dart';
import 'truth_dare_packs.dart';
import 'truth_dare_results_screen.dart';
import 'truth_dare_setup_screen.dart';

class TruthDareGameScreen extends StatefulWidget {
  final TruthDareGameConfig config;

  const TruthDareGameScreen({super.key, required this.config});

  @override
  State<TruthDareGameScreen> createState() => _TruthDareGameScreenState();
}

class _TruthDareGameScreenState extends State<TruthDareGameScreen> {
  late List<TruthDarePlayer> players;
  late List<int> _shuffleBag;
  int currentPlayerIndex = 0;

  TruthDareQuestion? currentQuestion;
  TruthOrDareChoice? currentChoice;

  List<TruthDareQuestion> truthList = [];
  List<TruthDareQuestion> dareList = [];
  bool loadingPacks = true;

  final rand = Random();

  // skipping / switching state
  final Map<int, int> _skipsUsed = {};
  bool _hasSwitchedThisTurn = false;

  @override
  void initState() {
    super.initState();

    players = List.generate(
      widget.config.playerCount,
      (i) => TruthDarePlayer(name: widget.config.playerNames[i]),
    );

    _shuffleBag = List.generate(players.length, (i) => i)..shuffle(rand);

    _loadPacks();

    // First player selection depends on mode
    if (widget.config.turnSelectionMode == TurnSelectionMode.random) {
      _selectNextPlayer(); // random player to start
    } else {
      // bottle mode → start at index 0, bottle will move to next players
      currentPlayerIndex = 0;
    }
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
      _hasSwitchedThisTurn = false;
    });
  }

  TruthDarePlayer get currentPlayer => players[currentPlayerIndex];

  // --- helpers for skip logic ---

  bool _canSkipCurrentPlayer() {
    if (widget.config.skipBehavior == SkipBehavior.disabled) {
      return false;
    }
    if (!widget.config.limitSkips) {
      return true;
    }
    final used = _skipsUsed[currentPlayerIndex] ?? 0;
    return used < widget.config.maxSkipsPerPlayer;
  }

  void _recordSkipUsed() {
    _skipsUsed[currentPlayerIndex] = (_skipsUsed[currentPlayerIndex] ?? 0) + 1;
  }

  // --- question selection ---

  void _pickTruth() {
    SoundManager.playTap();
    setState(() {
      currentChoice = TruthOrDareChoice.truth;
      currentQuestion = truthList[rand.nextInt(truthList.length)];
      _hasSwitchedThisTurn = false; // fresh question → allow switch
    });
  }

  void _pickDare() {
    SoundManager.playTap();
    setState(() {
      currentChoice = TruthOrDareChoice.dare;
      currentQuestion = dareList[rand.nextInt(dareList.length)];
      _hasSwitchedThisTurn = false; // fresh question → allow switch
    });
  }

  void _switchChoice() {
    if (!widget.config.allowSwitchAfterQuestion) return;
    if (currentQuestion == null || currentChoice == null) return;
    if (_hasSwitchedThisTurn) return; // prevent multiple switches

    SoundManager.playTap();

    setState(() {
      if (currentChoice == TruthOrDareChoice.truth) {
        currentChoice = TruthOrDareChoice.dare;
        currentQuestion = dareList[rand.nextInt(dareList.length)];
      } else {
        currentChoice = TruthOrDareChoice.truth;
        currentQuestion = truthList[rand.nextInt(truthList.length)];
      }
      _hasSwitchedThisTurn = true;
    });
  }

  // --- result actions ---

  void _failed() {
    SoundManager.playFail();

    // simple scoring: failure → -1
    setState(() {
      currentPlayer.score -= 1;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (widget.config.turnSelectionMode == TurnSelectionMode.random) {
        _selectNextPlayer();
      } else {
        // bottle mode → wait for next spin
        setState(() {
          currentQuestion = null;
          currentChoice = null;
          _hasSwitchedThisTurn = false;
        });
      }
    });
  }

  void _confirmCompleted() {
    SoundManager.playWin();

    // simple scoring: success → +1 (same as your old code)
    setState(() {
      currentPlayer.score += 1;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (widget.config.turnSelectionMode == TurnSelectionMode.random) {
        _selectNextPlayer();
      } else {
        // bottle mode → wait for next spin
        setState(() {
          currentQuestion = null;
          currentChoice = null;
          _hasSwitchedThisTurn = false;
        });
      }
    });
  }

  void _skip() {
    if (!_canSkipCurrentPlayer()) {
      // silently ignore; you can add a SnackBar if you want feedback
      return;
    }

    SoundManager.playTap();

    // Optional penalty if configured
    if (widget.config.skipBehavior == SkipBehavior.penalty) {
      setState(() {
        currentPlayer.score -= 1;
      });
    }

    _recordSkipUsed();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (widget.config.turnSelectionMode == TurnSelectionMode.random) {
        _selectNextPlayer();
      } else {
        // bottle mode → still same player until next spin
        setState(() {
          currentQuestion = null;
          currentChoice = null;
          _hasSwitchedThisTurn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingPacks) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final player = currentPlayer;
    final canSkip = _canSkipCurrentPlayer();

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TruthDareSetupScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: PartyColors.background,
        appBar: AppBar(
          backgroundColor: PartyColors.background,
          title: const Text("Truth or Dare"),
          actions: [
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                Navigator.pushReplacement(
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
              // 🔁 BOTTLE ONLY IN SPIN-BOTTLE MODE
              if (widget.config.turnSelectionMode ==
                  TurnSelectionMode.spinBottle)
                PhysicsSpinBottle(
                  onSpinEnd: () {
                    _selectNextPlayer(); // new player when bottle stops
                  },
                )
              else
                const SizedBox(height: 16),

              const SizedBox(height: 12),

              Text(
                "It's ${player.name}'s Turn",
                style: const TextStyle(
                  color: PartyColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "Score: ${player.score}",
                style: const TextStyle(
                  color: PartyColors.accentYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              PartyCard(
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

              const SizedBox(height: 30),

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

              if (currentQuestion != null) const SizedBox(height: 24),

              if (currentQuestion != null)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    PartyButton(
                      text: "DONE",
                      gradient: PartyGradients.truth,
                      onTap: _confirmCompleted,
                    ),

                    if (canSkip)
                      PartyButton(
                        text: "SKIP",
                        // gradient: PartyGradients.truth,
                        gradient: LinearGradient(
                          colors: [Colors.yellowAccent, Colors.orangeAccent],
                        ),
                        onTap: _skip,
                      ),
                    PartyButton(
                      text: "FAILED",
                      gradient: PartyGradients.dare,
                      onTap: _failed,
                    ),
                    if (widget.config.allowSwitchAfterQuestion &&
                        !_hasSwitchedThisTurn)
                      PartyButton(
                        text: "SWITCH",
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.pinkAccent],
                        ),
                        onTap: _switchChoice,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
