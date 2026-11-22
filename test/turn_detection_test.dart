import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:leadcity_navigation/data/campus_graph.dart';
import 'package:leadcity_navigation/services/campus_routing_service.dart';
import 'package:leadcity_navigation/services/voice_navigation_controller.dart';
import 'package:leadcity_navigation/services/voice_service.dart';
import 'package:leadcity_navigation/utils/route_geometry.dart';

const _origin = LatLng(7.3200, 3.8800);

/// Point [north]/[east] metres from [_origin].
LatLng _at(double north, double east) => LatLng(
      _origin.latitude + north / 111320,
      _origin.longitude +
          east / (111320 * math.cos(_origin.latitude * math.pi / 180)),
    );

/// Densified polyline (a vertex every ~10 m, like the survey trace).
List<LatLng> _path(List<(double, double)> corners) {
  final out = <LatLng>[];
  for (var i = 0; i < corners.length - 1; i++) {
    final (n1, e1) = corners[i];
    final (n2, e2) = corners[i + 1];
    final len = math.sqrt(math.pow(n2 - n1, 2) + math.pow(e2 - e1, 2));
    final n = math.max(1, (len / 10).round());
    for (var k = 0; k < n; k++) {
      out.add(_at(n1 + (n2 - n1) * k / n, e1 + (e2 - e1) * k / n));
    }
  }
  final (nl, el) = corners.last;
  out.add(_at(nl, el));
  return out;
}

List<TurnStep> _turns(List<(double, double)> corners) =>
    detectTurns(RouteGeometry(_path(corners)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('detectTurns', () {
    test('north then west is a left turn at the corner', () {
      final t = _turns([(0, 0), (60, 0), (60, -60)]);
      expect(t, hasLength(1));
      expect(t.single.instruction, 'Turn left');
      expect(t.single.alongMeters, closeTo(60, 3));
    });

    test('the same corner walked the other way is a right turn', () {
      final t = _turns([(60, -60), (60, 0), (0, 0)]);
      expect(t, hasLength(1));
      expect(t.single.instruction, 'Turn right');
      expect(t.single.alongMeters, closeTo(60, 3));
    });

    test('north then east is a right turn; reversed it is left', () {
      expect(_turns([(0, 0), (50, 0), (50, 50)]).single.instruction,
          'Turn right');
      expect(_turns([(50, 50), (50, 0), (0, 0)]).single.instruction,
          'Turn left');
    });

    test('straight paths and gentle bends produce no turn', () {
      expect(_turns([(0, 0), (100, 0)]), isEmpty);
      expect(_turns([(0, 0), (50, 0), (100, 8)]), isEmpty); // ~9°
      expect(_turns([(0, 0), (50, 0), (95, 18)]), isEmpty); // ~22°, a curve
    });

    test('slight and sharp bends are labelled as such', () {
      expect(_turns([(0, 0), (50, 0), (90, 33)]).single.instruction,
          'Slight right'); // ~40°
      expect(_turns([(0, 0), (50, 0), (10, -20)]).single.instruction,
          'Sharp left'); // ~153°
    });

    test('a small left-right wobble is ignored', () {
      final t = _turns([(0, 0), (40, 0), (48, -4), (56, 0), (100, 0)]);
      expect(t, isEmpty);
    });

    test('two real corners are both found, in order', () {
      final t = _turns([(0, 0), (50, 0), (50, 50), (100, 50)]);
      expect(t.map((s) => s.instruction), ['Turn right', 'Turn left']);
      expect(t[0].alongMeters, lessThan(t[1].alongMeters));
    });
  });

  group('against the survey labels on the real campus graph', () {
    // Each stored label on edge (from -> to) describes the corner at `from`
    // when walking the survey trace prev -> from -> to. Node ids follow the
    // trace, so prev = id - 1. Build a short trace window around each corner
    // and check the detector agrees forwards and flips when walked backwards.
    String id(int i) => 'node_${i.toString().padLeft(3, '0')}';
    int idx(String s) => int.parse(s.substring(5));
    final g = campusGraph;
    final labelled = g.edges
        .where((e) =>
            CampusGraph.isTurnInstruction(e.voiceInstruction) &&
            idx(e.toId) == idx(e.fromId) + 1)
        .toList();

    List<LatLng>? window(int centre) {
      final pts = <LatLng>[];
      for (var i = centre - 3; i <= centre + 3; i++) {
        final n = g.nodes[id(i)];
        if (n == null) return null;
        if (pts.isNotEmpty) {
          // Must be consecutive trace nodes joined by an edge.
          final prev = id(i - 1);
          if (!g.getNeighbours(prev).any((x) => x.id == id(i))) return null;
        }
        pts.add(n.position);
      }
      return pts;
    }

    TurnStep? nearest(List<TurnStep> steps, double along) {
      TurnStep? best;
      for (final s in steps) {
        if ((s.alongMeters - along).abs() > 15) continue;
        if (best == null ||
            (s.alongMeters - along).abs() < (best.alongMeters - along).abs()) {
          best = s;
        }
      }
      return best;
    }

    test('detected direction matches labels, and flips when reversed', () {
      var checked = 0, forwardOk = 0, reverseOk = 0;
      for (final e in labelled) {
        final pts = window(idx(e.fromId));
        if (pts == null) continue;
        final fwd = RouteGeometry(pts);
        final corner = fwd.project(g.nodes[e.fromId]!.position).alongMeters;
        final f = nearest(detectTurns(fwd), corner);
        final rev = RouteGeometry(pts.reversed.toList());
        final r = nearest(detectTurns(rev), rev.length - corner);
        if (f == null && r == null) continue; // very gentle at this scale
        checked++;
        final wantLeft = e.voiceInstruction!.toLowerCase().contains('left');
        if (f != null && f.isLeft == wantLeft) forwardOk++;
        if (r != null && r.isLeft == !wantLeft) reverseOk++;
      }
      // ignore: avoid_print
      print('survey labels checked: $checked, forward agree: $forwardOk, '
          'reverse flips: $reverseOk');
      expect(checked, greaterThan(50));
      expect(forwardOk / checked, greaterThan(0.95));
      expect(reverseOk / checked, greaterThan(0.95));
    });

    test('routes carry shape-based instructions', () {
      final svc = CampusRoutingService(g);
      final a = g.nodes['node_010']!.position;
      final b = g.nodes['node_200']!.position;
      final route = svc.calculateRoute(a, b)!;
      final expected = detectTurns(RouteGeometry(route.polylinePoints))
          .map((s) => s.instruction)
          .toList();
      expect(route.instructions, expected);
    });
  });

  group('VoiceNavigationController (progress based)', () {
    CampusRoute route(List<(double, double)> corners) {
      final pts = _path(corners);
      return CampusRoute(
        polylinePoints: pts,
        instructions: const [],
        totalDistanceMeters: RouteGeometry(pts).length,
        estimatedWalkingMinutes: 1,
        nodeIds: const [],
      );
    }

    test('advances only when the corner is reached along the route', () {
      final vc = VoiceNavigationController(
        route([(0, 0), (100, 0), (100, -60), (160, -60)]),
        VoiceService(),
      );
      expect(vc.steps.map((s) => s.instruction), ['Turn left', 'Turn right']);

      vc.onProgress(40); // 60 m before the first corner
      expect(vc.nextInstructionIndex, 0);
      vc.onProgress(88); // 12 m before: "Turn left now"
      expect(vc.nextInstructionIndex, 1);
      expect(vc.nextInstructionText, 'Turn right');

      for (var i = 0; i < 10; i++) {
        vc.onProgress(90); // never repeats or skips ahead
      }
      expect(vc.nextInstructionIndex, 1);
    });

    test('corners skipped by a GPS jump are dropped silently', () {
      final vc = VoiceNavigationController(
        route([(0, 0), (100, 0), (100, -60), (160, -60)]),
        VoiceService(),
      );
      vc.onProgress(140); // past the first corner by 40 m
      expect(vc.nextInstructionIndex, 1);
    });

    test('phrases', () {
      final s = _turns([(0, 0), (60, 0), (60, -60)]).single;
      expect(VoiceNavigationController.nowPhrase(s), 'Turn left now');
      expect(VoiceNavigationController.approachPhrase(s, 41),
          'In 40 metres, turn left');
      final slight = _turns([(0, 0), (50, 0), (90, 33)]).single;
      expect(VoiceNavigationController.nowPhrase(slight),
          'Keep slightly right now');
    });

    test('a close first corner is mentioned at the start', () {
      final vc = VoiceNavigationController(
        route([(0, 0), (30, 0), (30, -60)]),
        VoiceService(),
      );
      expect(vc.firstTurnHint(), 'In 30 metres, turn left.');
    });

    test('arrival within 15 m', () {
      final vc = VoiceNavigationController(route([(0, 0), (50, 0)]), VoiceService());
      expect(vc.checkArrival(_at(0, 10), _at(0, 0)), isTrue);
      expect(vc.checkArrival(_at(0, 30), _at(0, 0)), isFalse);
    });
  });
}
