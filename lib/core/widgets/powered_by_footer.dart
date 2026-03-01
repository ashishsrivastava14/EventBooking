import 'package:flutter/material.dart';

class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by ',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Image.asset(
            'assets/images/quickprepai.png',
            height: 18,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
