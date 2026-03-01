import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🎵 Concert / Music venue – stage at top, floor + tiered seating below.
class ConcertLayout extends BaseLayout {
  const ConcertLayout({
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
  double get mapHeight => 850;

  @override
  Rect get fieldRect => const Rect.fromLTWH(200, 20, 500, 140);

  @override
  String getOrientationLabel() => 'Stage Front';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _ConcertStagePainter(),
      size: const Size(500, 140),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    // Pit (directly at stage)
    if (zoneIds.contains('pit')) {
      data.add(const ZoneRenderData(
          zoneId: 'pit', bounds: Rect.fromLTWH(250, 170, 400, 80)));
    }
    // Floor GA
    if (zoneIds.contains('floor_ga')) {
      data.add(const ZoneRenderData(
          zoneId: 'floor_ga', bounds: Rect.fromLTWH(200, 260, 500, 140)));
    }
    // Floor Reserved
    if (zoneIds.contains('floor_reserved')) {
      data.add(const ZoneRenderData(
          zoneId: 'floor_reserved',
          bounds: Rect.fromLTWH(200, 410, 500, 120)));
    }
    // Left Orchestra
    if (zoneIds.contains('left_orch')) {
      data.add(const ZoneRenderData(
          zoneId: 'left_orch', bounds: Rect.fromLTWH(20, 260, 160, 270)));
    }
    // Right Orchestra
    if (zoneIds.contains('right_orch')) {
      data.add(const ZoneRenderData(
          zoneId: 'right_orch', bounds: Rect.fromLTWH(720, 260, 160, 270)));
    }
    // Left Mezzanine
    if (zoneIds.contains('left_mezz')) {
      data.add(const ZoneRenderData(
          zoneId: 'left_mezz', bounds: Rect.fromLTWH(20, 550, 160, 130)));
    }
    // Right Mezzanine
    if (zoneIds.contains('right_mezz')) {
      data.add(const ZoneRenderData(
          zoneId: 'right_mezz', bounds: Rect.fromLTWH(720, 550, 160, 130)));
    }
    // Balcony
    if (zoneIds.contains('balcony')) {
      data.add(const ZoneRenderData(
          zoneId: 'balcony', bounds: Rect.fromLTWH(200, 550, 500, 130)));
    }
    // VIP Platform
    if (zoneIds.contains('vip_platform')) {
      data.add(const ZoneRenderData(
          zoneId: 'vip_platform', bounds: Rect.fromLTWH(300, 700, 300, 130)));
    }
    return data;
  }
}

class _ConcertStagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stage background
    final stagePaint = Paint()..color = const Color(0xFF1A1A2E);
    final stagePath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - 30)
      ..quadraticBezierTo(w / 2, h + 10, 0, h - 30)
      ..close();
    canvas.drawPath(stagePath, stagePaint);

    // Stage edge glow
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF026CDF), Color(0xFF7B2FBE)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, h - 34, w, 8));
    canvas.drawRect(Rect.fromLTWH(0, h - 34, w, 4), glowPaint);

    // Stage lip curve
    final lipPaint = Paint()
      ..color = const Color(0xFF026CDF).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final lipPath = Path()
      ..moveTo(0, h - 30)
      ..quadraticBezierTo(w / 2, h + 10, w, h - 30);
    canvas.drawPath(lipPath, lipPaint);

    // PA speakers (rectangles on sides)
    final speakerPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRect(Rect.fromLTWH(8, 20, 25, 60), speakerPaint);
    canvas.drawRect(Rect.fromLTWH(w - 33, 20, 25, 60), speakerPaint);
    // Speaker grills
    final grillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
          Offset(10, 25 + i * 10.0), Offset(31, 25 + i * 10.0), grillPaint);
      canvas.drawLine(Offset(w - 31, 25 + i * 10.0),
          Offset(w - 10, 25 + i * 10.0), grillPaint);
    }

    // Spotlight effects
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.3, 10), radius: 60));
    canvas.drawCircle(Offset(w * 0.3, 10), 60, spotlightPaint);

    final spotlightPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.7, 10), radius: 60));
    canvas.drawCircle(Offset(w * 0.7, 10), 60, spotlightPaint2);

    // "STAGE" label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'STAGE',
        style: TextStyle(
          color: Color(0xFF5BABF5),
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h / 2 - tp.height / 2 - 10));

    // Catwalk hint (line from center stage lip down)
    final catwalkPaint = Paint()
      ..color = const Color(0xFF026CDF).withValues(alpha: 0.2)
      ..strokeWidth = 20;
    canvas.drawLine(Offset(w / 2, h - 30), Offset(w / 2, h + 5), catwalkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
