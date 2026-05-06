import 'dart:async';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/campus_graph.dart';
import 'voice_service.dart';

/// Proximity-triggered voice guidance along a solved [CampusRoute].
///
/// Uses [VoiceService] for TTS only; does not implement speech itself.
class VoiceNavigationController {
  VoiceNavigationController(
    this._route,
    this._voiceService, {
    CampusGraph? campusGraphOverride,
  }) : _campusGraph = campusGraphOverride ?? campusGraph {
    final raw = _rawAnchorsFromGraph(_route, _campusGraph);
    final n = math.min(raw.length, _route.instructions.length);
    assert(() {
      if (raw.length != _route.instructions.length) {
        // ignore: avoid_print
        print(
          'VoiceNavigationController: anchor count (${raw.length}) '
          '!= instructions (${_route.instructions.length}); '
          'using first $n paired steps.',
        );
      }
      return true;
    }());
    _instructionAnchors = raw.sublist(0, n);
    _instructionTexts = _route.instructions.sublist(0, n);
  }

  final CampusRoute _route;
  final VoiceService _voiceService;
  final CampusGraph _campusGraph;

  /// Maneuver point per paired instruction (aligned with [_instructionTexts]).
  late final List<LatLng> _instructionAnchors;

  /// Subset of [_route.instructions] aligned with anchors (same length).
  late final List<String> _instructionTexts;

  /// Next index into [_instructionTexts] / [_instructionAnchors].
  int _nextSpeakIndex = 0;

  bool _hasAnnouncedArrival = false;

  /// LatLng at the destination node for each voiced graph edge along [route].
  static List<LatLng> _rawAnchorsFromGraph(CampusRoute route, CampusGraph graph) {
    final anchors = <LatLng>[];
    final ids = route.nodeIds;
    for (var k = 0; k < ids.length - 1; k++) {
      final spoken = graph.getEdgeInstruction(ids[k], ids[k + 1]);
      if (spoken == null || spoken.trim().isEmpty) continue;
      final node = graph.nodes[ids[k + 1]];
      if (node != null) {
        anchors.add(node.position);
      }
    }
    return anchors;
  }

  /// GPS tick: announce the next unspoken maneuver when within 20 m of its node.
  void onLocationUpdate(LatLng currentPosition) {
    if (_nextSpeakIndex >= _instructionTexts.length) return;

    final anchor = _instructionAnchors[_nextSpeakIndex];
    final distanceM =
        haversineDistanceMetersAnchor(currentPosition, anchor);

    if (distanceM < 20.0) {
      unawaited(_voiceService.speak(_instructionTexts[_nextSpeakIndex]));
      _nextSpeakIndex++;
    }
  }

  /// True when within 15 m of [destination]; speaks arrival once when it first becomes true.
  bool checkArrival(LatLng currentPosition, LatLng destination) {
    final distanceM =
        haversineDistanceMetersAnchor(currentPosition, destination);
    final arrived = distanceM <= 15.0;
    if (arrived && !_hasAnnouncedArrival) {
      _hasAnnouncedArrival = true;
      unawaited(
        _voiceService.speak('You have arrived at your destination.'),
      );
    }
    return arrived;
  }

  void reset() {
    _nextSpeakIndex = 0;
    _hasAnnouncedArrival = false;
  }

  /// Index of the next unspoken instruction in [CampusRoute.instructions]
  /// (same as index into the paired steps built at construction; equals paired
  /// count when all have been spoken).
  int get nextInstructionIndex => _nextSpeakIndex >= _instructionTexts.length
      ? _instructionTexts.length
      : _nextSpeakIndex;

  /// Text of the upcoming instruction, or null if none left.
  String? get nextInstructionText =>
      _nextSpeakIndex >= _instructionTexts.length
          ? null
          : _instructionTexts[_nextSpeakIndex];

  /// Haversine distance in metres (pure Dart via `dart:math`).
  static double haversineDistanceMetersAnchor(LatLng a, LatLng b) {
    const earthRadiusMeters = 6371000.0;
    final phi1 = a.latitude * math.pi / 180.0;
    final phi2 = b.latitude * math.pi / 180.0;
    final dPhi = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLambda = (b.longitude - a.longitude) * math.pi / 180.0;
    final sinDPhi = math.sin(dPhi / 2.0);
    final sinDLambda = math.sin(dLambda / 2.0);
    final h = sinDPhi * sinDPhi +
        math.cos(phi1) * math.cos(phi2) * sinDLambda * sinDLambda;
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt((1 - h).clamp(0.0, 1.0)));
    return earthRadiusMeters * c;
  }
}
