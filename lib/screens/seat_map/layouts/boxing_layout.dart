import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🥊 Boxing ring or MMA octagon – central ring, concentric seating.
class BoxingLayout extends BaseLayout {
  const BoxingLayout({
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
  double get mapWidth => 850;
  @override
  double get mapHeight => 850;

  @override
  Rect get fieldRect => const Rect.fromLTWH(275, 275, 300, 300);

  @override
  String getOrientationLabel() => 'Center Ring';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _BoxingRingPainter(),
      size: const Size(300, 300),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    // Ringside (closest ring) – 4 sections around ring
    if (zoneIds.contains('ringside_n')) {
      data.add(const ZoneRenderData(
          zoneId: 'ringside_n', bounds: Rect.fromLTWH(275, 180, 300, 80)));
    }
    if (zoneIds.contains('ringside_s')) {
      data.add(const ZoneRenderData(
          zoneId: 'ringside_s', bounds: Rect.fromLTWH(275, 590, 300, 80)));
    }
    if (zoneIds.contains('ringside_e')) {
      data.add(const ZoneRenderData(
          zoneId: 'ringside_e', bounds: Rect.fromLTWH(590, 275, 80, 300)));
    }
    if (zoneIds.contains('ringside_w')) {
      data.add(const ZoneRenderData(
          zoneId: 'ringside_w', bounds: Rect.fromLTWH(180, 275, 80, 300)));
    }

    // Floor level
    if (zoneIds.contains('floor_n')) {
      data.add(const ZoneRenderData(
          zoneId: 'floor_n', bounds: Rect.fromLTWH(200, 70, 450, 100)));
    }
    if (zoneIds.contains('floor_s')) {
      data.add(const ZoneRenderData(
          zoneId: 'floor_s', bounds: Rect.fromLTWH(200, 680, 450, 100)));
    }

    // Lower tier – outer ring
    if (zoneIds.contains('lower_e')) {
      data.add(const ZoneRenderData(
          zoneId: 'lower_e', bounds: Rect.fromLTWH(690, 200, 140, 450)));
    }
    if (zoneIds.contains('lower_w')) {
      data.add(const ZoneRenderData(
          zoneId: 'lower_w', bounds: Rect.fromLTWH(20, 200, 140, 450)));
    }

    // Upper tier – corners
    if (zoneIds.contains('upper_nw')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_nw', bounds: Rect.fromLTWH(20, 20, 160, 160)));
    }
    if (zoneIds.contains('upper_ne')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_ne', bounds: Rect.fromLTWH(670, 20, 160, 160)));
    }
    if (zoneIds.contains('upper_sw')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_sw', bounds: Rect.fromLTWH(20, 670, 160, 160)));
    }
    if (zoneIds.contains('upper_se')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_se', bounds: Rect.fromLTWH(670, 670, 160, 160)));
    }
    return data;
  }
}

class _BoxingRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Canvas surface
    final canvasPaint = Paint()..color = const Color(0xFFE0D1B0);
    canvas.drawRect(Rect.fromLTWH(10, 10, w - 20, h - 20), canvasPaint);

    // Ring posts (4 corners)
    final postPaint = Paint()..color = const Color(0xFF424242);
    final postPositions = [
      Offset(20, 20),
      Offset(w - 20, 20),
      Offset(20, h - 20),
      Offset(w - 20, h - 20),
    ];
    for (final pos in postPositions) {
      canvas.drawCircle(pos, 6, postPaint);
    }

    // Ring ropes (3 horizontal lines on each side)
    final ropeColors = [
      const Color(0xFFD32F2F), // Red
      Colors.white,
      const Color(0xFF1565C0), // Blue
    ];
    for (int i = 0; i < 3; i++) {
      final offset = 5.0 + i * 3;
      final rp = Paint()
        ..color = ropeColors[i]
        ..strokeWidth = 2;
      // top rope
      canvas.drawLine(Offset(20, 20 + offset), Offset(w - 20, 20 + offset), rp);
      // bottom rope
      canvas.drawLine(
          Offset(20, h - 20 - offset), Offset(w - 20, h - 20 - offset), rp);
      // left rope
      canvas.drawLine(Offset(20 + offset, 20), Offset(20 + offset, h - 20), rp);
      // right rope
      canvas.drawLine(
          Offset(w - 20 - offset, 20), Offset(w - 20 - offset, h - 20), rp);
    }

    // Red corner
    final redCornerPaint = Paint()
      ..color = const Color(0xFFD32F2F).withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(12, 12, 30, 30), redCornerPaint);

    // Blue corner
    final blueCornerPaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(w - 42, h - 42, 30, 30), blueCornerPaint);

    // Corner labels
    _drawLabel(canvas, 'RED', 27, 50, const Color(0xFFD32F2F));
    _drawLabel(canvas, 'BLUE', w - 32, h - 56, const Color(0xFF1565C0));

    // Center ring logo area
    final logoPaint = Paint()
      ..color = const Color(0xFF8D6E63).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(cx, cy), 30, logoPaint);

    // Judge tables (3 sides)
    final judgePaint = Paint()
      ..color = const Color(0xFF616161);
    canvas.drawRect(Rect.fromLTWH(cx - 20, h + 4, 40, 8), judgePaint);
    canvas.drawRect(Rect.fromLTWH(-8, cy - 15, 8, 30), judgePaint);
    canvas.drawRect(Rect.fromLTWH(w, cy - 15, 8, 30), judgePaint);

    _drawLabel(canvas, 'JUDGE', cx, h + 14, const Color(0xFF9E9E9E));
  }

  void _drawLabel(
      Canvas canvas, String text, double x, double y, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
