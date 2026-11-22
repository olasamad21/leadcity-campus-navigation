import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:leadcity_navigation/data/campus_graph.dart';
import 'package:leadcity_navigation/utils/route_geometry.dart';

/// ~111 m per 0.001° of latitude.
const _a = LatLng(7.3200, 3.8800);
const _b = LatLng(7.3210, 3.8800); // ~111 m north of a
const _c = LatLng(7.3210, 3.8810); // ~110 m east of b

void main() {
  final g = RouteGeometry([_a, _b, _c]);

  test('length sums segment distances', () {
    expect(g.length, closeTo(221, 2));
  });

  test('pointAt interpolates and clamps', () {
    expect(g.pointAt(-5), _a);
    expect(g.pointAt(9999), _c);
    final mid = g.pointAt(g.length / 4);
    expect(mid.latitude, closeTo(7.3205, 0.0001));
    expect(mid.longitude, closeTo(3.8800, 1e-9));
  });

  test('slices split the route at the given distance', () {
    final d = 150.0;
    final walked = g.sliceTo(d);
    final ahead = g.sliceFrom(d);
    expect(walked.first, _a);
    expect(ahead.last, _c);
    expect(walked.last, ahead.first);
    expect(RouteGeometry(walked).length, closeTo(d, 0.5));
    expect(RouteGeometry(ahead).length, closeTo(g.length - d, 0.5));
  });

  test('project snaps a nearby point and reports progress', () {
    // 10 m east of the midpoint of the first leg.
    const p = LatLng(7.3205, 3.88009);
    final proj = g.project(p);
    expect(proj.offsetMeters, closeTo(10, 1));
    expect(proj.alongMeters, closeTo(55.5, 1.5));
  });

  test('bearingAt points along each leg', () {
    expect(g.bearingAt(10), closeTo(0, 1)); // north
    expect(g.bearingAt(200), closeTo(90, 1)); // east
  });

  test('turnStepsFor finds the corner from the shape', () {
    final route = CampusRoute(
      polylinePoints: const [_a, _b, _c],
      instructions: const [],
      totalDistanceMeters: 221,
      estimatedWalkingMinutes: 3,
      nodeIds: const ['a', 'b', 'c'],
    );
    final steps = turnStepsFor(route, g);
    expect(steps, hasLength(1));
    expect(steps.single.isRight, isTrue); // north, then east
    expect(steps.single.alongMeters, closeTo(111, 2)); // at b, the corner
  });
}
