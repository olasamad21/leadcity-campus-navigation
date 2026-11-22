import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/campus_graph.dart';
import '../utils/route_geometry.dart';

/// On-graph routing over [CampusGraph] edges (pre-measured walkway segments).
///
/// [CampusRoute] is declared next to [CampusGraph] in `campus_graph.dart`.
class CampusRoutingService {
  CampusRoutingService(this._graph);

  final CampusGraph _graph;

  /// Graph used for routing (same instance [calculateRoute] uses).
  CampusGraph get graph => _graph;

  /// Dijkstra shortest path; edge weights are [CampusEdge.distanceMeters].
  ///
  /// Uses the graph's prebuilt [CampusGraph.adjacency] and a binary-heap
  /// frontier, so each step is O(log V) instead of re-sorting every node.
  List<String>? findPath(String startNodeId, String endNodeId) {
    if (!_graph.nodes.containsKey(startNodeId) ||
        !_graph.nodes.containsKey(endNodeId)) {
      return null;
    }
    if (startNodeId == endNodeId) {
      return [startNodeId];
    }

    final dist = <String, double>{startNodeId: 0};
    final prev = <String, String>{};
    final done = <String>{};
    final frontier = _MinHeap()..push(0, startNodeId);
    final adjacency = _graph.adjacency;

    while (frontier.isNotEmpty) {
      final (d, u) = frontier.pop();
      if (!done.add(u)) continue; // stale heap entry
      if (u == endNodeId) break;
      for (final (v, w) in adjacency[u] ?? const <(String, double)>[]) {
        final alt = d + w;
        if (alt < (dist[v] ?? double.infinity)) {
          dist[v] = alt;
          prev[v] = u;
          frontier.push(alt, v);
        }
      }
    }

    if (!dist.containsKey(endNodeId)) {
      return null;
    }

    return _buildPath(prev, startNodeId, endNodeId);
  }

  /// Snaps endpoints to nearest nodes, then runs [findPath].
  CampusRoute? calculateRoute(LatLng origin, LatLng destination) {
    final start = _graph.getNearestNodeId(origin);
    final end = _graph.getNearestNodeId(destination);

    final path = findPath(start, end);
    if (path == null) return null;

    final polylinePoints = _graph.getRouteCoordinates(path);
    // Turns come from the shape of this path, so they are correct in either
    // walking direction and sit on the real corner.
    final instructions = detectTurns(RouteGeometry(polylinePoints))
        .map((s) => s.instruction)
        .toList();
    final totalDistanceMeters = _pathTotalDistance(path);

    final walkingMetersPerMinute = 80.0;
    final estimatedWalkingMinutes = totalDistanceMeters <= 0
        ? 0
        : (totalDistanceMeters / walkingMetersPerMinute).ceil();

    return CampusRoute(
      polylinePoints: polylinePoints,
      instructions: instructions,
      totalDistanceMeters: totalDistanceMeters,
      estimatedWalkingMinutes: estimatedWalkingMinutes,
      nodeIds: path,
    );
  }

  double _pathTotalDistance(List<String> nodeIds) {
    if (nodeIds.length < 2) return 0;
    var sum = 0.0;
    for (var i = 0; i < nodeIds.length - 1; i++) {
      sum += _graph.getEdgeDistance(nodeIds[i], nodeIds[i + 1]);
    }
    return sum;
  }

  static List<String>? _buildPath(
    Map<String, String> prev,
    String start,
    String end,
  ) {
    final reversed = <String>[end];
    var cur = end;
    while (cur != start) {
      final p = prev[cur];
      if (p == null) return null;
      reversed.add(p);
      cur = p;
    }
    return reversed.reversed.toList();
  }
}

/// Minimal binary min-heap of (distance, nodeId) for Dijkstra.
class _MinHeap {
  final List<(double, String)> _items = [];

  bool get isNotEmpty => _items.isNotEmpty;

  void push(double priority, String id) {
    _items.add((priority, id));
    var i = _items.length - 1;
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_items[parent].$1 <= _items[i].$1) break;
      final tmp = _items[parent];
      _items[parent] = _items[i];
      _items[i] = tmp;
      i = parent;
    }
  }

  (double, String) pop() {
    final top = _items.first;
    final last = _items.removeLast();
    if (_items.isNotEmpty) {
      _items[0] = last;
      var i = 0;
      while (true) {
        final l = 2 * i + 1, r = l + 1;
        var smallest = i;
        if (l < _items.length && _items[l].$1 < _items[smallest].$1) {
          smallest = l;
        }
        if (r < _items.length && _items[r].$1 < _items[smallest].$1) {
          smallest = r;
        }
        if (smallest == i) break;
        final tmp = _items[smallest];
        _items[smallest] = _items[i];
        _items[i] = tmp;
        i = smallest;
      }
    }
    return top;
  }
}
