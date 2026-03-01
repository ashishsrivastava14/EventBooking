import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🎤 Comedy club – small stage, round tables in arcs.
class ComedyLayout extends BaseLayout {
  const ComedyLayout({
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
  double get mapWidth => 700;
  @override
  double get mapHeight => 650;

  @override
  Rect get fieldRect => const Rect.fromLTWH(220, 20, 260, 120);

  @override
  String getOrientationLabel() => 'Stage Front';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _ComedyStagePainter(),
      size: const Size(260, 120),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    // Front tables (closest to stage – 2 rows)
    if (zoneIds.contains('front_tables')) {
      data.add(const ZoneRenderData(
          zoneId: 'front_tables', bounds: Rect.fromLTWH(120, 160, 460, 120)));
    }
    // Middle tables
    if (zoneIds.contains('middle_tables')) {
      data.add(const ZoneRenderData(
          zoneId: 'middle_tables', bounds: Rect.fromLTWH(80, 300, 540, 140)));
    }
    // Bar seating (back wall)
    if (zoneIds.contains('bar_seating')) {
      data.add(const ZoneRenderData(
          zoneId: 'bar_seating', bounds: Rect.fromLTWH(80, 460, 540, 90)));
    }
    // Balcony rail
    if (zoneIds.contains('balcony_rail')) {
      data.add(const ZoneRenderData(
          zoneId: 'balcony_rail', bounds: Rect.fromLTWH(120, 560, 460, 80)));
    }
    return data;
  }
}

class _ComedyStagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Raised stage platform
    final stagePaint = Paint()..color = const Color(0xFF3E2723);
    final stagePath = Path()
      ..moveTo(10, 10)
      ..lineTo(w - 10, 10)
      ..lineTo(w - 10, h - 10)
      ..quadraticBezierTo(w / 2, h + 5, 10, h - 10)
      ..close();
    canvas.drawPath(stagePath, stagePaint);

    // Stage edge
    final edgePaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final edgePath = Path()
      ..moveTo(10, h - 10)
      ..quadraticBezierTo(w / 2, h + 5, w - 10, h - 10);
    canvas.drawPath(edgePath, edgePaint);

    // Spotlight circle
    final spotPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(w / 2, h / 2), radius: 50));
    canvas.drawCircle(Offset(w / 2, h / 2), 50, spotPaint);

    // Microphone stand
    final micPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2;
    // Stand pole
    canvas.drawLine(
        Offset(w / 2, h * 0.35), Offset(w / 2, h * 0.75), micPaint);
    // Base tripod
    canvas.drawLine(
        Offset(w / 2, h * 0.75), Offset(w / 2 - 10, h * 0.82), micPaint);
    canvas.drawLine(
        Offset(w / 2, h * 0.75), Offset(w / 2 + 10, h * 0.82), micPaint);
    // Mic head
    final micHeadPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(w / 2, h * 0.32), 6, micHeadPaint);

    // "STAGE" label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'STAGE',
        style: TextStyle(
          color: Color(0xFFBCAAA4),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, 16));

    // Stool
    final stoolPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(w / 2 + 30, h * 0.5), Offset(w / 2 + 30, h * 0.75), stoolPaint);
    canvas.drawLine(Offset(w / 2 + 22, h * 0.5),
        Offset(w / 2 + 38, h * 0.5), stoolPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
