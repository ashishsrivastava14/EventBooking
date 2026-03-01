import 'package:flutter/material.dart';

enum SeatDisplayState { available, selected, taken, vip, accessible, restricted }

class SeatMapSeatWidget extends StatelessWidget {
  final String seatId;
  final SeatDisplayState state;
  final double price;
  final VoidCallback? onTap;
  final double size;

  const SeatMapSeatWidget({
    super.key,
    required this.seatId,
    required this.state,
    required this.price,
    this.onTap,
    this.size = 22,
  });

  Color get _color {
    switch (state) {
      case SeatDisplayState.available:
        return const Color(0xFF026CDF);
      case SeatDisplayState.selected:
        return const Color(0xFFFF6B00);
      case SeatDisplayState.taken:
        return const Color(0xFF3A3F4E);
      case SeatDisplayState.vip:
        return const Color(0xFFFFD700);
      case SeatDisplayState.accessible:
        return const Color(0xFF00C48C);
      case SeatDisplayState.restricted:
        return const Color(0xFFFF4D4F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTappable =
        state != SeatDisplayState.taken && state != SeatDisplayState.restricted;

    return GestureDetector(
      onTap: isTappable ? onTap : null,
      child: Tooltip(
        message: '$seatId — \$${price.toStringAsFixed(0)}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: state == SeatDisplayState.taken
                ? _color.withValues(alpha: 0.25)
                : state == SeatDisplayState.selected
                    ? _color
                    : _color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _color,
              width: state == SeatDisplayState.selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: state == SeatDisplayState.accessible
                ? Icon(Icons.accessible, size: size * 0.55, color: _color)
                : state == SeatDisplayState.restricted
                    ? Icon(Icons.block, size: size * 0.5, color: _color)
                    : Text(
                        seatId.split('-').last.replaceAll(RegExp(r'[A-Z]'), ''),
                        style: TextStyle(
                          fontSize: size * 0.32,
                          fontWeight: FontWeight.w700,
                          color: state == SeatDisplayState.selected
                              ? Colors.white
                              : state == SeatDisplayState.taken
                                  ? _color.withValues(alpha: 0.4)
                                  : _color,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
