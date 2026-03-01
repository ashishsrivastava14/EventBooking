import 'package:flutter/material.dart';
import 'base_layout.dart';

/// 🎭 Theatre / Drama – proscenium arch stage, curved seating rows.
class TheatreLayout extends BaseLayout {
  const TheatreLayout({
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
  double get mapHeight => 800;

  @override
  Rect get fieldRect => const Rect.fromLTWH(160, 20, 500, 160);

  @override
  String getOrientationLabel() => 'Stage Front';

  @override
  Widget buildFieldOrStage(BuildContext context) {
    return CustomPaint(
      painter: _TheatreStagePainter(),
      size: const Size(500, 160),
    );
  }

  @override
  List<ZoneRenderData> getZoneRenderData() {
    final zoneIds = zones.map((z) => z.zoneId).toList();
    final data = <ZoneRenderData>[];

    // Orchestra pit area label
    // Stalls (ground floor)
    if (zoneIds.contains('stalls')) {
      data.add(const ZoneRenderData(
          zoneId: 'stalls', bounds: Rect.fromLTWH(160, 200, 500, 160)));
    }
    // Dress Circle
    if (zoneIds.contains('dress_circle')) {
      data.add(const ZoneRenderData(
          zoneId: 'dress_circle', bounds: Rect.fromLTWH(160, 380, 500, 130)));
    }
    // Upper Circle
    if (zoneIds.contains('upper_circle')) {
      data.add(const ZoneRenderData(
          zoneId: 'upper_circle', bounds: Rect.fromLTWH(160, 530, 500, 120)));
    }
    // Balcony / Gods
    if (zoneIds.contains('balcony')) {
      data.add(const ZoneRenderData(
          zoneId: 'balcony', bounds: Rect.fromLTWH(160, 670, 500, 110)));
    }
    // Left Boxes
    if (zoneIds.contains('box_left')) {
      data.add(const ZoneRenderData(
          zoneId: 'box_left', bounds: Rect.fromLTWH(20, 200, 120, 300)));
    }
    // Right Boxes
    if (zoneIds.contains('box_right')) {
      data.add(const ZoneRenderData(
          zoneId: 'box_right', bounds: Rect.fromLTWH(680, 200, 120, 300)));
    }
    return data;
  }
}

class _TheatreStagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Proscenium arch
    final archPaint = Paint()..color = const Color(0xFF5D4037);
    // Left column
    canvas.drawRect(Rect.fromLTWH(0, 0, 20, h), archPaint);
    // Right column
    canvas.drawRect(Rect.fromLTWH(w - 20, 0, 20, h), archPaint);
    // Top arch
    final archPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, 20)
      ..quadraticBezierTo(w / 2, 35, 0, 20)
      ..close();
    canvas.drawPath(archPath, archPaint);

    // Arch decoration
    final decorPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final decorPath = Path()
      ..moveTo(20, 20)
      ..quadraticBezierTo(w / 2, 40, w - 20, 20);
    canvas.drawPath(decorPath, decorPaint);

    // Stage floor
    final stagePaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(20, 30, w - 40, h - 50), stagePaint);

    // Stage planks
    final plankPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 0.5;
    for (double x = 25; x < w - 25; x += 15) {
      canvas.drawLine(Offset(x, 30), Offset(x, h - 20), plankPaint);
    }

    // Apron (front of stage – extends toward audience)
    final apronPath = Path()
      ..moveTo(20, h - 20)
      ..lineTo(w - 20, h - 20)
      ..quadraticBezierTo(w / 2, h + 5, 20, h - 20);
    final apronPaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawPath(apronPath, apronPaint);

    // Orchestra pit (below apron)
    final pitPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(60, h - 8, w - 120, 8), pitPaint);

    final pitLabel = TextPainter(
      text: const TextSpan(
        text: 'ORCHESTRA PIT',
        style: TextStyle(
            color: Color(0xFF78909C), fontSize: 7, letterSpacing: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pitLabel.paint(canvas, Offset(w / 2 - pitLabel.width / 2, h - 7));

    // Curtain lines
    final curtainPaint = Paint()
      ..color = const Color(0xFFC62828).withValues(alpha: 0.3)
      ..strokeWidth = 2;
    // Left curtain drape
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(25 + i * 4.0, 30),
        Offset(22 + i * 5.0, h - 25),
        curtainPaint,
      );
    }
    // Right curtain drape
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(w - 25 - i * 4.0, 30),
        Offset(w - 22 - i * 5.0, h - 25),
        curtainPaint,
      );
    }

    // "STAGE" label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'STAGE',
        style: TextStyle(
          color: Color(0xFFBCAAA4),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h / 2 - 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
