import 'dart:math';
import 'package:flutter/material.dart';
import 'base_layout.dart';

/// ⚽ Football / Soccer stadium – rectangular pitch, stands all 4 sides.
class FootballLayout extends BaseLayout {
  const FootballLayout({
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
  double get mapHeight => 750;

  @override
  Rect get fieldRect => const Rect.fromLTWH(190, 180, 580, 380);

  @override
  String getOrientationLabel() => 'North–South';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _FootballFieldPainter(),
      size: const Size(580, 380),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('north')) {
      data.add(const ZoneRenderData(
          zoneId: 'north', bounds: Rect.fromLTWH(190, 20, 580, 140)));
    }
    if (zoneIds.contains('south')) {
      data.add(const ZoneRenderData(
          zoneId: 'south', bounds: Rect.fromLTWH(190, 580, 580, 140)));
    }
    if (zoneIds.contains('east')) {
      data.add(const ZoneRenderData(
          zoneId: 'east', bounds: Rect.fromLTWH(790, 180, 150, 380)));
    }
    if (zoneIds.contains('west')) {
      data.add(const ZoneRenderData(
          zoneId: 'west', bounds: Rect.fromLTWH(20, 180, 150, 380)));
    }
    // Corner sections
    if (zoneIds.contains('nw')) {
      data.add(const ZoneRenderData(
          zoneId: 'nw', bounds: Rect.fromLTWH(20, 20, 150, 140)));
    }
    if (zoneIds.contains('ne')) {
      data.add(const ZoneRenderData(
          zoneId: 'ne', bounds: Rect.fromLTWH(790, 20, 150, 140)));
    }
    if (zoneIds.contains('sw')) {
      data.add(const ZoneRenderData(
          zoneId: 'sw', bounds: Rect.fromLTWH(20, 580, 150, 140)));
    }
    if (zoneIds.contains('se')) {
      data.add(const ZoneRenderData(
          zoneId: 'se', bounds: Rect.fromLTWH(790, 580, 150, 140)));
    }
    return data;
  }
}

class _FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Green pitch
    final pitchPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), const Radius.circular(4)),
      pitchPaint,
    );

    // Darker stripes
    final stripePaint = Paint()..color = const Color(0xFF276C2E);
    for (int i = 0; i < 10; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * h / 10, w, h / 10),
        stripePaint,
      );
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer boundary
    canvas.drawRect(
        Rect.fromLTWH(10, 10, w - 20, h - 20), linePaint);

    // Center line
    canvas.drawLine(
        Offset(10, h / 2), Offset(w - 10, h / 2), linePaint);

    // Center circle
    canvas.drawCircle(Offset(w / 2, h / 2), 40, linePaint);

    // Center dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w / 2, h / 2), 3, dotPaint);

    // Penalty boxes (18-yard)
    final penaltyW = 150.0;
    final penaltyH = 70.0;
    // Top
    canvas.drawRect(
      Rect.fromLTWH(
          w / 2 - penaltyW / 2, 10, penaltyW, penaltyH),
      linePaint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTWH(
          w / 2 - penaltyW / 2, h - 10 - penaltyH, penaltyW, penaltyH),
      linePaint,
    );

    // Goal boxes (6-yard)
    final goalBoxW = 70.0;
    final goalBoxH = 30.0;
    canvas.drawRect(
      Rect.fromLTWH(w / 2 - goalBoxW / 2, 10, goalBoxW, goalBoxH),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          w / 2 - goalBoxW / 2, h - 10 - goalBoxH, goalBoxW, goalBoxH),
      linePaint,
    );

    // Penalty spots
    canvas.drawCircle(Offset(w / 2, 10 + penaltyH - 15), 3, dotPaint);
    canvas.drawCircle(Offset(w / 2, h - 10 - penaltyH + 15), 3, dotPaint);

    // Penalty arcs
    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w / 2, 10 + penaltyH - 15),
          width: 60,
          height: 40),
      0,
      pi,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w / 2, h - 10 - penaltyH + 15),
          width: 60,
          height: 40),
      pi,
      pi,
      false,
      arcPaint,
    );

    // Corner arcs
    final cornerR = 12.0;
    canvas.drawArc(
        Rect.fromLTWH(10 - cornerR, 10 - cornerR, cornerR * 2, cornerR * 2),
        0, pi / 2, false, linePaint);
    canvas.drawArc(
        Rect.fromLTWH(
            w - 10 - cornerR, 10 - cornerR, cornerR * 2, cornerR * 2),
        pi / 2, pi / 2, false, linePaint);
    canvas.drawArc(
        Rect.fromLTWH(
            10 - cornerR, h - 10 - cornerR, cornerR * 2, cornerR * 2),
        -pi / 2, pi / 2, false, linePaint);
    canvas.drawArc(
        Rect.fromLTWH(w - 10 - cornerR, h - 10 - cornerR, cornerR * 2,
            cornerR * 2),
        pi, pi / 2, false, linePaint);

    // Goals
    final goalPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
        Rect.fromLTWH(w / 2 - 15, 2, 30, 10), goalPaint);
    canvas.drawRect(
        Rect.fromLTWH(w / 2 - 15, h - 12, 30, 10), goalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
