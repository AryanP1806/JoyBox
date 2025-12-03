// lib/games/assassin/assassin_play_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../core/safe_nav.dart';
import '../../theme/party_theme.dart';
import '../../widgets/party_card.dart';
import '../../widgets/party_button.dart';
import '../../widgets/pulse_timer_text.dart';

import 'assassin_models.dart';
import 'assassin_results_screen.dart';

class AssassinPlayScreen extends StatefulWidget {
  final List<AssassinPlayer> players;
  final AssassinGameConfig config;

  const AssassinPlayScreen({
    super.key,
    required this.players,
    required this.config,
  });

  @override
  State<AssassinPlayScreen> createState() => _AssassinPlayScreenState();
}

class _AssassinPlayScreenState extends State<AssassinPlayScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _musicStarted = false;

  Timer? _timer;
  late int _secondsLeft;
  late bool _timerEnabled;

  @override
  void initState() {
    super.initState();

    _timerEnabled = widget.config.timerEnabled;
    _secondsLeft = (widget.config.timerSeconds).clamp(10, 600);

    if (_timerEnabled) {
      _startTimer();
    }

    _maybeStartMusic();
  }

  Future<void> _maybeStartMusic() async {
    if (widget.config.backgroundMusic != true) return;
    if (_musicStarted) return;

    _musicStarted = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/assassin_bg.mp3'));
    } catch (_) {
      // ignore if missing
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft <= 0) {
        timer.cancel();
        // When time runs out, civilians win (you can flip this rule if you want)
        _onWinner(AssassinWinner.civilians);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  void _onWinner(AssassinWinner winner) {
    if (widget.players.isEmpty) {
      SafeNav.goHome(context);
      return;
    }

    _timer?.cancel();

    SafeNav.safeReplace(
      context,
      AssassinResultsScreen(
        players: widget.players,
        winner: winner,
        config: widget.config, // ✅ pass config forward
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
      SafeNav.goHome(context);
      return const SizedBox.shrink();
    }

    final detective = widget.players.firstWhere(
      (p) => p.role == AssassinRole.detective,
      orElse: () =>
          AssassinPlayer(name: "Detective", role: AssassinRole.detective),
    );

    return Scaffold(
      backgroundColor: PartyColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "WINK ASSASSIN – LIVE ROUND",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (_timerEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: PulseTimerText(
                  text: "00:${_secondsLeft.toString().padLeft(2, '0')}",
                  color: Colors.redAccent,
                ),
              ),

            const SizedBox(height: 18),

            PartyCard(
              child: Column(
                children: [
                  Text(
                    "Detective: ${detective.name}",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Victims: wait 3–7 seconds\n"
                    "after the wink before dying.\n\n"
                    "Detective has ONE accusation.\n"
                    "Play in real life – phone stays aside.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            PartyButton(
              text: "CIVILIANS WIN",
              gradient: PartyGradients.truth,
              onTap: () => _onWinner(AssassinWinner.civilians),
            ),

            const SizedBox(height: 12),

            PartyButton(
              text: "ASSASSIN WINS",
              gradient: PartyGradients.dare,
              onTap: () => _onWinner(AssassinWinner.assassin),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
