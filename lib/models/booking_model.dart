enum BookingStatus { confirmed, checkedIn, cancelled, completed }

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String eventId;
  final String eventTitle;
  final String eventImageUrl;
  final String venue;
  final DateTime eventDate;
  final String tierName;
  final List<String> seats;
  final double subtotal;
  final double serviceFee;
  final double discount;
  final double total;
  final String promoCode;
  final String paymentMethod;
  final DateTime bookingDate;
  BookingStatus status;
  final String qrData;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.eventId,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.venue,
    required this.eventDate,
    required this.tierName,
    required this.seats,
    required this.subtotal,
    required this.serviceFee,
    this.discount = 0,
    required this.total,
    this.promoCode = '',
    required this.paymentMethod,
    required this.bookingDate,
    this.status = BookingStatus.confirmed,
    required this.qrData,
  });

  BookingModel copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    BookingStatus? status,
  }) {
    return BookingModel(
      id: id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
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
      bookingDate: bookingDate,
      status: status ?? this.status,
      qrData: qrData,
    );
  }
}
