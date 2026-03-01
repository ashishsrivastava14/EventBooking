import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF026CDF);
  static const Color secondary = Color(0xFFFF6B00);
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141824);
  static const Color card = Color(0xFF1E2433);
  static const Color success = Color(0xFF00C48C);
  static const Color error = Color(0xFFFF4D4F);

  // Light theme
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF0F2F5);

  // Text colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B3C0);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6E7191);

  // Seat Colors
  static const Color seatAvailable = Color(0xFF026CDF);
  static const Color seatSelected = Color(0xFFFF6B00);
  static const Color seatTaken = Color(0xFF4A4E5A);
  static const Color seatVip = Color(0xFFFFD700);

  // ─── Gradients ───────────────────────────────────────────────
  /// Main brand gradient – blue to deep indigo
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF026CDF), Color(0xFF0148A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Vibrant accent gradient – blue to orange/purple
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF026CDF), Color(0xFF7B2FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary button / tag gradient – orange to pink
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF3D6F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient – teal to green
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C48C), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background overlay gradient – applied over background image
  static const LinearGradient backgroundOverlayGradient = LinearGradient(
    colors: [
      Color(0xCC0A0E1A), // top: dark navy 80% opacity
      Color(0x880D1432), // mid: deep blue 53% opacity
      Color(0xAA0A0E1A), // bottom: dark navy 67% opacity
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  /// AppBar gradient – subtle top strip
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF0D1432), Color(0xFF0A0E1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card gradient – rich dark surface
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF232B3E), Color(0xFF181E2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card gradient for light theme
  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFEEF2FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Image scrim – fade bottom of images to dark
  static const LinearGradient imageScrimGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Section header gradient text helper colors
  static const Color gradientStart = Color(0xFF5BABF5);
  static const Color gradientEnd = Color(0xFF7B2FBE);
}
