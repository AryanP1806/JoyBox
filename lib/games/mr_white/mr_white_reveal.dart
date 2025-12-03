import 'dart:math';
import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_discussion.dart';
import '../../core/safe_nav.dart';

class MrWhiteRevealScreen extends StatefulWidget {
  final MrWhiteGameConfig config;

  const MrWhiteRevealScreen({super.key, required this.config});

  @override
  State<MrWhiteRevealScreen> createState() => _MrWhiteRevealScreenState();
}

class _MrWhiteRevealScreenState extends State<MrWhiteRevealScreen>
    with SingleTickerProviderStateMixin {
  late List<MrWhitePlayer> players;
  int currentIndex = 0;
  bool revealed = false;

  late AnimationController _controller;
  late Animation<double> _flip;

  @override
  void initState() {
    super.initState();
    players = _generatePlayers();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flip = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ PLAYER + ROLE + WORD GENERATION (SAFE)
  List<MrWhitePlayer> _generatePlayers() {
    final rand = Random();
    final names = widget.config.playerNames;

    if (widget.config.customWords.isEmpty) {
      // Instead of crashing, send user back to setup
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SafeNav.goHome(context);
      });
      return [];
    }

    List<String> roles = List.filled(widget.config.playerCount, "civilian");

    int added = 0;
    while (added < widget.config.specialCount) {
      final i = rand.nextInt(widget.config.playerCount);
      if (roles[i] == "civilian") {
        roles[i] = widget.config.mode == MrWhiteMode.mrWhite
            ? "mrwhite"
            : "undercover";
        added++;
      }
    }

    final List<String> words = List.from(widget.config.customWords);
    final mainWord = words[rand.nextInt(words.length)];

    String similarWord = mainWord;
    if (widget.config.mode == MrWhiteMode.undercover && words.length > 1) {
      do {
        similarWord = words[rand.nextInt(words.length)];
      } while (similarWord == mainWord);
    }

    return List.generate(widget.config.playerCount, (i) {
      if (roles[i] == "mrwhite") {
        return MrWhitePlayer(name: names[i], role: "mrwhite");
      } else if (roles[i] == "undercover") {
        return MrWhitePlayer(
          name: names[i],
          role: "undercover",
          word: similarWord,
        );
      } else {
        return MrWhitePlayer(name: names[i], role: "civilian", word: mainWord);
      }
    });
  }

  void _reveal() {
    setState(() => revealed = true);
    _controller.forward();
  }

  void _next() {
    if (currentIndex >= players.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MrWhiteDiscussionScreen(players: players, config: widget.config),
        ),
      );
    } else {
      setState(() {
        revealed = false;
        currentIndex++;
      });
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = players[currentIndex];
    final isSpecial = player.role != "civilian";

    if (players.isEmpty) {
      // We already redirected in init; just avoid build crashes
      return const Scaffold(body: Center(child: Text("Returning to setup...")));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Role Reveal")),
      body: Center(
        child: revealed
            ? AnimatedBuilder(
                animation: _flip,
                builder: (context, child) {
                  final angle = _flip.value;
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
                child: _buildRevealCard(player, isSpecial),
              )
            : GestureDetector(
                onTap: _reveal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    "Give phone to ${player.name}\nTAP TO REVEAL",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ✅ PREMIUM REVEAL CARD (NO INVERTED TEXT)
  Widget _buildRevealCard(MrWhitePlayer player, bool isSpecial) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: (isSpecial ? Colors.redAccent : Colors.greenAccent)
                .withValues(alpha: 0.8),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            player.role.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: isSpecial ? Colors.redAccent : Colors.greenAccent,
              shadows: [
                Shadow(
                  color: isSpecial ? Colors.redAccent : Colors.greenAccent,
                  blurRadius: 30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            player.word == null
                ? "YOU HAVE NO WORD"
                : "YOUR WORD:\n${player.word}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // ✅ CONTINUE BUTTON
          GestureDetector(
            onTap: _next,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                ),
              ),
              child: Text(
                currentIndex == players.length - 1
                    ? "START GAME"
                    : "NEXT PLAYER",
                style: const TextStyle(
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
    );
  }
}
