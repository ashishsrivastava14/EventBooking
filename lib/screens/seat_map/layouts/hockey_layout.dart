import 'dart:math';
import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🏒 Ice hockey rink – rounded-corner rink with markings.
class HockeyLayout extends BaseLayout {
  const HockeyLayout({
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
  double get mapHeight => 680;

  @override
  Rect get fieldRect => const Rect.fromLTWH(190, 170, 580, 320);

  @override
  String getOrientationLabel() => 'Goal–Goal';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _HockeyRinkPainter(),
      size: const Size(580, 320),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('north')) {
      data.add(const ZoneRenderData(
          zoneId: 'north', bounds: Rect.fromLTWH(190, 20, 580, 130)));
    }
    if (zoneIds.contains('south')) {
      data.add(const ZoneRenderData(
          zoneId: 'south', bounds: Rect.fromLTWH(190, 510, 580, 150)));
    }
    if (zoneIds.contains('east')) {
      data.add(const ZoneRenderData(
          zoneId: 'east', bounds: Rect.fromLTWH(790, 170, 150, 320)));
    }
    if (zoneIds.contains('west')) {
      data.add(const ZoneRenderData(
          zoneId: 'west', bounds: Rect.fromLTWH(20, 170, 150, 320)));
    }
    if (zoneIds.contains('club_north')) {
      data.add(const ZoneRenderData(
          zoneId: 'club_north', bounds: Rect.fromLTWH(20, 20, 150, 130)));
    }
    if (zoneIds.contains('club_south')) {
      data.add(const ZoneRenderData(
          zoneId: 'club_south', bounds: Rect.fromLTWH(790, 510, 150, 150)));
    }
    return data;
  }
}

class _HockeyRinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cornerR = 60.0;

    // White ice surface
    final icePaint = Paint()..color = const Color(0xFFE8EAF6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), Radius.circular(cornerR)),
      icePaint,
    );

    // Rink boards
    final boardPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, w - 4, h - 4), Radius.circular(cornerR)),
      boardPaint,
    );

    final linePaint = Paint()..strokeWidth = 3;

    // Red center line
    linePaint.color = const Color(0xFFD32F2F);
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), linePaint);

    // Blue lines
    linePaint.color = const Color(0xFF1565C0);
    canvas.drawLine(Offset(w * 0.33, 0), Offset(w * 0.33, h), linePaint);
    canvas.drawLine(Offset(w * 0.67, 0), Offset(w * 0.67, h), linePaint);

    // Red goal lines
    linePaint.color = const Color(0xFFD32F2F);
    linePaint.strokeWidth = 2;
    canvas.drawLine(Offset(40, 0), Offset(40, h), linePaint);
    canvas.drawLine(Offset(w - 40, 0), Offset(w - 40, h), linePaint);

    // Center ice circle
    final circlePaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w / 2, h / 2), 30, circlePaint);

    // Center dot
    final dotPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawCircle(Offset(w / 2, h / 2), 4, dotPaint);

    // Face-off circles (4 in zones)
    final foCirclePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final foPositions = [
      Offset(w * 0.2, h * 0.3),
      Offset(w * 0.2, h * 0.7),
      Offset(w * 0.8, h * 0.3),
      Offset(w * 0.8, h * 0.7),
    ];
    for (final pos in foPositions) {
      canvas.drawCircle(pos, 24, foCirclePaint);
      canvas.drawCircle(pos, 3, Paint()..color = const Color(0xFFD32F2F));
    }

    // Neutral zone face-off dots
    final nzDots = [
      Offset(w * 0.33, h * 0.3),
      Offset(w * 0.33, h * 0.7),
      Offset(w * 0.67, h * 0.3),
      Offset(w * 0.67, h * 0.7),
    ];
    for (final pos in nzDots) {
      canvas.drawCircle(pos, 3, dotPaint);
    }

    // Goal creases (blue D-shapes)
    final creasePaint = Paint()
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.4);
    // Left goal crease
    canvas.drawArc(
      Rect.fromCenter(center: Offset(25, h / 2), width: 40, height: 50),
      -pi / 2,
      pi,
      true,
      creasePaint,
    );
    // Right goal crease
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w - 25, h / 2), width: 40, height: 50),
      pi / 2,
      pi,
      true,
      creasePaint,
    );

    // Goals (red rectangles)
    final goalPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
        Rect.fromLTWH(5, h / 2 - 12, 18, 24), goalPaint);
    canvas.drawRect(
        Rect.fromLTWH(w - 23, h / 2 - 12, 18, 24), goalPaint);

    // Center logo placeholder
    final logoPaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.15);
    canvas.drawCircle(Offset(w / 2, h / 2), 20, logoPaint);

    // "PENALTY BOX" and "BENCH" labels
    final benchTP = TextPainter(
      text: const TextSpan(
        text: 'BENCH',
        style: TextStyle(color: Color(0xFF78909C), fontSize: 7),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    benchTP.paint(canvas, Offset(w / 2 - 40, 6));

    final penTP = TextPainter(
      text: const TextSpan(
        text: 'PENALTY',
        style: TextStyle(color: Color(0xFF78909C), fontSize: 7),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    penTP.paint(canvas, Offset(w / 2 + 15, 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
