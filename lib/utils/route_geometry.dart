import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/campus_graph.dart';
import 'map_markers.dart';

/// Distance-along-route maths for a walking polyline.
class RouteGeometry {
  RouteGeometry(List<LatLng> points)
      : points = List.unmodifiable(points),
        _cum = _cumulative(points);

  final List<LatLng> points;

  /// Cumulative distance (m) at each vertex; `_cum.last` = total length.
  final List<double> _cum;

  double get length => _cum.isEmpty ? 0 : _cum.last;

  static List<double> _cumulative(List<LatLng> pts) {
    final out = <double>[];
    var total = 0.0;
    for (var i = 0; i < pts.length; i++) {
      if (i > 0) total += distance(pts[i - 1], pts[i]);
      out.add(total);
    }
    return out;
  }

  /// Point at [d] metres along the route (clamped to the ends).
  LatLng pointAt(double d) {
    if (points.isEmpty) return const LatLng(0, 0);
    if (d <= 0) return points.first;
    if (d >= length) return points.last;
    final i = _segmentIndex(d);
    final segLen = _cum[i + 1] - _cum[i];
    final t = segLen <= 0 ? 0.0 : (d - _cum[i]) / segLen;
    return _lerp(points[i], points[i + 1], t);
  }

  /// Walking direction (compass degrees) at [d] metres along the route.
  double bearingAt(double d) {
    if (points.length < 2) return 0;
    final i = _segmentIndex(d.clamp(0, length));
    return MapMarkers.bearing(points[i], points[i + 1]);
  }

  /// Route from the start up to [d] metres.
  List<LatLng> sliceTo(double d) {
    if (points.length < 2 || d <= 0) {
      return points.isEmpty ? const [] : [points.first];
    }
    if (d >= length) return points;
    final i = _segmentIndex(d);
    return [...points.sublist(0, i + 1), pointAt(d)];
  }

  /// Route from [d] metres to the end.
  List<LatLng> sliceFrom(double d) {
    if (points.length < 2 || d <= 0) return points;
    if (d >= length) return [points.last];
    final i = _segmentIndex(d);
    return [pointAt(d), ...points.sublist(i + 1)];
  }

  /// Closest point on the route to [p].
  ///
  /// [minAlong] ignores segments that end before that distance, so progress
  /// does not jump backwards where the path doubles back on itself.
  RouteProjection project(LatLng p, {double minAlong = 0}) {
    if (points.length < 2) {
      final only = points.isEmpty ? p : points.first;
      return RouteProjection(only, 0, distance(p, only));
    }
    RouteProjection? best;
    for (var i = 0; i < points.length - 1; i++) {
      if (_cum[i + 1] < minAlong) continue;
      final a = points[i], b = points[i + 1];
      final k = math.cos((a.latitude + b.latitude) * 0.5 * math.pi / 180);
      final ax = a.longitude * k, ay = a.latitude;
      final dx = b.longitude * k - ax, dy = b.latitude - ay;
      final lenSq = dx * dx + dy * dy;
      var t = lenSq < 1e-18
          ? 0.0
          : ((p.longitude * k - ax) * dx + (p.latitude - ay) * dy) / lenSq;
      t = t.clamp(0.0, 1.0);
      final q = _lerp(a, b, t);
      final off = distance(p, q);
      if (best == null || off < best.offsetMeters) {
        best = RouteProjection(q, _cum[i] + (_cum[i + 1] - _cum[i]) * t, off);
      }
    }
    return best ?? RouteProjection(points.last, length, distance(p, points.last));
  }

  int _segmentIndex(double d) {
    var lo = 0, hi = _cum.length - 2;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_cum[mid] <= d) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  static LatLng _lerp(LatLng a, LatLng b, double t) => LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );

  /// Haversine distance in metres.
  static double distance(LatLng a, LatLng b) {
    const r = 6371000.0;
    final p1 = a.latitude * math.pi / 180, p2 = b.latitude * math.pi / 180;
    final dp = p2 - p1;
    final dl = (b.longitude - a.longitude) * math.pi / 180;
    final h = math.sin(dp / 2) * math.sin(dp / 2) +
        math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
    return 2 * r * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  /// Bounds around every point, for fitting the camera.
  LatLngBounds bounds() {
    var minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    if ((maxLat - minLat).abs() < 1e-5 && (maxLng - minLng).abs() < 1e-5) {
      minLat -= 3e-4;
      maxLat += 3e-4;
      minLng -= 3e-4;
      maxLng += 3e-4;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class RouteProjection {
  const RouteProjection(this.point, this.alongMeters, this.offsetMeters);

  /// Closest point on the route.
  final LatLng point;

  /// Distance from the route start to [point].
  final double alongMeters;

  /// Distance from the query position to [point].
  final double offsetMeters;
}

/// One spoken manoeuvre on a route, positioned along the polyline.
class TurnStep {
  const TurnStep(this.instruction, this.position, this.alongMeters);

  final String instruction;
  final LatLng position;
  final double alongMeters;

  bool get isLeft => instruction.toLowerCase().contains('left');
  bool get isRight => instruction.toLowerCase().contains('right');

  IconData get icon => isLeft
      ? Icons.turn_left_rounded
      : isRight
          ? Icons.turn_right_rounded
          : Icons.straight_rounded;
}

/// Turn steps for [route], aligned one-to-one with [CampusRoute.instructions]
/// (same filter as the voice controller: the manoeuvre is at the far node of
/// each turn edge).
List<TurnStep> turnStepsFor(
  CampusRoute route,
  RouteGeometry geometry, {
  CampusGraph? graph,
}) {
  final g = graph ?? campusGraph;
  final steps = <TurnStep>[];
  final ids = route.nodeIds;
  var minAlong = 0.0;
  for (var k = 0; k < ids.length - 1; k++) {
    final text = g.getEdgeInstruction(ids[k], ids[k + 1]);
    if (!CampusGraph.isTurnInstruction(text)) continue;
    final node = g.nodes[ids[k + 1]];
    if (node == null) continue;
    final proj = geometry.project(node.position, minAlong: minAlong);
    minAlong = proj.alongMeters;
    steps.add(TurnStep(text!, node.position, proj.alongMeters));
  }
  return steps;
}
