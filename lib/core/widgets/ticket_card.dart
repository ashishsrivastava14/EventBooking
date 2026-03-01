import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../theme/app_colors.dart';
import 'app_image.dart';

class TicketCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF026CDF).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gradient left accent strip
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: booking.status == BookingStatus.confirmed
                        ? AppColors.successGradient
                        : booking.status == BookingStatus.cancelled
                            ? const LinearGradient(
                                colors: [AppColors.error, Color(0xFFFF8A80)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : booking.status == BookingStatus.checkedIn
                                ? AppColors.primaryGradient
                                : AppColors.cardGradient,
                  ),
                ),
                Expanded(
                  child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(
                      imageUrl: booking.eventImageUrl,
                      width: 70,
                      height: 70,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.eventTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(booking.eventDate)} · ${booking.venue}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${booking.tierName} · ${booking.seats.join(", ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const Spacer(),
                            _buildStatusBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Dashed divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      height: 1,
                      color: index % 2 == 0
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1))
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking: ${booking.id.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppColors.primaryGradient.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      '\$${booking.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (booking.status) {
      case BookingStatus.confirmed:
        color = AppColors.success;
        text = 'Confirmed';
        break;
      case BookingStatus.checkedIn:
        color = AppColors.primary;
        text = 'Checked In';
        break;
      case BookingStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
      case BookingStatus.completed:
        color = AppColors.textSecondaryDark;
        text = 'Completed';
        break;
    }

    final gradient = booking.status == BookingStatus.confirmed
        ? AppColors.successGradient
        : booking.status == BookingStatus.cancelled
            ? const LinearGradient(
                colors: [AppColors.error, Color(0xFFFF8A80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : booking.status == BookingStatus.checkedIn
                ? AppColors.primaryGradient
                : LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
