import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final String bookingId;
  const TicketDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = context.read<BookingProvider>().getBookingById(bookingId);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppBackground(child: const Center(child: Text('Ticket not found'))),
      );
    }

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  subject: 'My Ticket – ${booking.eventTitle}',
                  text:
                      '🎟️ ${booking.eventTitle}\n'
                      '📅 ${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}\n'
                      '📍 ${booking.venue}\n'
                      '💺 ${booking.tierName} · Seats: ${booking.seats.join(', ')}\n'
                      '🔖 Ref: ${booking.id.toUpperCase()}',
                ),
              );
            },
          ),
        ],
      ),
      body: AppBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ticket stub design
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Top part - Event image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AppImage(
                      imageUrl: booking.eventImageUrl,
                      height: 150,
                      width: double.infinity,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.eventTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _detailRow(Icons.calendar_today, 'Date',
                            _formatDate(booking.eventDate)),
                        _detailRow(
                            Icons.location_on, 'Venue', booking.venue),
                        _detailRow(Icons.confirmation_number, 'Tier',
                            booking.tierName),
                        _detailRow(Icons.event_seat, 'Seats',
                            booking.seats.join(', ')),
                        _detailRow(Icons.receipt, 'Booking Ref',
                            booking.id.toUpperCase()),
                        _detailRow(Icons.payment, 'Total',
                            '\$${booking.total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),

                  // Dashed divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(
                        40,
                        (index) => Expanded(
                          child: Container(
                            height: 1.5,
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

                  // QR Code section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: booking.qrData,
                            version: QrVersions.auto,
                            size: 160,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Barcode placeholder
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              40,
                              (i) => Container(
                                width: i % 3 == 0 ? 3 : 1.5,
                                height: 50,
                                margin: const EdgeInsets.only(right: 2),
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.qrData,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(booking.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText(booking.status),
                      style: TextStyle(
                        color: _statusColor(booking.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CustomButton(
              text: 'Transfer Ticket',
              onPressed: () => _showTransferDialog(context, booking),
              isOutlined: true,
              icon: Icons.send,
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context, BookingModel booking) {
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.checkedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            booking.status == BookingStatus.checkedIn
                ? 'Cannot transfer a checked-in ticket.'
                : 'Cannot transfer a cancelled ticket.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark =
            Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.card : AppColors.cardLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Transfer Ticket',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the recipient\'s email address. Ownership of "${booking.eventTitle}" will be transferred to them.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'someone@example.com',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter an email address.';
                    }
                    final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Transfer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final bookingProv =
                    context.read<BookingProvider>();
                final success = bookingProv.transferBooking(
                    booking.id, emailController.text);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '✅ Ticket transferred to ${emailController.text.trim()}!'
                          : 'Transfer failed. Please try again.',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.checkedIn:
        return AppColors.primary;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.completed:
        return AppColors.textSecondaryDark;
    }
  }

  String _statusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
