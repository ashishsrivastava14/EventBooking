import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🎾 Tennis court – rectangle court with seats on all 4 sides.
class TennisLayout extends BaseLayout {
  const TennisLayout({
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
  double get mapWidth => 820;
  @override
  double get mapHeight => 700;

  @override
  Rect get fieldRect => const Rect.fromLTWH(190, 180, 440, 340);

  @override
  String getOrientationLabel() => 'Baseline–Baseline';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _TennisCourtPainter(),
      size: const Size(440, 340),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('north_baseline')) {
      data.add(const ZoneRenderData(
          zoneId: 'north_baseline', bounds: Rect.fromLTWH(190, 20, 440, 140)));
    }
    if (zoneIds.contains('south_baseline')) {
      data.add(const ZoneRenderData(
          zoneId: 'south_baseline',
          bounds: Rect.fromLTWH(190, 540, 440, 140)));
    }
    if (zoneIds.contains('east_court')) {
      data.add(const ZoneRenderData(
          zoneId: 'east_court', bounds: Rect.fromLTWH(650, 180, 150, 340)));
    }
    if (zoneIds.contains('west_court')) {
      data.add(const ZoneRenderData(
          zoneId: 'west_court', bounds: Rect.fromLTWH(20, 180, 150, 340)));
    }
    if (zoneIds.contains('royal_box')) {
      data.add(const ZoneRenderData(
          zoneId: 'royal_box', bounds: Rect.fromLTWH(20, 20, 150, 140)));
    }
    if (zoneIds.contains('debenture')) {
      data.add(const ZoneRenderData(
          zoneId: 'debenture', bounds: Rect.fromLTWH(650, 20, 150, 140)));
    }
    return data;
  }
}

class _TennisCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Court surface – blue hard court
    final courtPaint = Paint()..color = const Color(0xFF1565C0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), const Radius.circular(2)),
      courtPaint,
    );

    // Surrounding area – green
    final surroundPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 30), surroundPaint);
    canvas.drawRect(Rect.fromLTWH(0, h - 30, w, 30), surroundPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, 40, h), surroundPaint);
    canvas.drawRect(Rect.fromLTWH(w - 40, 0, 40, h), surroundPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer court (doubles)
    final courtRect = Rect.fromLTWH(40, 30, w - 80, h - 60);
    canvas.drawRect(courtRect, linePaint);

    // Singles sidelines
    final singlesInset = 20.0;
    canvas.drawLine(
        Offset(40 + singlesInset, 30),
        Offset(40 + singlesInset, h - 30),
        linePaint);
    canvas.drawLine(
        Offset(w - 40 - singlesInset, 30),
        Offset(w - 40 - singlesInset, h - 30),
        linePaint);

    // Net line (center)
    final netPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(40, h / 2), Offset(w - 40, h / 2), netPaint);

    // Net posts
    final postPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(36, h / 2), 4, postPaint);
    canvas.drawCircle(Offset(w - 36, h / 2), 4, postPaint);

    // Service lines
    final serviceY1 = 30 + (h - 60) * 0.28;
    final serviceY2 = h - 30 - (h - 60) * 0.28;
    canvas.drawLine(
        Offset(40 + singlesInset, serviceY1),
        Offset(w - 40 - singlesInset, serviceY1),
        linePaint);
    canvas.drawLine(
        Offset(40 + singlesInset, serviceY2),
        Offset(w - 40 - singlesInset, serviceY2),
        linePaint);

    // Center service line
    canvas.drawLine(
        Offset(w / 2, serviceY1), Offset(w / 2, serviceY2), linePaint);

    // Center marks on baselines
    canvas.drawLine(
        Offset(w / 2, 30), Offset(w / 2, 38), linePaint);
    canvas.drawLine(
        Offset(w / 2, h - 30), Offset(w / 2, h - 38), linePaint);

    // "NET" label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'NET',
        style: TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
        canvas, Offset(w / 2 - textPainter.width / 2, h / 2 + 5));

    // Umpire chair (small icon)
    final umpPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawRect(
        Rect.fromLTWH(w - 40 - singlesInset - 8, h / 2 - 8, 6, 16),
        umpPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
