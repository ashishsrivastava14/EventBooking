import 'package:flutter/material.dart';

/// A widget that renders [child] on top of the app's standard background image.
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
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/dark_bg1.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
