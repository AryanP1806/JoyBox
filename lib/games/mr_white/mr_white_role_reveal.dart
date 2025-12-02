import 'package:flutter/material.dart';
import 'mr_white_models.dart';
import 'mr_white_final_guess.dart';
import 'mr_white_scoreboard.dart';
import 'mr_white_discussion.dart';

class MrWhiteRoleRevealScreen extends StatefulWidget {
  final MrWhitePlayer eliminatedPlayer;
  final List<MrWhitePlayer> players;
  final MrWhiteGameConfig config;

  const MrWhiteRoleRevealScreen({
    super.key,
    required this.eliminatedPlayer,
    required this.players,
    required this.config,
  });

  @override
  State<MrWhiteRoleRevealScreen> createState() =>
      _MrWhiteRoleRevealScreenState();
}

class _MrWhiteRoleRevealScreenState extends State<MrWhiteRoleRevealScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  int get aliveCivilians =>
      widget.players.where((p) => p.role == "civilian" && p.isAlive).length;

  int get aliveSpecial =>
      widget.players.where((p) => p.role != "civilian" && p.isAlive).length;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _glow = Tween<double>(
      begin: 0.0,
      end: 25.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue(BuildContext context) {
    final isMrWhite = widget.eliminatedPlayer.role == "mrwhite";

    if (isMrWhite) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MrWhiteFinalGuessScreen(players: widget.players),
        ),
      );
      return;
    }

    if (aliveSpecial >= aliveCivilians) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MrWhiteScoreBoardScreen(
            players: widget.players,
            mrWhiteWonByNumbers: true,
          ),
        ),
      );
      return;
    }

    if (aliveSpecial == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MrWhiteScoreBoardScreen(
            players: widget.players,
            civiliansWon: true,
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MrWhiteDiscussionScreen(
          players: widget.players,
          config: widget.config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleText = widget.eliminatedPlayer.role.toUpperCase();
    final isCivilian = widget.eliminatedPlayer.role == "civilian";

    final roleColor = isCivilian ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withValues(alpha: _glow.value / 80),
                          blurRadius: _glow.value,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.eliminatedPlayer.name,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          roleText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: roleColor,
                            shadows: [
                              Shadow(
                                color: roleColor.withValues(alpha: 0.8),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          "WAS ELIMINATED",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: () => _continue(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD200), Color(0xFFFF9F00)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orangeAccent.withValues(
                                    alpha: 0.8,
                                  ),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: const Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 18,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
