import '../../models/venue_model.dart';
import 'layouts/base_layout.dart';
import 'layouts/cricket_layout.dart';
import 'layouts/football_layout.dart';
import 'layouts/tennis_layout.dart';
import 'layouts/basketball_layout.dart';
import 'layouts/baseball_layout.dart';
import 'layouts/hockey_layout.dart';
import 'layouts/boxing_layout.dart';
import 'layouts/concert_layout.dart';
import 'layouts/theatre_layout.dart';
import 'layouts/comedy_layout.dart';
import 'layouts/esports_layout.dart';
import 'layouts/formula1_layout.dart';
import '../../models/seating_zone.dart';
import 'package:flutter/material.dart';

typedef LayoutBuilder = BaseLayout Function({
  Key? key,
  required VenueModel venue,
  required List<SeatingZone> zones,
  required Set<String> selectedSeats,
  required Set<String> takenSeats,
  required void Function(String, String, double) onSeatTapped,
  required void Function(String) onZoneTapped,
  String? activeZoneId,
});

class SeatMapController {
  /// Returns the correct layout builder function for the given event category.
  static LayoutBuilder resolveLayoutBuilder(String eventCategory) {
    switch (eventCategory.toLowerCase()) {
      case 'cricket':
        return _buildCricket;
      case 'football':
      case 'soccer':
        return _buildFootball;
      case 'tennis':
        return _buildTennis;
      case 'basketball':
        return _buildBasketball;
      case 'baseball':
        return _buildBaseball;
      case 'hockey':
        return _buildHockey;
      case 'boxing':
      case 'mma':
        return _buildBoxing;
      case 'concert':
      case 'music':
        return _buildConcert;
      case 'theatre':
      case 'drama':
        return _buildTheatre;
      case 'comedy':
        return _buildComedy;
      case 'esports':
        return _buildEsports;
      case 'formula1':
      case 'motorsport':
        return _buildFormula1;
      default:
        return _buildConcert;
    }
  }

  /// Convenience: directly resolve a layout widget.
  static BaseLayout resolveLayout({
    required String eventCategory,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) {
    final builder = resolveLayoutBuilder(eventCategory);
    return builder(
      venue: venue,
      zones: zones,
      selectedSeats: selectedSeats,
      takenSeats: takenSeats,
      onSeatTapped: onSeatTapped,
      onZoneTapped: onZoneTapped,
      activeZoneId: activeZoneId,
    );
  }

  // ── Builder functions ─────────────────────────────────────

  static BaseLayout _buildCricket({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      CricketLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildFootball({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      FootballLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildTennis({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      TennisLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildBasketball({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      BasketballLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildBaseball({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      BaseballLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildHockey({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      HockeyLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildBoxing({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      BoxingLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildConcert({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      ConcertLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildTheatre({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      TheatreLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildComedy({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      ComedyLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildEsports({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      EsportsLayout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );

  static BaseLayout _buildFormula1({
    Key? key,
    required VenueModel venue,
    required List<SeatingZone> zones,
    required Set<String> selectedSeats,
    required Set<String> takenSeats,
    required void Function(String, String, double) onSeatTapped,
    required void Function(String) onZoneTapped,
    String? activeZoneId,
  }) =>
      Formula1Layout(
        key: key,
        venue: venue,
        zones: zones,
        selectedSeats: selectedSeats,
        takenSeats: takenSeats,
        onSeatTapped: onSeatTapped,
        onZoneTapped: onZoneTapped,
        activeZoneId: activeZoneId,
      );
}
