import 'dart:math';
import 'package:flutter/material.dart';
import 'base_layout.dart';

/// ⚾ Baseball stadium – diamond infield, fan-shaped outfield.
class BaseballLayout extends BaseLayout {
  const BaseballLayout({
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
  double get mapWidth => 900;
  @override
  double get mapHeight => 900;

  @override
  Rect get fieldRect => const Rect.fromLTWH(150, 150, 600, 600);

  @override
  String getOrientationLabel() => 'Home Plate South';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _BaseballFieldPainter(),
      size: const Size(600, 600),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('home_plate')) {
      data.add(const ZoneRenderData(
          zoneId: 'home_plate', bounds: Rect.fromLTWH(300, 770, 300, 120)));
    }
    if (zoneIds.contains('first_base')) {
      data.add(const ZoneRenderData(
          zoneId: 'first_base', bounds: Rect.fromLTWH(640, 520, 250, 180)));
    }
    if (zoneIds.contains('third_base')) {
      data.add(const ZoneRenderData(
          zoneId: 'third_base', bounds: Rect.fromLTWH(10, 520, 250, 180)));
    }
    if (zoneIds.contains('lf_bleachers')) {
      data.add(const ZoneRenderData(
          zoneId: 'lf_bleachers', bounds: Rect.fromLTWH(10, 100, 230, 400)));
    }
    if (zoneIds.contains('rf_bleachers')) {
      data.add(const ZoneRenderData(
          zoneId: 'rf_bleachers', bounds: Rect.fromLTWH(660, 100, 230, 400)));
    }
    if (zoneIds.contains('upper_deck')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_deck', bounds: Rect.fromLTWH(260, 10, 380, 120)));
    }
    return data;
  }
}

class _BaseballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final homeY = h - 40;

    // Outfield grass
    final outfieldPaint = Paint()..color = const Color(0xFF2E7D32);
    final outfieldPath = Path()
      ..moveTo(cx, homeY)
      ..lineTo(40, homeY - 380)
      ..arcToPoint(
        Offset(w - 40, homeY - 380),
        radius: const Radius.circular(320),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(outfieldPath, outfieldPaint);

    // Warning track
    final warnPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, homeY), width: 640, height: 640),
      -pi * 0.82,
      pi * 0.64,
      false,
      warnPaint,
    );

    // Infield dirt
    final dirtPaint = Paint()..color = const Color(0xFFD2B48C);
    final infieldSize = 140.0;
    canvas.drawCircle(
        Offset(cx, homeY - infieldSize * 1.1), infieldSize * 0.9, dirtPaint);

    // Infield grass
    final infieldGrass = Paint()..color = const Color(0xFF388E3C);
    canvas.drawCircle(
        Offset(cx, homeY - infieldSize * 1.1), infieldSize * 0.55, infieldGrass);

    // Diamond (baselines)
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final homePlate = Offset(cx, homeY);
    final firstBase = Offset(cx + infieldSize, homeY - infieldSize);
    final secondBase = Offset(cx, homeY - infieldSize * 2);
    final thirdBase = Offset(cx - infieldSize, homeY - infieldSize);

    canvas.drawLine(homePlate, firstBase, linePaint);
    canvas.drawLine(firstBase, secondBase, linePaint);
    canvas.drawLine(secondBase, thirdBase, linePaint);
    canvas.drawLine(thirdBase, homePlate, linePaint);

    // Bases (white squares)
    final basePaint = Paint()..color = Colors.white;
    for (final base in [firstBase, secondBase, thirdBase]) {
      canvas.drawRect(
        Rect.fromCenter(center: base, width: 10, height: 10),
        basePaint,
      );
    }

    // Home plate (pentagon)
    final hpPath = Path()
      ..moveTo(cx, homeY)
      ..lineTo(cx - 7, homeY - 7)
      ..lineTo(cx - 7, homeY - 14)
      ..lineTo(cx + 7, homeY - 14)
      ..lineTo(cx + 7, homeY - 7)
      ..close();
    canvas.drawPath(hpPath, basePaint);

    // Pitcher's mound
    final moundPaint = Paint()..color = const Color(0xFFC4A77D);
    canvas.drawCircle(
        Offset(cx, homeY - infieldSize), 12, moundPaint);
    // Rubber
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, homeY - infieldSize), width: 8, height: 2),
      basePaint,
    );

    // Foul lines extending outward
    final foulPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(homePlate, Offset(40, homeY - 400), foulPaint);
    canvas.drawLine(homePlate, Offset(w - 40, homeY - 400), foulPaint);

    // Foul poles
    final polePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(40, homeY - 395), Offset(40, homeY - 410), polePaint);
    canvas.drawLine(
        Offset(w - 40, homeY - 395), Offset(w - 40, homeY - 410), polePaint);

    // Batter's box lines
    canvas.drawRect(
      Rect.fromLTWH(cx - 20, homeY - 24, 14, 28),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + 6, homeY - 24, 14, 28),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
