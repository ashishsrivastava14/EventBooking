import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/booking_provider.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloading = false;

  Future<void> _downloadTicket(BuildContext context) async {
    setState(() => _isDownloading = true);
    try {
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image == null) throw Exception('Capture failed');
      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          subject: 'My Ticket',
          files: [
            XFile.fromData(
              image,
              name: 'ticket_${DateTime.now().millisecondsSinceEpoch}.png',
              mimeType: 'image/png',
            )
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _addToCalendar(BuildContext context, bookmark) async {
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!isMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add to Calendar is only supported on Android & iOS.'),
        ),
      );
      return;
    }
    try {
      final event = Event(
        title: bookmark.eventTitle,
        description:
            '${bookmark.tierName} · Seats: ${bookmark.seats.join(', ')}\nRef: ${bookmark.id.toUpperCase()}',
        location: bookmark.venue,
        startDate: bookmark.eventDate,
        endDate: bookmark.eventDate.add(const Duration(hours: 3)),
        iosParams: const IOSParams(reminder: Duration(hours: 1)),
        androidParams: const AndroidParams(emailInvites: []),
      );
      final added = await Add2Calendar.addEvent2Cal(event);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added
              ? '✅ Event added to your calendar!'
              : 'Could not add event — please check calendar permissions.'),
          backgroundColor: added ? AppColors.success : AppColors.error,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calendar error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = context.read<BookingProvider>().lastBooking;

    if (booking == null) {
      return Scaffold(
        body: AppBackground(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No booking found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        )),
      );
    }

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Success animation
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 64,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 300.ms),
                const SizedBox(height: 20),
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Your tickets have been booked successfully',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 30),

                // Booking ID
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Booking ID: ${booking.id.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // ── Screenshottable ticket block ──
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: booking.qrData,
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Ticket summary
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.card
                                : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _infoRow('Event', booking.eventTitle,
                                  isDark: isDark),
                              _infoRow(
                                  'Date',
                                  '${_monthName(booking.eventDate.month)} ${booking.eventDate.day}, ${booking.eventDate.year}',
                                  isDark: isDark),
                              _infoRow('Venue', booking.venue,
                                  isDark: isDark),
                              _infoRow('Tier', booking.tierName,
                                  isDark: isDark),
                              _infoRow('Seats', booking.seats.join(', '),
                                  isDark: isDark),
                              _infoRow('Total',
                                  '\$${booking.total.toStringAsFixed(2)}',
                                  isDark: isDark),
                              _infoRow('Payment', booking.paymentMethod,
                                  isDark: isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).scale(
                    begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'View Ticket',
                        onPressed: () =>
                            context.push('/ticket/${booking.id}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Download',
                        isLoading: _isDownloading,
                        onPressed: () => _downloadTicket(context),
                        isOutlined: true,
                        icon: Icons.download,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Share',
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              subject:
                                  'Booking Confirmed – ${booking.eventTitle}',
                              text:
                                  '🎉 I just booked tickets to ${booking.eventTitle}!\n'
                                  '📅 ${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}\n'
                                  '📍 ${booking.venue}\n'
                                  '💺 ${booking.tierName} · Seats: ${booking.seats.join(', ')}\n'
                                  '🔖 Ref: ${booking.id.toUpperCase()}',
                            ),
                          );
                        },
                        isOutlined: true,
                        icon: Icons.share,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Add to Calendar',
                        onPressed: () => _addToCalendar(context, booking),
                        isOutlined: true,
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
