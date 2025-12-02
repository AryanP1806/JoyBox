import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_scoreboard.dart';

class MrWhiteFinalGuessScreen extends StatefulWidget {
  final List<MrWhitePlayer> players;

  const MrWhiteFinalGuessScreen({super.key, required this.players});

  @override
  State<MrWhiteFinalGuessScreen> createState() =>
      _MrWhiteFinalGuessScreenState();
}

class _MrWhiteFinalGuessScreenState extends State<MrWhiteFinalGuessScreen> {
  final TextEditingController guessController = TextEditingController();
  late String correctWord;

  @override
  void initState() {
    super.initState();
    // Take any civilian's word as the "true" word
    correctWord = widget.players.firstWhere((p) => p.role == "civilian").word!;
  }

  @override
  void dispose() {
    guessController.dispose();
    super.dispose();
  }

  void submitGuess() {
    final guess = guessController.text.trim();
    if (guess.isEmpty) return;

    final isCorrect = guess.toLowerCase() == correctWord.toLowerCase();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MrWhiteScoreBoardScreen(
          players: widget.players,
          mrWhiteGuessCorrect: isCorrect,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark cinematic background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000428), Color(0xFF004E92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar / title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      "FINAL GUESS",
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.7),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "MR WHITE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "This is your last chance.\nGuess the secret word.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input field
                          TextField(
                            controller: guessController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type your final guess here",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Colors.white24,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Colors.white24,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Colors.amber,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Small hint (no spoilers)
                          // const Text(
                          //   "Everyone else: look away.\nOnly Mr White should see this.",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color: Colors.white54,
                          //     fontSize: 12,
                          //   ),
                          // ),
                          const SizedBox(height: 24),

                          // Submit button
                          GestureDetector(
                            onTap: submitGuess,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD200),
                                    Color(0xFFFF9F00),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orangeAccent.withValues(
                                      alpha: 0.9,
                                    ),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Text(
                                "SUBMIT GUESS",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
