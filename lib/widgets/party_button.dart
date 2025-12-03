import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PartyButton extends StatelessWidget {
  final String text;
  final String? subText;
  final VoidCallback onTap;
  final LinearGradient gradient;

  const PartyButton({
    super.key,
    required this.text,
    this.subText,
    required this.onTap,
    required this.gradient,
  });

  static final AudioPlayer _player = AudioPlayer();

  Future<void> _handleTap() async {
    // ✅ HAPTIC CLICK
    HapticFeedback.mediumImpact();

    // ✅ BUTTON SOUND
    try {
      await _player.stop();
      await _player.play(AssetSource("sounds/click.mp3"));
    } catch (_) {}

    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(32),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.55),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
            if (subText != null) ...[
              const SizedBox(height: 4),
              Text(
                subText!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
