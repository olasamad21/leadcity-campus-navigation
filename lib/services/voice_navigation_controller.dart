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

  /// Tracks which instruction indices have had their approach cue spoken
  /// ("In 40 metres, turn X" — fired between 35–45 m from the maneuver node).
  final Set<int> _announcedApproach = {};

  /// Tracks which instruction indices have had their "now" cue spoken
  /// ("Turn X now" — fired within 15 m of the maneuver node).
  final Set<int> _announcedNow = {};

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

  /// GPS tick: fire two-stage distance-based announcements for every unspoken
  /// instruction that contains 'left' or 'right'. Null instructions are skipped.
  ///
  /// Stage 1 (approach) — 35–45 m from maneuver node:
  ///   speaks "In 40 metres, turn left/right".
  /// Stage 2 (now)      — ≤15 m from maneuver node:
  ///   speaks "Turn left/right now".
  void onLocationUpdate(LatLng currentPosition) {
    for (var i = 0; i < _instructionTexts.length; i++) {
      final text = _instructionTexts[i];

      // Only fire for turn instructions.
      final lowerText = text.toLowerCase();
      if (!lowerText.contains('left') && !lowerText.contains('right')) continue;

      final anchor = _instructionAnchors[i];
      final distanceM = haversineDistanceMetersAnchor(currentPosition, anchor);

      // Stage 2 — within 15 m: speak "Turn X now".
      if (distanceM <= 15.0 && !_announcedNow.contains(i)) {
        _announcedNow.add(i);
        _announcedApproach.add(i); // ensure approach is also marked
        final direction = lowerText.contains('left') ? 'left' : 'right';
        unawaited(_voiceService.speak('Turn $direction now'));
        continue;
      }

      // Stage 1 — 35–45 m: speak "In 40 metres, turn X".
      if (distanceM >= 35.0 && distanceM <= 45.0 && !_announcedApproach.contains(i)) {
        _announcedApproach.add(i);
        final direction = lowerText.contains('left') ? 'left' : 'right';
        unawaited(_voiceService.speak('In 40 metres, turn $direction'));
      }
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
    _announcedApproach.clear();
    _announcedNow.clear();
    _hasAnnouncedArrival = false;
  }

  /// Index of the next instruction whose Stage 2 ("now") cue has not yet fired.
  /// Equals [_instructionTexts.length] when all have been spoken.
  int get nextInstructionIndex {
    for (var i = 0; i < _instructionTexts.length; i++) {
      if (!_announcedNow.contains(i)) return i;
    }
    return _instructionTexts.length;
  }

  /// Text of the next unspoken instruction (Stage 2 not yet fired), or null.
  String? get nextInstructionText {
    final idx = nextInstructionIndex;
    return idx < _instructionTexts.length ? _instructionTexts[idx] : null;
  }

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
