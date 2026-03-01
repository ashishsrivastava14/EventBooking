import 'seating_zone.dart';

class SeatMapConfig {
  final String layoutType;
  final List<SeatingZone> zones;
  final int totalCapacity;
  final bool hasFloorSeating;
  final bool isGeneralAdmission;
  final String courtSurface;
  final String fieldOrientation;

  const SeatMapConfig({
    required this.layoutType,
    required this.zones,
    required this.totalCapacity,
    this.hasFloorSeating = false,
    this.isGeneralAdmission = false,
    this.courtSurface = '',
    this.fieldOrientation = 'north-south',
  });
}
