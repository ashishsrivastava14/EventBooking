import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🎮 eSports arena – hexagonal stage, neon-accent seating.
class EsportsLayout extends BaseLayout {
  const EsportsLayout({
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
  double get mapHeight => 780;

  @override
  Rect get fieldRect => const Rect.fromLTWH(200, 20, 500, 180);

  @override
  String getOrientationLabel() => 'Stage Front';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _EsportsStagePainter(),
      size: const Size(500, 180),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    if (zoneIds.contains('floor_standing')) {
      data.add(const ZoneRenderData(
          zoneId: 'floor_standing',
          bounds: Rect.fromLTWH(200, 220, 500, 120)));
    }
    if (zoneIds.contains('floor_reserved')) {
      data.add(const ZoneRenderData(
          zoneId: 'floor_reserved',
          bounds: Rect.fromLTWH(200, 350, 500, 130)));
    }
    if (zoneIds.contains('lower_tier')) {
      data.add(const ZoneRenderData(
          zoneId: 'lower_tier', bounds: Rect.fromLTWH(200, 500, 500, 120)));
    }
    if (zoneIds.contains('upper_tier')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_tier', bounds: Rect.fromLTWH(200, 640, 500, 120)));
    }
    if (zoneIds.contains('vip_lounge')) {
      data.add(const ZoneRenderData(
          zoneId: 'vip_lounge', bounds: Rect.fromLTWH(20, 220, 160, 300)));
    }
    if (zoneIds.contains('side_tier')) {
      data.add(const ZoneRenderData(
          zoneId: 'side_tier', bounds: Rect.fromLTWH(720, 220, 160, 300)));
    }
    return data;
  }
}

class _EsportsStagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark background
    final bgPaint = Paint()..color = const Color(0xFF0A0E1A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Hexagonal stage
    final hexPaint = Paint()..color = const Color(0xFF1A1A2E);
    final hexPath = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * 0.3, h * 0.1)
      ..lineTo(w * 0.7, h * 0.1)
      ..lineTo(w * 0.85, h * 0.5)
      ..lineTo(w * 0.7, h * 0.9)
      ..lineTo(w * 0.3, h * 0.9)
      ..close();
    canvas.drawPath(hexPath, hexPaint);

    // Neon hex outline
    final neonPaint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(hexPath, neonPaint);

    // Inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7B2FBE).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(w / 2, h / 2), radius: 100));
    canvas.drawCircle(Offset(w / 2, h / 2), 100, glowPaint);

    // Team A station (left)
    final teamAPaint = Paint()..color = const Color(0xFF1565C0).withValues(alpha: 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.18, h * 0.3, w * 0.22, h * 0.4),
          const Radius.circular(4)),
      teamAPaint,
    );
    _drawLabel(canvas, 'TEAM A', w * 0.29, h * 0.5, const Color(0xFF42A5F5));

    // Team B station (right)
    final teamBPaint = Paint()..color = const Color(0xFFD32F2F).withValues(alpha: 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.6, h * 0.3, w * 0.22, h * 0.4),
          const Radius.circular(4)),
      teamBPaint,
    );
    _drawLabel(canvas, 'TEAM B', w * 0.71, h * 0.5, const Color(0xFFEF5350));

    // Large screen backdrop
    final screenPaint = Paint()
      ..color = const Color(0xFF0D1432)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.1, 4, w * 0.8, 12), const Radius.circular(2)),
      screenPaint,
    );
    final screenBorder = Paint()
      ..color = const Color(0xFF00BCD4).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.1, 4, w * 0.8, 12), const Radius.circular(2)),
      screenBorder,
    );
    _drawLabel(canvas, 'SCREEN', w / 2, 10, const Color(0xFF00BCD4));

    // Analyst desk
    final deskPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.35, h - 20, w * 0.3, 14),
          const Radius.circular(3)),
      deskPaint,
    );
    _drawLabel(
        canvas, 'ANALYST DESK', w / 2, h - 13, const Color(0xFF90A4AE));

    // "VS" label
    final vsPaint = TextPainter(
      text: const TextSpan(
        text: 'VS',
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    vsPaint.paint(
        canvas, Offset(w / 2 - vsPaint.width / 2, h / 2 - vsPaint.height / 2));
  }

  void _drawLabel(
      Canvas canvas, String text, double cx, double cy, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color, fontSize: 7, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
