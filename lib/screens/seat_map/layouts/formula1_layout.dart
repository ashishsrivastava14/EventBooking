import 'dart:math';
import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🏎️ Formula 1 / Motorsport – circuit map with grandstands.
class Formula1Layout extends BaseLayout {
  const Formula1Layout({
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
  double get mapWidth => 950;
  @override
  double get mapHeight => 750;

  @override
  Rect get fieldRect => const Rect.fromLTWH(100, 80, 750, 540);

  @override
  String getOrientationLabel() => 'Start/Finish Straight';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _F1CircuitPainter(),
      size: const Size(750, 540),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    // Main grandstand (start/finish straight)
    if (zoneIds.contains('main_grandstand')) {
      data.add(const ZoneRenderData(
          zoneId: 'main_grandstand',
          bounds: Rect.fromLTWH(300, 630, 350, 110)));
    }
    // Turn 1 grandstand
    if (zoneIds.contains('turn1')) {
      data.add(const ZoneRenderData(
          zoneId: 'turn1', bounds: Rect.fromLTWH(750, 400, 180, 150)));
    }
    // Hairpin grandstand
    if (zoneIds.contains('hairpin')) {
      data.add(const ZoneRenderData(
          zoneId: 'hairpin', bounds: Rect.fromLTWH(20, 200, 180, 150)));
    }
    // Pit straight grandstand
    if (zoneIds.contains('pit_straight')) {
      data.add(const ZoneRenderData(
          zoneId: 'pit_straight', bounds: Rect.fromLTWH(300, 10, 350, 60)));
    }
    // Chicane grandstand
    if (zoneIds.contains('chicane')) {
      data.add(const ZoneRenderData(
          zoneId: 'chicane', bounds: Rect.fromLTWH(750, 80, 180, 140)));
    }
    // Podium club
    if (zoneIds.contains('podium_club')) {
      data.add(const ZoneRenderData(
          zoneId: 'podium_club', bounds: Rect.fromLTWH(20, 450, 180, 130)));
    }
    return data;
  }
}

class _F1CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Track surface background
    final bgPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Track path
    final trackPaint = Paint()
      ..color = const Color(0xFF424242)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    final path = Path()
      ..moveTo(w * 0.35, h * 0.85)
      ..lineTo(w * 0.75, h * 0.85) // Start/finish straight
      ..quadraticBezierTo(
          w * 0.95, h * 0.85, w * 0.95, h * 0.65) // Turn 1
      ..lineTo(w * 0.95, h * 0.35) // Back straight right
      ..quadraticBezierTo(
          w * 0.95, h * 0.15, w * 0.75, h * 0.15) // Turn 2 (chicane)
      ..lineTo(w * 0.35, h * 0.15) // Pit straight
      ..quadraticBezierTo(
          w * 0.15, h * 0.15, w * 0.1, h * 0.3) // Turn 3
      ..lineTo(w * 0.1, h * 0.5) // Back straight left (hairpin approach)
      ..quadraticBezierTo(
          w * 0.05, h * 0.65, w * 0.15, h * 0.7) // Hairpin
      ..quadraticBezierTo(
          w * 0.25, h * 0.75, w * 0.2, h * 0.85) // Hairpin exit
      ..quadraticBezierTo(
          w * 0.15, h * 0.95, w * 0.35, h * 0.85); // Final corner

    // Run-off areas (wider track stroke)
    final runoffPath = Paint()
      ..color = const Color(0xFF78909C).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50;
    canvas.drawPath(path, runoffPath);

    // Track
    canvas.drawPath(path, trackPaint);

    // Track center line
    final centerLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, centerLinePaint);

    // Kerbs at key turns (red-white stripes)
    _drawKerb(canvas, w * 0.93, h * 0.75, w * 0.95, h * 0.58);
    _drawKerb(canvas, w * 0.85, h * 0.17, w * 0.93, h * 0.22);
    _drawKerb(canvas, w * 0.12, h * 0.25, w * 0.15, h * 0.45);

    // Start/finish line
    final sfPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(w * 0.55, h * 0.85 - 15),
        Offset(w * 0.55, h * 0.85 + 15),
        sfPaint);

    // Checkered flag pattern at start/finish
    final checkPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 2; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
                w * 0.55 - 8 + i * 4, h * 0.85 - 4 + j * 4, 4, 4),
            checkPaint,
          );
        }
      }
    }

    // Pit lane (dashed line parallel to pit straight)
    final pitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawLine(
        Offset(w * 0.35, h * 0.22), Offset(w * 0.75, h * 0.22), pitPaint);

    // Labels
    _drawLabel(canvas, 'S/F', w * 0.55, h * 0.78, Colors.white);
    _drawLabel(canvas, 'T1', w * 0.9, h * 0.72, const Color(0xFFFFD700));
    _drawLabel(canvas, 'T2', w * 0.88, h * 0.2, const Color(0xFFFFD700));
    _drawLabel(canvas, 'HAIRPIN', w * 0.12, h * 0.62, const Color(0xFFFFD700));
    _drawLabel(canvas, 'PIT LANE', w * 0.55, h * 0.25, const Color(0xFF90A4AE));

    // DRS zone indicator
    final drsPaint = Paint()
      ..color = const Color(0xFF00C48C)
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(w * 0.4, h * 0.85 + 16),
        Offset(w * 0.7, h * 0.85 + 16),
        drsPaint);
    _drawLabel(canvas, 'DRS', w * 0.55, h * 0.85 + 24, const Color(0xFF00C48C));

    // Direction arrows
    _drawArrow(canvas, w * 0.6, h * 0.85, 0); // right on straight
    _drawArrow(canvas, w * 0.95, h * 0.5, pi / 2); // down on back straight
    _drawArrow(canvas, w * 0.55, h * 0.15, pi); // left on pit straight
    _drawArrow(canvas, w * 0.1, h * 0.4, -pi / 2); // up on left
  }

  void _drawKerb(Canvas canvas, double x1, double y1, double x2, double y2) {
    final kerbPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 4;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), kerbPaint);
    final kerbWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    final dx = (x2 - x1) / 6;
    final dy = (y2 - y1) / 6;
    for (int i = 0; i < 6; i += 2) {
      canvas.drawLine(
        Offset(x1 + dx * i, y1 + dy * i),
        Offset(x1 + dx * (i + 1), y1 + dy * (i + 1)),
        kerbWhite,
      );
    }
  }

  void _drawLabel(
      Canvas canvas, String text, double cx, double cy, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color, fontSize: 8, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawArrow(Canvas canvas, double cx, double cy, double angle) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(6, 0)
      ..lineTo(-4, -4)
      ..lineTo(-4, 4)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
