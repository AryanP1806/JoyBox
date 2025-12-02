import 'package:flutter/material.dart';
import '../theme/party_theme.dart';

class PartyCard extends StatelessWidget {
  final Widget child;

  const PartyCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PartyGradients.neon,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PartyColors.accentPink.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
