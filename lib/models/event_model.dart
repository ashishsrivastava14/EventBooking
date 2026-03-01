import 'ticket_model.dart';
import 'seat_map_config.dart';

class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final DateTime date;
  final String time;
  final String venueId;
  final String venueName;
  final String city;
  final List<String> artists;
  final String description;
  final List<TicketTier> ticketTiers;
  final bool isFeatured;
  final bool isTrending;
  final double rating;
  final int reviewCount;
  String status; // Active, Cancelled, Draft
  final String? eventCategory; // "cricket", "football", "concert", etc.
  final String? venueType; // "stadium", "arena", "theatre", "club"
  final SeatMapConfig? seatMapConfig;

  EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.time,
    required this.venueId,
    required this.venueName,
    required this.city,
    required this.artists,
    required this.description,
    required this.ticketTiers,
    this.isFeatured = false,
    this.isTrending = false,
    this.rating = 4.5,
    this.reviewCount = 120,
    this.status = 'Active',
    this.eventCategory,
    this.venueType,
    this.seatMapConfig,
  });

  /// Returns the specific event category for seat map layout.
  /// Falls back to deriving from the generic [category] field.
  String get effectiveEventCategory {
    if (eventCategory != null) return eventCategory!;
    switch (category.toLowerCase()) {
      case 'concerts':
        return 'concert';
      case 'theatre':
        return 'theatre';
      case 'comedy':
        return 'comedy';
      default:
        return 'concert';
    }
  }

  double get minPrice {
    if (ticketTiers.isEmpty) return 0;
    return ticketTiers.map((t) => t.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (ticketTiers.isEmpty) return 0;
    return ticketTiers.map((t) => t.price).reduce((a, b) => a > b ? a : b);
  }

  int get totalTicketsSold =>
      ticketTiers.fold(0, (sum, t) => sum + t.soldQuantity);
}
