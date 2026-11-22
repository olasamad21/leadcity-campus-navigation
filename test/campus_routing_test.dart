import 'dart:math' show pi;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leadcity_navigation/data/campus_graph.dart';
import 'package:leadcity_navigation/services/campus_routing_service.dart';

/// Approximately offset [anchor] north by [northMeters] (spherical approximation).
LatLng offsetNorth(LatLng anchor, double northMeters) {
  const r = 6371000.0;
  final dLat = northMeters / r * (180 / pi);
  return LatLng(anchor.latitude + dLat, anchor.longitude);
}

/// Hand-crafted graphs (deterministic ids, isolated from campus production data).

/// Chain `n0 — n1 — n2 — n3 — n4` (10 m × 4) plus shortcut `n1 — n4` (80 m).
/// Shortest `n0 → n4` is the chain (`40 m`), not `n0→n1→n4`.
CampusGraph _routingGraphAlternate() {
  const p0 = LatLng(50.0, 9.0000);
  const p1 = LatLng(50.00009, 9.0000);
  const p2 = LatLng(50.00018, 9.0000);
  const p3 = LatLng(50.00027, 9.0000);
  const p4 = LatLng(50.00036, 9.0000);

  final nodes = {
    'n0': CampusNode(
      id: 'n0',
      position: p0,
      label: null,
      connectedNodeIds: ['n1'],
    ),
    'n1': CampusNode(
      id: 'n1',
      position: p1,
      label: null,
      connectedNodeIds: ['n0', 'n2', 'n4'],
    ),
    'n2': CampusNode(
      id: 'n2',
      position: p2,
      label: null,
      connectedNodeIds: ['n1', 'n3'],
    ),
    'n3': CampusNode(
      id: 'n3',
      position: p3,
      label: null,
      connectedNodeIds: ['n2', 'n4'],
    ),
    'n4': CampusNode(
      id: 'n4',
      position: p4,
      label: null,
      connectedNodeIds: ['n3', 'n1'],
    ),
    // Disconnected singleton
    'iso': CampusNode(
      id: 'iso',
      position: LatLng(40.0, 8.0),
      label: null,
      connectedNodeIds: [],
    ),
  };

  final edges = <CampusEdge>[
    const CampusEdge(fromId: 'n0', toId: 'n1', distanceMeters: 10),
    const CampusEdge(fromId: 'n1', toId: 'n2', distanceMeters: 10),
    const CampusEdge(fromId: 'n2', toId: 'n3', distanceMeters: 10),
    const CampusEdge(fromId: 'n3', toId: 'n4', distanceMeters: 10),
    const CampusEdge(fromId: 'n1', toId: 'n4', distanceMeters: 80),
  ];

  return CampusGraph(nodes: nodes, edges: edges);
}

/// Straight line `w0→w1→…→w5` with 40 m edges (total **200 m**) for ETA tests.
CampusGraph _wideChainGraph() {
  const lat = 48.0;
  double lngFor(int step) => 15.0000 + step * 0.0005;

  String nid(int i) => 'w$i';
  final nodes = <String, CampusNode>{};

  for (var i = 0; i <= 5; i++) {
    final prev = i > 0 ? nid(i - 1) : null;
    final next = i < 5 ? nid(i + 1) : null;
    final connected = <String>[
      if (prev != null) prev,
      if (next != null) next,
    ];
    nodes[nid(i)] = CampusNode(
      id: nid(i),
      position: LatLng(lat, lngFor(i)),
      label: null,
      connectedNodeIds: connected,
    );
  }

  final edges = <CampusEdge>[];
  for (var i = 0; i < 5; i++) {
    edges.add(
      CampusEdge(
        fromId: nid(i),
        toId: nid(i + 1),
        distanceMeters: 40,
        voiceInstruction: i.isEven ? 'Walk $i' : null,
      ),
    );
  }

  return CampusGraph(nodes: nodes, edges: edges);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CampusRoutingService + CampusGraph', () {
    late CampusGraph routing;

    setUp(() {
      routing = _routingGraphAlternate();
    });

    test('findPath: shortest route over multiple hops beats longer shortcut', () {
      final svc = CampusRoutingService(routing);

      expect(
        svc.findPath('n0', 'n4'),
        ['n0', 'n1', 'n2', 'n3', 'n4'],
      );
    });

    test('findPath: direct single edge between neighbours', () {
      final svc = CampusRoutingService(routing);

      expect(svc.findPath('n2', 'n3'), ['n2', 'n3']);
    });

    test('findPath: null when destination unreachable (disconnected)', () {
      final svc = CampusRoutingService(routing);

      expect(svc.findPath('n0', 'iso'), isNull);
      expect(svc.findPath('iso', 'iso'), ['iso']);
    });

    test('findPath: start == end returns single-node path', () {
      final svc = CampusRoutingService(routing);

      expect(svc.findPath('n2', 'n2'), ['n2']);
    });

    test('getNearestNodeId snaps to uniquely closest node', () {
      expect(
        routing.getNearestNodeId(LatLng(50.00029, 9.0000)),
        'n3',
      );

      expect(
        routing.getNearestNodeId(LatLng(40.0000, 8.0000)),
        'iso',
      );
    });

    test('calculateRoute ETA uses 80 m/min pacing (ceil of total metres)', () {
      final graph = _wideChainGraph();
      final svc = CampusRoutingService(graph);

      final w0 = graph.nodes['w0']!.position;
      final w5 = graph.nodes['w5']!.position;

      final route = svc.calculateRoute(w0, w5);
      expect(route, isNotNull);
      expect(route!.totalDistanceMeters, closeTo(200.0, 0.001));
      // ceil(200 / 80 = 2.5) = 3
      expect(route.estimatedWalkingMinutes, 3);
    });

    test('calculateRoute snapping uses graph nodes nearest to origins', () {
      final svc = CampusRoutingService(routing);

      final origin = routing.nodes['n0']!.position;
      final dest = routing.nodes['iso']!.position;

      expect(svc.calculateRoute(origin, dest), isNull);
    });
  });
}
