// Generates the app launcher icon PNGs into assets/icon/.
//
// Run:  flutter test tools/icon/generate_icon_test.dart
// Then: dart run flutter_launcher_icons
//
// Design: brand-navy background with soft "campus map" roads, a gold map pin
// holding a white disc with a navy "LC" (Lead City) monogram, and a white
// dotted walking route leading into the pin.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double S = 1024;

const navyLight = Color(0xFF4256A8);
const navy = Color(0xFF2E3D77);
const navyDeep = Color(0xFF111A3D);
const gold = Color(0xFFE8B04B);
const goldLight = Color(0xFFF6CF7E);
const goldDark = Color(0xFFC98419);

void paintBackground(Canvas c) {
  final rect = Rect.fromLTWH(0, 0, S, S);
  c.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [navyLight, navy, navyDeep],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect),
  );
  // Soft light, top right (behind the pin).
  c.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.35),
        radius: 0.6,
        colors: [
          const Color(0xFF6F84D6).withValues(alpha: 0.45),
          const Color(0xFF6F84D6).withValues(alpha: 0),
        ],
      ).createShader(rect),
  );
  // Faint campus roads.
  final road = Paint()
    ..color = Colors.white.withValues(alpha: 0.07)
    ..style = PaintingStyle.stroke
    ..strokeWidth = S * 0.035
    ..strokeCap = StrokeCap.round;
  c.drawPath(
    Path()
      ..moveTo(-S * 0.1, S * 0.30)
      ..cubicTo(S * 0.30, S * 0.22, S * 0.55, S * 0.40, S * 1.1, S * 0.18),
    road,
  );
  c.drawPath(
    Path()
      ..moveTo(S * 0.20, S * 1.1)
      ..cubicTo(S * 0.28, S * 0.70, S * 0.18, S * 0.45, S * 0.32, -S * 0.1),
    road,
  );
  c.drawPath(
    Path()
      ..moveTo(-S * 0.1, S * 0.86)
      ..cubicTo(S * 0.40, S * 0.95, S * 0.75, S * 0.78, S * 1.1, S * 0.90),
    road..strokeWidth = S * 0.025,
  );
}

/// Pin + route + monogram. [scale] shrinks the art around the centre so it
/// fits Android's adaptive-icon safe zone (centre 66%).
void paintForeground(Canvas c, {double scale = 1}) {
  c.save();
  c.translate(S / 2, S / 2);
  c.scale(scale);
  c.translate(-S / 2, -S / 2);

  // Pin geometry.
  final cx = S * 0.585, cy = S * 0.405, r = S * 0.185;
  final tip = Offset(cx, S * 0.70);

  // Walking route (dotted) from bottom-left into the pin's tip.
  final route = Path()
    ..moveTo(S * 0.255, S * 0.765)
    ..cubicTo(S * 0.33, S * 0.60, S * 0.45, S * 0.80, tip.dx - S * 0.02, tip.dy + S * 0.005);
  final dot = Paint()..color = Colors.white;
  for (final m in route.computeMetrics()) {
    // Start clear of the start ring; stop just short of the pin tip.
    var d = S * 0.10;
    final step = S * 0.062;
    while (d < m.length - S * 0.035) {
      c.drawCircle(m.getTangentForOffset(d)!.position, S * 0.018, dot);
      d += step;
    }
  }

  // Start point: white ring with navy centre.
  final start = Offset(S * 0.255, S * 0.765);
  c.drawCircle(start, S * 0.052, Paint()..color = Colors.white);
  c.drawCircle(start, S * 0.026, Paint()..color = navy);

  // Pin shadow.
  final pin = Path()
    ..moveTo(tip.dx, tip.dy)
    ..cubicTo(cx - r * 0.55, tip.dy - r * 0.55, cx - r, cy + r * 0.62, cx - r, cy)
    ..arcToPoint(Offset(cx + r, cy), radius: Radius.circular(r))
    ..cubicTo(cx + r, cy + r * 0.62, cx + r * 0.55, tip.dy - r * 0.55, tip.dx, tip.dy)
    ..close();
  c.drawPath(
    pin.shift(Offset(0, S * 0.018)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, S * 0.025),
  );
  // Pin body: gold gradient.
  c.drawPath(
    pin,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [goldLight, gold, goldDark],
      ).createShader(Rect.fromLTRB(cx - r, cy - r, cx + r, tip.dy)),
  );
  // Soft highlight on the pin's upper-left.
  c.drawPath(
    pin,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.7),
        radius: 0.7,
        colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromLTRB(cx - r, cy - r, cx + r, tip.dy)),
  );

  // White disc.
  final discR = r * 0.68;
  c.drawCircle(Offset(cx, cy), discR, Paint()..color = Colors.white);

  // "LC" monogram (geometric, navy).
  final ink = Paint()..color = navy;
  final h = discR * 0.95; // letter height
  final t = discR * 0.20; // stroke thickness
  final top = cy - h / 2;
  // L
  final lx = cx - discR * 0.58;
  c.drawRRect(
    RRect.fromRectAndRadius(
        Rect.fromLTWH(lx, top, t, h), Radius.circular(t * 0.25)),
    ink,
  );
  c.drawRRect(
    RRect.fromRectAndRadius(
        Rect.fromLTWH(lx, top + h - t, discR * 0.50, t),
        Radius.circular(t * 0.25)),
    ink,
  );
  // C
  final cR = h / 2 - t / 2;
  final cCentre = Offset(cx + discR * 0.22, cy);
  c.drawArc(
    Rect.fromCircle(center: cCentre, radius: cR),
    math.pi * 0.25,
    math.pi * 1.5,
    false,
    Paint()
      ..color = navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = t
      ..strokeCap = StrokeCap.round,
  );

  c.restore();
}

Future<void> save(String path, void Function(Canvas) draw) async {
  final rec = ui.PictureRecorder();
  draw(Canvas(rec));
  final img = await rec.endRecording().toImage(S.toInt(), S.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  final f = File(path)..createSync(recursive: true);
  f.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('generate launcher icon PNGs', () async {
    // Full icon (iOS + legacy Android): background + art, fully opaque.
    await save('assets/icon/icon_full.png', (c) {
      paintBackground(c);
      paintForeground(c, scale: 1.0);
    });
    // Adaptive icon layers (Android 8+): art kept inside the safe zone.
    await save('assets/icon/icon_background.png', paintBackground);
    await save('assets/icon/icon_foreground.png',
        (c) => paintForeground(c, scale: 0.78));

    // Previews (not used by the app): adaptive icon in a circle mask, large
    // and at real home-screen size.
    for (final size in [1024.0, 144.0]) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      c.scale(size / S);
      c.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, S, S)));
      // Adaptive layers are 108dp with ~18dp hidden per side: crop 1/6.
      c.translate(-S / 12, -S / 12);
      c.scale(1 + 1 / 6);
      paintBackground(c);
      paintForeground(c, scale: 0.78);
      final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
      final b = await img.toByteData(format: ui.ImageByteFormat.png);
      File('build/icon_preview/adaptive_${size.toInt()}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(b!.buffer.asUint8List());
    }
  });
}
