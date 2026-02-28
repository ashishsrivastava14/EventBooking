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

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF026CDF), Color(0xFF0148A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2433), Color(0xFF141824)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
