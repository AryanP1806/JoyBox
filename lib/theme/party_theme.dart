import 'package:flutter/material.dart';

class PartyColors {
  static const Color background = Color(0xFF0B0F1A);
  static const Color card = Color(0xFF161A2B);

  static const Color accentPink = Color(0xFFFF4ECD);
  static const Color accentCyan = Color(0xFF56CCF2);
  static const Color accentYellow = Color(0xFFF2C94C);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
}

class PartyGradients {
  static const LinearGradient neon = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient truth = LinearGradient(
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
  );

  static const LinearGradient dare = LinearGradient(
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
  );
}
