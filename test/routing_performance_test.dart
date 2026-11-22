import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:leadcity_navigation/data/campus_graph.dart';
import 'package:leadcity_navigation/services/campus_routing_service.dart';

/// Route-finding speed on the full 434-node campus graph.
void main() {
  test('random campus routes are fast', () {
    final svc = CampusRoutingService(campusGraph);
    final ids = campusGraph.nodes.keys.toList();
    final rnd = math.Random(7);
    final pairs = List.generate(
      300,
      (_) => (ids[rnd.nextInt(ids.length)], ids[rnd.nextInt(ids.length)]),
    );

    // Warm-up (JIT + any lazy indexes).
    for (final (a, b) in pairs.take(10)) {
      svc.findPath(a, b);
    }

    final sw = Stopwatch()..start();
    var found = 0;
    for (final (a, b) in pairs) {
      if (svc.findPath(a, b) != null) found++;
    }
    sw.stop();
    final avgMs = sw.elapsedMicroseconds / pairs.length / 1000;
    // ignore: avoid_print
    print('routes: ${pairs.length}, found: $found, '
        'average ${avgMs.toStringAsFixed(2)} ms per route');

    expect(found, greaterThan(pairs.length * 0.9));
    expect(avgMs, lessThan(5)); // generous budget for slow CI machines
  });

  test('fast routing finds exactly the shortest distance (vs reference)', () {
    final g = campusGraph;
    final svc = CampusRoutingService(g);
    final ids = g.nodes.keys.toList();
    final rnd = math.Random(11);

    double total(List<String> p) {
      var s = 0.0;
      for (var i = 0; i < p.length - 1; i++) {
        s += g.getEdgeDistance(p[i], p[i + 1]);
      }
      return s;
    }

    // Plain O(V^2) Dijkstra over every node, as the reference answer.
    double? reference(String a, String b) {
      final dist = {for (final id in ids) id: double.infinity};
      final done = <String>{};
      dist[a] = 0;
      while (true) {
        String? u;
        for (final id in ids) {
          if (!done.contains(id) &&
              dist[id]!.isFinite &&
              (u == null || dist[id]! < dist[u]!)) {
            u = id;
          }
        }
        if (u == null) return null;
        if (u == b) return dist[b];
        done.add(u);
        for (final (v, w) in g.adjacency[u]!) {
          if (dist[u]! + w < dist[v]!) dist[v] = dist[u]! + w;
        }
      }
    }

    for (var k = 0; k < 300; k++) {
      final a = ids[rnd.nextInt(ids.length)], b = ids[rnd.nextInt(ids.length)];
      final fast = svc.findPath(a, b);
      final ref = reference(a, b);
      if (ref == null) {
        expect(fast, isNull);
        continue;
      }
      expect(fast, isNotNull);
      expect(fast!.first, a);
      expect(fast.last, b);
      expect(total(fast), closeTo(ref, 1e-6), reason: '$a -> $b');
    }
  });
}
