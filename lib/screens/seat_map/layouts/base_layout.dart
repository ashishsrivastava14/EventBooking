import 'package:flutter/material.dart';
import '../../../models/seating_zone.dart';
import '../../../models/venue_model.dart';

/// Describes where a zone should be rendered on the map.
class ZoneRenderData {
  final String zoneId;
  final Rect bounds;
  final double rotation;

  const ZoneRenderData({
    required this.zoneId,
    required this.bounds,
    this.rotation = 0,
  });
}

/// Abstract base class for all venue layouts.
/// Concrete layouts implement [buildFieldOrStage], [getZoneRenderData], etc.
/// The base class handles rendering zones (overview blocks vs seat grids)
/// and individual seat selection.
abstract class BaseLayout extends StatelessWidget {
  final VenueModel venue;
  final List<SeatingZone> zones;
  final Set<String> selectedSeats;
  final Set<String> takenSeats;
  final void Function(String seatId, String zoneName, double price) onSeatTapped;
  final void Function(String zoneId) onZoneTapped;
  final String? activeZoneId;

  const BaseLayout({
    super.key,
    required this.venue,
    required this.zones,
    required this.selectedSeats,
    required this.takenSeats,
    required this.onSeatTapped,
    required this.onZoneTapped,
    this.activeZoneId,
  });

  double get mapWidth;
  double get mapHeight;
  Rect get fieldRect;
  Widget buildFieldOrStage(BuildContext context);
  List<ZoneRenderData> getZoneRenderData();
  String getOrientationLabel();

  @override
  Widget build(BuildContext context) {
    final zoneRenderData = getZoneRenderData();
    return SizedBox(
      width: mapWidth,
      height: mapHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Center field / court / stage
          Positioned(
            left: fieldRect.left,
            top: fieldRect.top,
            width: fieldRect.width,
            height: fieldRect.height,
            child: buildFieldOrStage(context),
          ),
          // All zone widgets (blocks or seat grids)
          for (final zrd in zoneRenderData) _buildZoneWidget(context, zrd),
        ],
      ),
    );
  }

  Widget _buildZoneWidget(BuildContext context, ZoneRenderData zrd) {
    final zone = zones.firstWhere(
      (z) => z.zoneId == zrd.zoneId,
      orElse: () => zones.first,
    );
    final isActive = activeZoneId == zrd.zoneId;
    final isOverview = activeZoneId == null;

    if (isOverview || !isActive) {
      return Positioned(
        left: zrd.bounds.left,
        top: zrd.bounds.top,
        width: zrd.bounds.width,
        height: zrd.bounds.height,
        child: buildZoneBlock(zone, isDimmed: !isOverview),
      );
    }

    return Positioned(
      left: zrd.bounds.left,
      top: zrd.bounds.top,
      width: zrd.bounds.width,
      height: zrd.bounds.height,
      child: buildSeatGrid(zone),
    );
  }

  /// Zone overview block – colored rectangle with name, price, availability.
  Widget buildZoneBlock(SeatingZone zone, {bool isDimmed = false}) {
    final alpha = isDimmed ? 0.08 : 0.18;
    final borderAlpha = isDimmed ? 0.15 : 0.6;
    final textAlpha = isDimmed ? 0.4 : 1.0;

    return GestureDetector(
      onTap: isDimmed ? null : () => onZoneTapped(zone.zoneId),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: zone.color.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: zone.color.withValues(alpha: borderAlpha),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                zone.zoneName,
                style: TextStyle(
                  color: zone.color.withValues(alpha: textAlpha),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${zone.priceAmount.toStringAsFixed(0)}',
              style: TextStyle(
                color: zone.color.withValues(alpha: textAlpha * 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${zone.availabilityPercent.toStringAsFixed(0)}% left',
              style: TextStyle(
                color: zone.color.withValues(alpha: textAlpha * 0.6),
                fontSize: 9,
              ),
            ),
            if (zone.isVIP)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  zone.priceTier,
                  style: TextStyle(
                    color: const Color(0xFFFFD700).withValues(alpha: textAlpha),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Seat grid – shows individual seats for a zone.
  Widget buildSeatGrid(SeatingZone zone) {
    final seatSize = 22.0;
    final seatMargin = 1.5;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: zone.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${zone.zoneName}  •  \$${zone.priceAmount.toStringAsFixed(0)}',
              style: TextStyle(
                color: zone.color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            for (int row = 0; row < zone.rows; row++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    child: Text(
                      String.fromCharCode(65 + row),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: zone.color.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  for (int col = 0; col < zone.seatsPerRow; col++)
                    _buildSeat(zone, row, col, seatSize, seatMargin),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeat(
    SeatingZone zone,
    int row,
    int col,
    double size,
    double margin,
  ) {
    final seatId =
        '${zone.zoneId}-${String.fromCharCode(65 + row)}${col + 1}';
    final isTaken = takenSeats.contains(seatId);
    final isSelected = selectedSeats.contains(seatId);

    Color color;
    if (isTaken) {
      color = const Color(0xFF3A3F4E);
    } else if (isSelected) {
      color = const Color(0xFFFF6B00);
    } else if (zone.isVIP) {
      color = const Color(0xFFFFD700);
    } else if (zone.isAccessible) {
      color = const Color(0xFF00C48C);
    } else {
      color = const Color(0xFF026CDF);
    }

    return GestureDetector(
      onTap: isTaken
          ? null
          : () => onSeatTapped(seatId, zone.zoneName, zone.priceAmount),
      onLongPress: isTaken
          ? null
          : () {},
      child: Tooltip(
        message:
            'Row ${String.fromCharCode(65 + row)}, Seat ${col + 1} — \$${zone.priceAmount.toStringAsFixed(0)}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            color: isTaken
                ? color.withValues(alpha: 0.25)
                : isSelected
                    ? color
                    : color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: zone.isAccessible && !isTaken && !isSelected
                ? Icon(Icons.accessible, size: 10, color: color)
                : Text(
                    '${col + 1}',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : isTaken
                              ? color.withValues(alpha: 0.4)
                              : color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Generate deterministic taken seat IDs based on zone's availability.
  static Set<String> generateTakenSeats(List<SeatingZone> zones) {
    final taken = <String>{};
    for (final zone in zones) {
      final totalSeats = zone.rows * zone.seatsPerRow;
      final takenCount =
          (totalSeats - zone.availableSeats).clamp(0, totalSeats);
      int count = 0;
      for (int row = 0; row < zone.rows && count < takenCount; row++) {
        for (int col = 0;
            col < zone.seatsPerRow && count < takenCount;
            col++) {
          if ((row * 7 + col * 13 + zone.zoneId.hashCode) % 5 < 2) {
            taken.add(
                '${zone.zoneId}-${String.fromCharCode(65 + row)}${col + 1}');
            count++;
          }
        }
      }
      // If the hash-based pattern didn't generate enough, fill remaining
      if (count < takenCount) {
        for (int row = 0; row < zone.rows && count < takenCount; row++) {
          for (int col = 0;
              col < zone.seatsPerRow && count < takenCount;
              col++) {
            final id =
                '${zone.zoneId}-${String.fromCharCode(65 + row)}${col + 1}';
            if (!taken.contains(id)) {
              taken.add(id);
              count++;
            }
          }
        }
      }
    }
    return taken;
  }
}
