import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/building_category.dart';
import '../theme/app_colors.dart';

/// Draws crisp custom map markers once and caches them for the session.
///
/// Bitmaps are rendered at the device pixel ratio so they stay sharp on
/// high-density screens.
class MapMarkers {
  MapMarkers._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static double get _dpr {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    return views.isEmpty ? 3.0 : views.first.devicePixelRatio;
  }

  /// Pre-renders every category marker (normal + selected) in parallel.
  static Future<void> warmUp() => Future.wait([
        for (final c in BuildingCategory.values) ...[
          category(c),
          category(c, selected: true),
        ],
        start(),
        destination(),
        userDot(),
      ]);

  /// Returns a cached marker if it is ready, else null (use [warmUp] first).
  static BitmapDescriptor? cached(BuildingCategory c, {bool selected = false}) =>
      _cache[_categoryKey(c, selected)];

  static BitmapDescriptor? get cachedUserDot => _cache['user'];
  static BitmapDescriptor? get cachedStart => _cache['start'];
  static BitmapDescriptor? get cachedDestination => _cache['dest'];

  static String _categoryKey(BuildingCategory c, bool selected) =>
      'cat_${c.name}_$selected';

  /// Round badge with the category icon. Selected = filled + larger.
  static Future<BitmapDescriptor> category(
    BuildingCategory c, {
    bool selected = false,
  }) {
    return _memo(_categoryKey(c, selected), () {
      final logical = selected ? 46.0 : 34.0;
      return _draw(logical, (canvas, s) {
        final center = Offset(s / 2, s / 2);
        final r = s / 2 - s * 0.08;
        canvas.drawCircle(
          center.translate(0, s * 0.03),
          r,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.25)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.05),
        );
        canvas.drawCircle(
            center, r, Paint()..color = selected ? c.color : Colors.white);
        canvas.drawCircle(
          center,
          r - s * 0.03,
          Paint()
            ..color = selected ? Colors.white : c.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.05,
        );
        _drawIcon(canvas, c.icon, center, s * 0.48,
            selected ? Colors.white : c.color);
      });
    });
  }

  /// Start of route: white disc with a thick green ring.
  static Future<BitmapDescriptor> start() => _memo('start', () {
        return _draw(30, (canvas, s) {
          final center = Offset(s / 2, s / 2);
          canvas.drawCircle(
            center,
            s * 0.42,
            Paint()
              ..color = Colors.black.withValues(alpha: 0.22)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.06),
          );
          canvas.drawCircle(center, s * 0.38, Paint()..color = AppColors.success);
          canvas.drawCircle(center, s * 0.2, Paint()..color = Colors.white);
        });
      });

  /// Destination pin: navy teardrop with a white core and gold dot.
  static Future<BitmapDescriptor> destination() => _memo('dest', () {
        return _draw(48, (canvas, s) {
          final w = s;
          final path = Path()
            ..moveTo(w / 2, s * 0.96)
            ..cubicTo(w * 0.15, s * 0.62, w * 0.1, s * 0.48, w * 0.1, s * 0.4)
            ..arcToPoint(Offset(w * 0.9, s * 0.4),
                radius: Radius.circular(w * 0.4))
            ..cubicTo(w * 0.9, s * 0.48, w * 0.85, s * 0.62, w / 2, s * 0.96)
            ..close();
          canvas.drawPath(
            path.shift(Offset(0, s * 0.02)),
            Paint()
              ..color = Colors.black.withValues(alpha: 0.25)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.04),
          );
          canvas.drawPath(path, Paint()..color = AppColors.primary);
          canvas.drawCircle(
              Offset(w / 2, s * 0.4), s * 0.18, Paint()..color = Colors.white);
          canvas.drawCircle(
              Offset(w / 2, s * 0.4), s * 0.09, Paint()..color = AppColors.accent);
        });
      });

  /// Live position: blue dot, white ring, soft halo and a heading cone
  /// (rotate the marker to the walking direction).
  static Future<BitmapDescriptor> userDot() => _memo('user', () {
        return _draw(64, (canvas, s) {
          final c = Offset(s / 2, s / 2);
          // Heading cone (points up = north before rotation).
          final cone = Path()
            ..moveTo(c.dx, c.dy)
            ..lineTo(c.dx - s * 0.2, c.dy - s * 0.44)
            ..quadraticBezierTo(c.dx, c.dy - s * 0.52, c.dx + s * 0.2, c.dy - s * 0.44)
            ..close();
          canvas.drawPath(
            cone,
            Paint()
              ..shader = ui.Gradient.linear(
                c,
                Offset(c.dx, c.dy - s * 0.5),
                [
                  AppColors.route.withValues(alpha: 0.45),
                  AppColors.route.withValues(alpha: 0.0),
                ],
              ),
          );
          canvas.drawCircle(
              c, s * 0.3, Paint()..color = AppColors.route.withValues(alpha: 0.16));
          canvas.drawCircle(
            c,
            s * 0.19,
            Paint()
              ..color = Colors.black.withValues(alpha: 0.25)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03),
          );
          canvas.drawCircle(c, s * 0.18, Paint()..color = Colors.white);
          canvas.drawCircle(c, s * 0.13, Paint()..color = AppColors.route);
        });
      });

  // ── internals ────────────────────────────────────────────────────────────

  static final Map<String, Future<BitmapDescriptor>> _pending = {};

  static Future<BitmapDescriptor> _memo(
    String key,
    Future<BitmapDescriptor> Function() build,
  ) {
    final hit = _cache[key];
    if (hit != null) return Future.value(hit);
    return _pending.putIfAbsent(key, () async {
      final d = await build();
      _cache[key] = d;
      _pending.remove(key);
      return d;
    });
  }

  static Future<BitmapDescriptor> _draw(
    double logicalSize,
    void Function(Canvas canvas, double size) paint,
  ) async {
    final dpr = _dpr;
    final px = (logicalSize * dpr).roundToDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, px);
    final image =
        await recorder.endRecording().toImage(px.toInt(), px.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }

  static void _drawIcon(
      Canvas canvas, IconData icon, Offset center, double size, Color color) {
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      )
      ..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  /// Compass bearing in degrees from [a] to [b] (0 = north).
  static double bearing(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }
}
