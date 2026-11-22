import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:leadcity_navigation/utils/camera_heading.dart';
import 'package:leadcity_navigation/utils/route_geometry.dart';

const _origin = LatLng(7.3200, 3.8800);

LatLng _at(double north, double east) => LatLng(
      _origin.latitude + north / 111320,
      _origin.longitude +
          east / (111320 * math.cos(_origin.latitude * math.pi / 180)),
    );

/// Polyline through [corners] with a vertex every ~10 m (like the survey).
RouteGeometry _route(List<(double, double)> corners) {
  final pts = <LatLng>[];
  for (var i = 0; i < corners.length - 1; i++) {
    final (n1, e1) = corners[i];
    final (n2, e2) = corners[i + 1];
    final len = math.sqrt(math.pow(n2 - n1, 2) + math.pow(e2 - e1, 2));
    final n = math.max(1, (len / 10).round());
    for (var k = 0; k < n; k++) {
      pts.add(_at(n1 + (n2 - n1) * k / n, e1 + (e2 - e1) * k / n));
    }
  }
  pts.add(_at(corners.last.$1, corners.last.$2));
  return RouteGeometry(pts);
}

/// Runs the smoother for [seconds] at 150 ms ticks.
void _run(CameraHeadingSmoother s, double seconds) {
  for (var t = 0.0; t < seconds; t += 0.15) {
    s.step(0.15);
  }
}

void main() {
  group('lookAheadBearing', () {
    final g = _route([(0, 0), (100, 0), (100, 100)]); // north, then east

    test('faces along a long straight', () {
      expect(lookAheadBearing(g, 20), closeTo(0, 1));
      expect(lookAheadBearing(g, 150), closeTo(90, 1));
    });

    test('starts turning as the corner comes into reach', () {
      final before = lookAheadBearing(g, 60); // corner 40 m away: not yet
      final near = lookAheadBearing(g, 90); // corner 10 m away: blending
      expect(before, closeTo(0, 1));
      expect(near, greaterThan(20));
      expect(near, lessThan(80));
    });

    test('two quick turns blend: no full swing to the short middle leg', () {
      // North 100 m, east only 12 m, then north again.
      final z = _route([(0, 0), (100, 0), (100, 12), (200, 12)]);
      var maxEast = 0.0;
      for (var d = 80.0; d <= 125; d += 1) {
        final b = lookAheadBearing(z, d);
        final signed = CameraHeadingSmoother.diff(b, 0);
        maxEast = math.max(maxEast, signed);
      }
      // A full swing would reach 90°; blended it stays well below that.
      expect(maxEast, lessThan(60));
    });
  });

  group('CameraHeadingSmoother', () {
    test('ignores small wiggles on a straight walk', () {
      final s = CameraHeadingSmoother()..reset(0);
      s.setTarget(6);
      _run(s, 2);
      expect(s.bearing, 0);
      s.setTarget(354);
      _run(s, 2);
      expect(s.bearing, 0);
    });

    test('rotates smoothly, never faster than the limit, then settles', () {
      final s = CameraHeadingSmoother()..reset(0);
      s.setTarget(90);
      var prev = s.bearing;
      var steps = 0;
      while (s.isRotating || steps == 0) {
        s.step(0.15);
        final moved = CameraHeadingSmoother.diff(s.bearing, prev).abs();
        expect(moved, lessThanOrEqualTo(60 * 0.15 + 1e-9));
        prev = s.bearing;
        if (++steps > 200) fail('never settled');
      }
      expect(s.bearing, 90);
      // A 90° turn takes about one and a half to three seconds.
      expect(steps * 0.15, inInclusiveRange(1.4, 3.5));
    });

    test('turns the short way round through north', () {
      final s = CameraHeadingSmoother()..reset(350);
      s.setTarget(20);
      s.step(0.15);
      // Moved clockwise past 350 toward 360/0, not back through 180.
      expect(CameraHeadingSmoother.diff(s.bearing, 350), greaterThan(0));
      _run(s, 4);
      expect(s.bearing, closeTo(20, 1e-9));
    });

    test('once rotating it finishes even below the dead band', () {
      final s = CameraHeadingSmoother()..reset(0);
      s.setTarget(30);
      _run(s, 6);
      expect(s.bearing, closeTo(30, 1e-9));
      expect(s.isRotating, isFalse);
    });
  });
}
