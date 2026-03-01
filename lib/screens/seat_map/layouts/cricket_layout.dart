import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🏏 Cricket stadium – oval field with pitch in center.
class CricketLayout extends BaseLayout {
  const CricketLayout({
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
  double get mapHeight => 880;

  @override
  Rect get fieldRect => const Rect.fromLTWH(200, 200, 500, 480);

  @override
  String getOrientationLabel() => 'North–South';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _CricketFieldPainter(),
      size: const Size(500, 480),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('north')) {
      data.add(const ZoneRenderData(
          zoneId: 'north', bounds: Rect.fromLTWH(150, 20, 600, 160)));
    }
    if (zoneIds.contains('south')) {
      data.add(const ZoneRenderData(
          zoneId: 'south', bounds: Rect.fromLTWH(150, 700, 600, 160)));
    }
    if (zoneIds.contains('east')) {
      data.add(const ZoneRenderData(
          zoneId: 'east', bounds: Rect.fromLTWH(720, 200, 160, 230)));
    }
    if (zoneIds.contains('west')) {
      data.add(const ZoneRenderData(
          zoneId: 'west', bounds: Rect.fromLTWH(20, 200, 160, 230)));
    }
    if (zoneIds.contains('pavilion')) {
      data.add(const ZoneRenderData(
          zoneId: 'pavilion', bounds: Rect.fromLTWH(720, 450, 160, 230)));
    }
    if (zoneIds.contains('members')) {
      data.add(const ZoneRenderData(
          zoneId: 'members', bounds: Rect.fromLTWH(20, 450, 160, 230)));
    }
    return data;
  }
}

class _CricketFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width / 2 - 10;
    final ry = size.height / 2 - 10;

    // Green oval outfield
    final fieldPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      fieldPaint,
    );

    // Lighter inner oval
    final innerPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 1.6, height: ry * 1.6),
      innerPaint,
    );

    // 30-yard circle
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 1.2, height: ry * 1.2),
      circlePaint,
    );

    // Boundary rope
    final ropePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      ropePaint,
    );

    // Pitch (center rectangle)
    final pitchW = 24.0;
    final pitchH = 100.0;
    final pitchRect = Rect.fromCenter(
      center: center,
      width: pitchW,
      height: pitchH,
    );
    final pitchPaint = Paint()..color = const Color(0xFFD2B48C);
    canvas.drawRect(pitchRect, pitchPaint);

    // Pitch crease lines
    final creasePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    // Batting crease at both ends
    canvas.drawLine(
      Offset(center.dx - 18, center.dy - pitchH / 2 + 8),
      Offset(center.dx + 18, center.dy - pitchH / 2 + 8),
      creasePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 18, center.dy + pitchH / 2 - 8),
      Offset(center.dx + 18, center.dy + pitchH / 2 - 8),
      creasePaint,
    );

    // Stumps (small lines at each end)
    final stumpPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx - 4, center.dy - pitchH / 2),
      Offset(center.dx + 4, center.dy - pitchH / 2),
      stumpPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 4, center.dy + pitchH / 2),
      Offset(center.dx + 4, center.dy + pitchH / 2),
      stumpPaint,
    );

    // Sight screens (white rectangles at top & bottom of oval)
    final screenPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(center.dx, 20), width: 40, height: 10),
      screenPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(center.dx, size.height - 20), width: 40, height: 10),
      screenPaint,
    );

    // Pitch label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '22 yards',
        style: TextStyle(color: Colors.white70, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + pitchH / 2 + 6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
