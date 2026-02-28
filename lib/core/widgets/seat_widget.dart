import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SeatState { available, selected, taken, vip }

class SeatWidget extends StatelessWidget {
  final String label;
  final SeatState state;
  final VoidCallback? onTap;

  const SeatWidget({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (state) {
      case SeatState.available:
        color = AppColors.seatAvailable;
        break;
      case SeatState.selected:
        color = AppColors.seatSelected;
        break;
      case SeatState.taken:
        color = AppColors.seatTaken;
        break;
      case SeatState.vip:
        color = AppColors.seatVip;
        break;
    }

    return GestureDetector(
      onTap: state == SeatState.taken ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: state == SeatState.taken
              ? color.withOpacity(0.3)
              : state == SeatState.selected
                  ? color
                  : color.withOpacity(0.2),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
            bottom: Radius.circular(4),
          ),
          border: Border.all(
            color: color,
            width: state == SeatState.selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: state == SeatState.selected
                  ? Colors.white
                  : state == SeatState.taken
                      ? color.withOpacity(0.5)
                      : color,
            ),
          ),
        ),
      ),
    );
  }
}
