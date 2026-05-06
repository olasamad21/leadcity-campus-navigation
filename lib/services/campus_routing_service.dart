import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/campus_graph.dart';

/// On-graph routing over [CampusGraph] edges (pre-measured walkway segments).
///
/// [CampusRoute] is declared next to [CampusGraph] in `campus_graph.dart`.
class CampusRoutingService {
  CampusRoutingService(this._graph);

  final CampusGraph _graph;

  /// Graph used for routing (same instance [calculateRoute] uses).
  CampusGraph get graph => _graph;

  /// Dijkstra shortest paths; edge weights are [CampusEdge.distanceMeters].
  /// Frontier: unvisited nodes, sorted ascending by tentative distance each step.
  List<String>? findPath(String startNodeId, String endNodeId) {
    if (!_graph.nodes.containsKey(startNodeId) ||
        !_graph.nodes.containsKey(endNodeId)) {
      return null;
    }
    if (startNodeId == endNodeId) {
      return [startNodeId];
    }

    final dist = <String, double>{
      for (final id in _graph.nodes.keys) id: double.infinity,
    };
    final prev = <String, String>{};
    final visited = <String>{};

    dist[startNodeId] = 0;

    while (visited.length < _graph.nodes.length) {
      final unvisitedIds =
          _graph.nodes.keys.where((id) => !visited.contains(id)).toList();

      unvisitedIds.sort((a, b) => dist[a]!.compareTo(dist[b]!));

      String? u;
      for (final id in unvisitedIds) {
        if (dist[id]!.isFinite) {
          u = id;
          break;
        }
      }
      if (u == null) break;

      visited.add(u);

      if (u == endNodeId) {
        break;
      }

      for (final neighbour in _graph.getNeighbours(u)) {
        final nid = neighbour.id;
        final w = _graph.getEdgeDistance(u, nid);
        if (!w.isFinite) continue;

        final alt = dist[u]! + w;
        if (alt < dist[nid]!) {
          dist[nid] = alt;
          prev[nid] = u;
        }
      }
    }

    if (dist[endNodeId] == double.infinity) {
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
    final instructions = _graph.getRouteInstructions(path);
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
