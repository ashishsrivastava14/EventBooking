class TicketTier {
  final String name;
  final double price;
  final int totalQuantity;
  final int soldQuantity;

  const TicketTier({
    required this.name,
    required this.price,
    required this.totalQuantity,
    this.soldQuantity = 0,
  });

  int get availableQuantity => totalQuantity - soldQuantity;
}

class TicketModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventImageUrl;
  final String venue;
  final DateTime eventDate;
  final String tierName;
  final List<String> seats;
  final double totalPrice;
  final String bookingRef;
  final TicketStatus status;
  final String qrData;

  const TicketModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.venue,
    required this.eventDate,
    required this.tierName,
    required this.seats,
    required this.totalPrice,
    required this.bookingRef,
    this.status = TicketStatus.confirmed,
    required this.qrData,
  });
}

enum TicketStatus { confirmed, used, cancelled }
