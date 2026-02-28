import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String _statusFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProv = context.watch<BookingProvider>();

    var bookings = bookingProv.bookings;
    if (_statusFilter != 'All') {
      bookings = bookings.where((b) {
        switch (_statusFilter) {
          case 'Confirmed':
            return b.status == BookingStatus.confirmed;
          case 'Checked In':
            return b.status == BookingStatus.checkedIn;
          case 'Cancelled':
            return b.status == BookingStatus.cancelled;
          case 'Completed':
            return b.status == BookingStatus.completed;
          default:
            return true;
        }
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      bookings = bookings
          .where((b) =>
              b.eventTitle
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              b.userName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV exported! (Mock)'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export CSV'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by event or user...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _statusFilter,
                  underline: const SizedBox(),
                  items: ['All', 'Confirmed', 'Checked In', 'Cancelled', 'Completed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _statusFilter = v!),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${bookings.length} bookings found',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: bookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return _bookingTile(b, isDark, bookingProv);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bookingTile(
      BookingModel b, bool isDark, BookingProvider bookingProv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _statusColor(b.status).withOpacity(0.15),
          child: Icon(_statusIcon(b.status),
              color: _statusColor(b.status), size: 18),
        ),
        title: Text(b.eventTitle,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${b.userName} • \$${b.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _statusColor(b.status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _statusText(b.status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor(b.status),
            ),
          ),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Booking ID', b.id.toUpperCase()),
                _detailRow('Email', b.userEmail),
                _detailRow('Tier', b.tierName),
                _detailRow('Seats', b.seats.join(', ')),
                _detailRow('Subtotal', '\$${b.subtotal.toStringAsFixed(2)}'),
                _detailRow('Service Fee',
                    '\$${b.serviceFee.toStringAsFixed(2)}'),
                if (b.discount > 0)
                  _detailRow('Discount',
                      '-\$${b.discount.toStringAsFixed(2)}'),
                _detailRow('Total', '\$${b.total.toStringAsFixed(2)}'),
                _detailRow('Payment', b.paymentMethod),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (b.status == BookingStatus.confirmed)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => bookingProv.checkInBooking(b.id),
                          icon: const Icon(Icons.qr_code_scanner, size: 16),
                          label: const Text('Check In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    if (b.status == BookingStatus.confirmed) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => bookingProv.cancelBooking(b.id),
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondaryDark)),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
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

  IconData _statusIcon(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return Icons.check;
      case BookingStatus.checkedIn:
        return Icons.qr_code;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.completed:
        return Icons.done_all;
    }
  }

  String _statusText(BookingStatus s) {
    switch (s) {
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
}
