import 'package:flutter/material.dart';

class StarryTheme {
  StarryTheme._();

  // Background Colors
  static const Color darkBackground = Color(0xFF1A0B2E); // Deep purple/black
  static const Color purpleCardBg = Color(0xFF2D1B4E);

  // Gradients
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2A1B42), // Lighter purple top
      Color(0xFF11051F), // Darker purple bottom
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6E45E2), Color(0xFF88D3CE)],
  );

  static LinearGradient glassGradient({double opacity = 0.2}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: opacity),
        Colors.white.withValues(alpha: opacity * 0.5),
      ],
    );
  }

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB39DDB); // Light purple text

  // Accent Colors
  static const Color accentPink = Color(0xFFFF69B4);
  static const Color accentSecondary = Color(
    0xFFB3E5FC,
  ); // Light Blue/Cyan for secondary accents
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentGold = Color(0xFFFFD700);
}
