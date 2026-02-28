import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ticket_card.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProv = context.watch<BookingProvider>();

    final userBookings = bookingProv.bookings;

    final upcoming = userBookings
        .where((b) =>
            b.eventDate.isAfter(DateTime.now()) &&
            b.status != BookingStatus.cancelled)
        .toList();
    final past = userBookings
        .where((b) => b.eventDate.isBefore(DateTime.now()))
        .toList();
    final cancelled = userBookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'Past (${past.length})'),
            Tab(text: 'Cancelled (${cancelled.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketList(upcoming, 'No upcoming tickets', isDark),
          _buildTicketList(past, 'No past tickets', isDark),
          _buildTicketList(cancelled, 'No cancelled tickets', isDark),
        ],
      ),
    );
  }

  Widget _buildTicketList(
      List bookings, String emptyMessage, bool isDark) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return TicketCard(
          booking: booking,
          onTap: () => context.push('/ticket/${booking.id}'),
        );
      },
    );
  }
}
