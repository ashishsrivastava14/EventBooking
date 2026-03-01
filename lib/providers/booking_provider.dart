import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../core/constants/mock_data.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  BookingModel? _lastBooking;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get lastBooking => _lastBooking;

  BookingProvider() {
    _bookings = List.from(MockData.bookings);
  }

  List<BookingModel> getUserBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  List<BookingModel> get upcomingBookings {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.eventDate.isAfter(now) && b.status == BookingStatus.confirmed)
        .toList();
  }

  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return _bookings
        .where((b) =>
            b.eventDate.isBefore(now) || b.status == BookingStatus.completed)
        .toList();
  }

  List<BookingModel> get cancelledBookings {
    return _bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();
  }

  BookingModel createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String eventId,
    required String eventTitle,
    required String eventImageUrl,
    required String venue,
    required DateTime eventDate,
    required String tierName,
    required List<String> seats,
    required double subtotal,
    required double serviceFee,
    required double discount,
    required double total,
    required String promoCode,
    required String paymentMethod,
  }) {
    final bookingId = 'b${_bookings.length + 1}';
    final qrData = 'EVT-$bookingId-${eventId.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

    final booking = BookingModel(
      id: bookingId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      eventId: eventId,
      eventTitle: eventTitle,
      eventImageUrl: eventImageUrl,
      venue: venue,
      eventDate: eventDate,
      tierName: tierName,
      seats: seats,
      subtotal: subtotal,
      serviceFee: serviceFee,
      discount: discount,
      total: total,
      promoCode: promoCode,
      paymentMethod: paymentMethod,
      bookingDate: DateTime.now(),
      status: BookingStatus.confirmed,
      qrData: qrData,
    );

    _bookings.add(booking);
    _lastBooking = booking;
    notifyListeners();
    return booking;
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index].status = BookingStatus.cancelled;
      notifyListeners();
    }
  }

  /// Transfers a booking to a new email address.
  /// Returns true on success, false if the booking was not found or
  /// cannot be transferred (e.g. already cancelled / checked-in).
  bool transferBooking(String bookingId, String recipientEmail) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;
    final booking = _bookings[index];
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.checkedIn) return false;
    _bookings[index] = booking.copyWith(
      userEmail: recipientEmail.trim().toLowerCase(),
      userName: recipientEmail.trim().toLowerCase(),
    );
    notifyListeners();
    return true;
  }

  void checkInBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index].status = BookingStatus.checkedIn;
      notifyListeners();
    }
  }

  BookingModel? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  // Admin: revenue today (mock)
  double get revenueToday => _bookings
      .where((b) =>
          b.bookingDate.day == DateTime.now().day &&
          b.status != BookingStatus.cancelled)
      .fold(0.0, (sum, b) => sum + b.total);

  // Admin: total revenue
  double get totalRevenue => _bookings
      .where((b) => b.status != BookingStatus.cancelled)
      .fold(0.0, (sum, b) => sum + b.total);

  // Admin: bookings by category
  Map<String, double> getRevenueByCategory(List<dynamic> events) {
    final map = <String, double>{};
    for (final b in _bookings.where((b) => b.status != BookingStatus.cancelled)) {
      final event = events.cast<dynamic>().firstWhere(
        (e) => e.id == b.eventId,
        orElse: () => null,
      );
      if (event != null) {
        final cat = event.category as String;
        map[cat] = (map[cat] ?? 0) + b.total;
      }
    }
    return map;
  }
}
