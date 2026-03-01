import 'dart:math';
import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🏀 Basketball arena – hardwood court, tiered seating.
class BasketballLayout extends BaseLayout {
  const BasketballLayout({
    super.key,
    required super.venue,
    required super.zones,
    required super.selectedSeats,
    required super.takenSeats,
    required super.onSeatTapped,
    required super.onZoneTapped,
    super.activeZoneId,
  });

  @override
  double get mapWidth => 960;
  @override
  double get mapHeight => 720;

  @override
  Rect get fieldRect => const Rect.fromLTWH(230, 200, 500, 300);

  @override
  String getOrientationLabel() => 'Baseline–Baseline';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _BasketballCourtPainter(),
      size: const Size(500, 300),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('courtside')) {
      data.add(const ZoneRenderData(
          zoneId: 'courtside', bounds: Rect.fromLTWH(230, 510, 500, 80)));
    }
    if (zoneIds.contains('lower_east')) {
      data.add(const ZoneRenderData(
          zoneId: 'lower_east', bounds: Rect.fromLTWH(750, 200, 190, 300)));
    }
    if (zoneIds.contains('lower_west')) {
      data.add(const ZoneRenderData(
          zoneId: 'lower_west', bounds: Rect.fromLTWH(20, 200, 190, 300)));
    }
    if (zoneIds.contains('lower_north')) {
      data.add(const ZoneRenderData(
          zoneId: 'lower_north', bounds: Rect.fromLTWH(230, 100, 500, 80)));
    }
    if (zoneIds.contains('upper_north')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_north', bounds: Rect.fromLTWH(230, 10, 500, 80)));
    }
    if (zoneIds.contains('upper_south')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_south', bounds: Rect.fromLTWH(230, 600, 500, 110)));
    }
    // corner/upper side sections
    if (zoneIds.contains('upper_west')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_west', bounds: Rect.fromLTWH(20, 10, 190, 180)));
    }
    if (zoneIds.contains('upper_east')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_east', bounds: Rect.fromLTWH(750, 10, 190, 180)));
    }
    return data;
  }
}

class _BasketballCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hardwood floor
    final floorPaint = Paint()..color = const Color(0xFFC68642);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), const Radius.circular(2)),
      floorPaint,
    );

    // Floor planks
    final plankPaint = Paint()
      ..color = const Color(0xFFB87530)
      ..strokeWidth = 0.5;
    for (double x = 0; x < w; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), plankPaint);
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer boundary
    canvas.drawRect(Rect.fromLTWH(5, 5, w - 10, h - 10), linePaint);

    // Center line
    canvas.drawLine(
        Offset(w / 2, 5), Offset(w / 2, h - 5), linePaint);

    // Center circle
    canvas.drawCircle(Offset(w / 2, h / 2), 30, linePaint);

    // Center dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w / 2, h / 2), 3, dotPaint);

    // 3-point arcs (left and right)
    final threePointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left 3-point arc
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(5, h / 2), width: 180, height: 220),
      -pi / 2,
      pi,
      false,
      threePointPaint,
    );
    // Left 3-point sideline extensions
    canvas.drawLine(Offset(5, h / 2 - 110), Offset(5, 5), threePointPaint);
    canvas.drawLine(Offset(5, h / 2 + 110), Offset(5, h - 5), threePointPaint);

    // Right 3-point arc
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w - 5, h / 2), width: 180, height: 220),
      pi / 2,
      pi,
      false,
      threePointPaint,
    );

    // Paint/key area (left)
    final keyW = 70.0;
    final keyH = 120.0;
    canvas.drawRect(
        Rect.fromLTWH(5, h / 2 - keyH / 2, keyW, keyH), linePaint);

    // Paint/key area (right)
    canvas.drawRect(
        Rect.fromLTWH(w - 5 - keyW, h / 2 - keyH / 2, keyW, keyH),
        linePaint);

    // Free throw circles
    canvas.drawCircle(Offset(5 + keyW, h / 2), 25, linePaint);
    canvas.drawCircle(Offset(w - 5 - keyW, h / 2), 25, linePaint);

    // Backboards and baskets
    final backboardPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(15, h / 2 - 12), Offset(15, h / 2 + 12), backboardPaint);
    canvas.drawLine(Offset(w - 15, h / 2 - 12),
        Offset(w - 15, h / 2 + 12), backboardPaint);

    // Basket circles
    final basketPaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(22, h / 2), 6, basketPaint);
    canvas.drawCircle(Offset(w - 22, h / 2), 6, basketPaint);

    // Restricted areas (small arcs under baskets)
    final restrictedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(15, h / 2), width: 30, height: 30),
      -pi / 2,
      pi,
      false,
      restrictedPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w - 15, h / 2), width: 30, height: 30),
      pi / 2,
      pi,
      false,
      restrictedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
