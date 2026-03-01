import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A widget that renders [child] on top of the app's standard background image
/// with a rich gradient overlay for a beautiful, immersive UI.
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: AppBackground(child: YourBodyWidget()),
/// )
/// ```
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Layer 1: Background texture image ──────────────────────
        Positioned.fill(
          child: Opacity(
            opacity: 0.18,
            child: Image.asset(
              'assets/images/dark_bg1.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // ── Layer 2: Gradient overlay for depth & beauty ──────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundOverlayGradient,
            ),
          ),
        ),
        // ── Layer 3: Subtle radial glow – top-right accent ─────────
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF026CDF).withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // ── Layer 4: Subtle radial glow – bottom-left accent ───────
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7B2FBE).withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // ── Layer 5: Content ────────────────────────────────────────
        child,
      ],
    );
  }
}
