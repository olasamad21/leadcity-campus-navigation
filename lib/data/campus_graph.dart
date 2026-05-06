import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

// ============================================================
// CAMPUS GRAPH — Lead City University Navigation
// ============================================================
// AUTO-GENERATED from GPX — 40 junction connections added: May 5, 2026 11:31:14 AM
// 164 nodes | 163 edges | 3625m total | ~20.0m spacing
// ============================================================

class CampusNode {
  final String id;
  final LatLng position;
  final String? label;
  final List<String> connectedNodeIds;

  const CampusNode({
    required this.id,
    required this.position,
    this.label,
    required this.connectedNodeIds,
  });
}

class CampusEdge {
  final String fromId;
  final String toId;
  final double distanceMeters;
  final String? voiceInstruction;

  const CampusEdge({
    required this.fromId,
    required this.toId,
    required this.distanceMeters,
    this.voiceInstruction,
  });
}

class CampusRoute {
  final List<LatLng> polylinePoints;
  final List<String> instructions;
  final double totalDistanceMeters;
  final int estimatedWalkingMinutes;
  final List<String> nodeIds;

  const CampusRoute({
    required this.polylinePoints,
    required this.instructions,
    required this.totalDistanceMeters,
    required this.estimatedWalkingMinutes,
    required this.nodeIds,
  });
}

class CampusGraph {
  final Map<String, CampusNode> nodes;
  final List<CampusEdge> edges;

  CampusGraph({required this.nodes, required this.edges});

  List<CampusNode> getNeighbours(String nodeId) {
    final node = nodes[nodeId];
    if (node == null) return [];
    return node.connectedNodeIds
        .map((id) => nodes[id])
        .whereType<CampusNode>()
        .toList();
  }

  double getEdgeDistance(String fromId, String toId) {
    for (final edge in edges) {
      if ((edge.fromId == fromId && edge.toId == toId) ||
          (edge.fromId == toId && edge.toId == fromId)) {
        return edge.distanceMeters;
      }
    }
    return double.infinity;
  }

  String? getEdgeInstruction(String fromId, String toId) {
    for (final edge in edges) {
      if (edge.fromId == fromId && edge.toId == toId) return edge.voiceInstruction;
      if (edge.fromId == toId && edge.toId == fromId) return edge.voiceInstruction;
    }
    return null;
  }

  String getNearestNodeId(LatLng position) {
    if (nodes.isEmpty) throw StateError('getNearestNodeId: graph has no nodes');
    String? nearestId;
    double nearestDist = double.infinity;
    for (final entry in nodes.entries) {
      final d = _haversineDistanceMeters(
        position.latitude, position.longitude,
        entry.value.position.latitude, entry.value.position.longitude,
      );
      if (d < nearestDist) {
        nearestDist = d;
        nearestId = entry.key;
      }
    }
    return nearestId!;
  }

  List<LatLng> getRouteCoordinates(List<String> nodeIds) {
    return nodeIds.map((id) => nodes[id]?.position).whereType<LatLng>().toList();
  }

  List<String> getRouteInstructions(List<String> nodeIds) {
    final instructions = <String>[];
    for (int i = 0; i < nodeIds.length - 1; i++) {
      final instr = getEdgeInstruction(nodeIds[i], nodeIds[i + 1]);
      if (instr != null) instructions.add(instr);
    }
    return instructions;
  }

  static double _haversineDistanceMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dPhi = (lat2 - lat1) * math.pi / 180;
    final dLam = (lon2 - lon1) * math.pi / 180;
    final a = math.pow(math.sin(dPhi / 2), 2) +
        math.cos(phi1) * math.cos(phi2) * math.pow(math.sin(dLam / 2), 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt((1 - a).clamp(0.0, 1.0)));
  }
}

final campusGraph = CampusGraph(
  nodes: {
    'node_000': CampusNode(
      id: 'node_000',
      position: LatLng(7.32686333, 3.87899000),
      label: 'Route start',
      connectedNodeIds: ['node_001'],
    ),
    'node_001': CampusNode(
      id: 'node_001',
      position: LatLng(7.32667167, 3.87911167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_000', 'node_002', 'node_114'],
    ),
    'node_002': CampusNode(
      id: 'node_002',
      position: LatLng(7.32660167, 3.87927167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_001', 'node_003', 'node_113'],
    ),
    'node_003': CampusNode(
      id: 'node_003',
      position: LatLng(7.32661833, 3.87945667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_002', 'node_004', 'node_112'],
    ),
    'node_004': CampusNode(
      id: 'node_004',
      position: LatLng(7.32666500, 3.87965500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_003', 'node_005'],
    ),
    'node_005': CampusNode(
      id: 'node_005',
      position: LatLng(7.32672833, 3.87983667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_004', 'node_006'],
    ),
    'node_006': CampusNode(
      id: 'node_006',
      position: LatLng(7.32682333, 3.88001333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_005', 'node_007'],
    ),
    'node_007': CampusNode(
      id: 'node_007',
      position: LatLng(7.32690000, 3.88019000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_006', 'node_008'],
    ),
    'node_008': CampusNode(
      id: 'node_008',
      position: LatLng(7.32699333, 3.88035667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_007', 'node_009', 'node_108'],
    ),
    'node_009': CampusNode(
      id: 'node_009',
      position: LatLng(7.32707000, 3.88053500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_008', 'node_010', 'node_107'],
    ),
    'node_010': CampusNode(
      id: 'node_010',
      position: LatLng(7.32706167, 3.88073167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_009', 'node_011'],
    ),
    'node_011': CampusNode(
      id: 'node_011',
      position: LatLng(7.32698500, 3.88092500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_010', 'node_012'],
    ),
    'node_012': CampusNode(
      id: 'node_012',
      position: LatLng(7.32688000, 3.88109833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_011', 'node_013'],
    ),
    'node_013': CampusNode(
      id: 'node_013',
      position: LatLng(7.32670833, 3.88119333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_012', 'node_014'],
    ),
    'node_014': CampusNode(
      id: 'node_014',
      position: LatLng(7.32652833, 3.88127167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_013', 'node_015'],
    ),
    'node_015': CampusNode(
      id: 'node_015',
      position: LatLng(7.32633500, 3.88136333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_014', 'node_016'],
    ),
    'node_016': CampusNode(
      id: 'node_016',
      position: LatLng(7.32615667, 3.88145167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_015', 'node_017'],
    ),
    'node_017': CampusNode(
      id: 'node_017',
      position: LatLng(7.32598333, 3.88153000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_016', 'node_018'],
    ),
    'node_018': CampusNode(
      id: 'node_018',
      position: LatLng(7.32582500, 3.88156667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_017', 'node_019', 'node_023'],
    ),
    'node_019': CampusNode(
      id: 'node_019',
      position: LatLng(7.32573000, 3.88138167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_018', 'node_020', 'node_022'],
    ),
    'node_020': CampusNode(
      id: 'node_020',
      position: LatLng(7.32566333, 3.88118667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_019', 'node_021'],
    ),
    'node_021': CampusNode(
      id: 'node_021',
      position: LatLng(7.32563167, 3.88121500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_020', 'node_022'],
    ),
    'node_022': CampusNode(
      id: 'node_022',
      position: LatLng(7.32571667, 3.88141667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_019', 'node_021', 'node_023'],
    ),
    'node_023': CampusNode(
      id: 'node_023',
      position: LatLng(7.32581500, 3.88158333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_018', 'node_022', 'node_024'],
    ),
    'node_024': CampusNode(
      id: 'node_024',
      position: LatLng(7.32573000, 3.88171167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_023', 'node_025', 'node_061'],
    ),
    'node_025': CampusNode(
      id: 'node_025',
      position: LatLng(7.32554833, 3.88181167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_024', 'node_026', 'node_060'],
    ),
    'node_026': CampusNode(
      id: 'node_026',
      position: LatLng(7.32537333, 3.88190500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_025', 'node_027', 'node_059'],
    ),
    'node_027': CampusNode(
      id: 'node_027',
      position: LatLng(7.32518500, 3.88198667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_026', 'node_028', 'node_058'],
    ),
    'node_028': CampusNode(
      id: 'node_028',
      position: LatLng(7.32500500, 3.88208000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_027', 'node_029', 'node_057'],
    ),
    'node_029': CampusNode(
      id: 'node_029',
      position: LatLng(7.32481833, 3.88215500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_028', 'node_030', 'node_056'],
    ),
    'node_030': CampusNode(
      id: 'node_030',
      position: LatLng(7.32462667, 3.88222667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_029', 'node_031', 'node_055'],
    ),
    'node_031': CampusNode(
      id: 'node_031',
      position: LatLng(7.32444333, 3.88230000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_030', 'node_032', 'node_054'],
    ),
    'node_032': CampusNode(
      id: 'node_032',
      position: LatLng(7.32425833, 3.88238500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_031', 'node_033', 'node_053'],
    ),
    'node_033': CampusNode(
      id: 'node_033',
      position: LatLng(7.32409000, 3.88238333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_032', 'node_034', 'node_051', 'node_052'],
    ),
    'node_034': CampusNode(
      id: 'node_034',
      position: LatLng(7.32396000, 3.88222500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_033', 'node_035'],
    ),
    'node_035': CampusNode(
      id: 'node_035',
      position: LatLng(7.32386500, 3.88203667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_034', 'node_036'],
    ),
    'node_036': CampusNode(
      id: 'node_036',
      position: LatLng(7.32374667, 3.88191500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_035', 'node_037', 'node_039', 'node_040', 'node_050'],
    ),
    'node_037': CampusNode(
      id: 'node_037',
      position: LatLng(7.32356167, 3.88199000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_036', 'node_038', 'node_049'],
    ),
    'node_038': CampusNode(
      id: 'node_038',
      position: LatLng(7.32353833, 3.88197500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_037', 'node_039', 'node_049'],
    ),
    'node_039': CampusNode(
      id: 'node_039',
      position: LatLng(7.32373333, 3.88192167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_036', 'node_038', 'node_040', 'node_050'],
    ),
    'node_040': CampusNode(
      id: 'node_040',
      position: LatLng(7.32377833, 3.88184833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_036', 'node_039', 'node_041'],
    ),
    'node_041': CampusNode(
      id: 'node_041',
      position: LatLng(7.32362833, 3.88180333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_040', 'node_042'],
    ),
    'node_042': CampusNode(
      id: 'node_042',
      position: LatLng(7.32343833, 3.88186333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_041', 'node_043'],
    ),
    'node_043': CampusNode(
      id: 'node_043',
      position: LatLng(7.32324500, 3.88190500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_042', 'node_044', 'node_047'],
    ),
    'node_044': CampusNode(
      id: 'node_044',
      position: LatLng(7.32305833, 3.88194833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_043', 'node_045', 'node_046'],
    ),
    'node_045': CampusNode(
      id: 'node_045',
      position: LatLng(7.32287667, 3.88201667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_044', 'node_046'],
    ),
    'node_046': CampusNode(
      id: 'node_046',
      position: LatLng(7.32297333, 3.88199333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_044', 'node_045', 'node_047'],
    ),
    'node_047': CampusNode(
      id: 'node_047',
      position: LatLng(7.32317000, 3.88194667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_043', 'node_046', 'node_048'],
    ),
    'node_048': CampusNode(
      id: 'node_048',
      position: LatLng(7.32335500, 3.88196000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_047', 'node_049'],
    ),
    'node_049': CampusNode(
      id: 'node_049',
      position: LatLng(7.32351667, 3.88200667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_037', 'node_038', 'node_048', 'node_050'],
    ),
    'node_050': CampusNode(
      id: 'node_050',
      position: LatLng(7.32370833, 3.88194500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_036', 'node_039', 'node_049', 'node_051'],
    ),
    'node_051': CampusNode(
      id: 'node_051',
      position: LatLng(7.32409833, 3.88237333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_033', 'node_050', 'node_052'],
    ),
    'node_052': CampusNode(
      id: 'node_052',
      position: LatLng(7.32411333, 3.88239500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_033', 'node_051', 'node_053'],
    ),
    'node_053': CampusNode(
      id: 'node_053',
      position: LatLng(7.32431000, 3.88236333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_032', 'node_052', 'node_054'],
    ),
    'node_054': CampusNode(
      id: 'node_054',
      position: LatLng(7.32449333, 3.88228167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_031', 'node_053', 'node_055'],
    ),
    'node_055': CampusNode(
      id: 'node_055',
      position: LatLng(7.32467667, 3.88220000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_030', 'node_054', 'node_056'],
    ),
    'node_056': CampusNode(
      id: 'node_056',
      position: LatLng(7.32487333, 3.88213167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_029', 'node_055', 'node_057'],
    ),
    'node_057': CampusNode(
      id: 'node_057',
      position: LatLng(7.32504667, 3.88206000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_028', 'node_056', 'node_058'],
    ),
    'node_058': CampusNode(
      id: 'node_058',
      position: LatLng(7.32523500, 3.88198833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_027', 'node_057', 'node_059'],
    ),
    'node_059': CampusNode(
      id: 'node_059',
      position: LatLng(7.32541833, 3.88191333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_026', 'node_058', 'node_060'],
    ),
    'node_060': CampusNode(
      id: 'node_060',
      position: LatLng(7.32559500, 3.88182167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_025', 'node_059', 'node_061'],
    ),
    'node_061': CampusNode(
      id: 'node_061',
      position: LatLng(7.32577000, 3.88173667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_024', 'node_060', 'node_062'],
    ),
    'node_062': CampusNode(
      id: 'node_062',
      position: LatLng(7.32595000, 3.88165500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_061', 'node_063'],
    ),
    'node_063': CampusNode(
      id: 'node_063',
      position: LatLng(7.32613167, 3.88157333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_062', 'node_064'],
    ),
    'node_064': CampusNode(
      id: 'node_064',
      position: LatLng(7.32631000, 3.88149000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_063', 'node_065'],
    ),
    'node_065': CampusNode(
      id: 'node_065',
      position: LatLng(7.32649500, 3.88141500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_064', 'node_066'],
    ),
    'node_066': CampusNode(
      id: 'node_066',
      position: LatLng(7.32666667, 3.88133167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_065', 'node_067'],
    ),
    'node_067': CampusNode(
      id: 'node_067',
      position: LatLng(7.32685333, 3.88123667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_066', 'node_068'],
    ),
    'node_068': CampusNode(
      id: 'node_068',
      position: LatLng(7.32702667, 3.88114167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_067', 'node_069'],
    ),
    'node_069': CampusNode(
      id: 'node_069',
      position: LatLng(7.32719167, 3.88102333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_068', 'node_070'],
    ),
    'node_070': CampusNode(
      id: 'node_070',
      position: LatLng(7.32733167, 3.88089167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_069', 'node_071', 'node_105'],
    ),
    'node_071': CampusNode(
      id: 'node_071',
      position: LatLng(7.32750167, 3.88078000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_070', 'node_072'],
    ),
    'node_072': CampusNode(
      id: 'node_072',
      position: LatLng(7.32764833, 3.88065833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_071', 'node_073'],
    ),
    'node_073': CampusNode(
      id: 'node_073',
      position: LatLng(7.32781333, 3.88055000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_072', 'node_074'],
    ),
    'node_074': CampusNode(
      id: 'node_074',
      position: LatLng(7.32798500, 3.88045833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_073', 'node_075'],
    ),
    'node_075': CampusNode(
      id: 'node_075',
      position: LatLng(7.32818333, 3.88038000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_074', 'node_076'],
    ),
    'node_076': CampusNode(
      id: 'node_076',
      position: LatLng(7.32810333, 3.88041667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_075', 'node_077'],
    ),
    'node_077': CampusNode(
      id: 'node_077',
      position: LatLng(7.32824167, 3.88060167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_076', 'node_078'],
    ),
    'node_078': CampusNode(
      id: 'node_078',
      position: LatLng(7.32837500, 3.88075500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_077', 'node_079', 'node_093'],
    ),
    'node_079': CampusNode(
      id: 'node_079',
      position: LatLng(7.32834167, 3.88094000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_078', 'node_080'],
    ),
    'node_080': CampusNode(
      id: 'node_080',
      position: LatLng(7.32841500, 3.88114000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_079', 'node_081'],
    ),
    'node_081': CampusNode(
      id: 'node_081',
      position: LatLng(7.32845500, 3.88133333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_080', 'node_082'],
    ),
    'node_082': CampusNode(
      id: 'node_082',
      position: LatLng(7.32862667, 3.88132833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_081', 'node_083', 'node_084'],
    ),
    'node_083': CampusNode(
      id: 'node_083',
      position: LatLng(7.32879500, 3.88132500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_082', 'node_084'],
    ),
    'node_084': CampusNode(
      id: 'node_084',
      position: LatLng(7.32867500, 3.88132667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_082', 'node_083', 'node_085'],
    ),
    'node_085': CampusNode(
      id: 'node_085',
      position: LatLng(7.32855833, 3.88145333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_084', 'node_086'],
    ),
    'node_086': CampusNode(
      id: 'node_086',
      position: LatLng(7.32856333, 3.88163667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_085', 'node_087'],
    ),
    'node_087': CampusNode(
      id: 'node_087',
      position: LatLng(7.32837167, 3.88174667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_086', 'node_088'],
    ),
    'node_088': CampusNode(
      id: 'node_088',
      position: LatLng(7.32822500, 3.88160833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_087', 'node_089'],
    ),
    'node_089': CampusNode(
      id: 'node_089',
      position: LatLng(7.32813333, 3.88142667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_088', 'node_090'],
    ),
    'node_090': CampusNode(
      id: 'node_090',
      position: LatLng(7.32803500, 3.88125167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_089', 'node_091'],
    ),
    'node_091': CampusNode(
      id: 'node_091',
      position: LatLng(7.32801333, 3.88108000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_090', 'node_092', 'node_094', 'node_095', 'node_096'],
    ),
    'node_092': CampusNode(
      id: 'node_092',
      position: LatLng(7.32814833, 3.88094167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_091', 'node_093', 'node_095'],
    ),
    'node_093': CampusNode(
      id: 'node_093',
      position: LatLng(7.32831667, 3.88083167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_078', 'node_092', 'node_094'],
    ),
    'node_094': CampusNode(
      id: 'node_094',
      position: LatLng(7.32795500, 3.88116000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_091', 'node_093', 'node_095', 'node_097'],
    ),
    'node_095': CampusNode(
      id: 'node_095',
      position: LatLng(7.32806667, 3.88100833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_091', 'node_092', 'node_094', 'node_096'],
    ),
    'node_096': CampusNode(
      id: 'node_096',
      position: LatLng(7.32803333, 3.88102167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_091', 'node_095', 'node_097'],
    ),
    'node_097': CampusNode(
      id: 'node_097',
      position: LatLng(7.32793833, 3.88118833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_094', 'node_096', 'node_098'],
    ),
    'node_098': CampusNode(
      id: 'node_098',
      position: LatLng(7.32793833, 3.88140333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_097', 'node_099'],
    ),
    'node_099': CampusNode(
      id: 'node_099',
      position: LatLng(7.32796000, 3.88160500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_098', 'node_100'],
    ),
    'node_100': CampusNode(
      id: 'node_100',
      position: LatLng(7.32783333, 3.88173500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_099', 'node_101'],
    ),
    'node_101': CampusNode(
      id: 'node_101',
      position: LatLng(7.32771667, 3.88156667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_100', 'node_102'],
    ),
    'node_102': CampusNode(
      id: 'node_102',
      position: LatLng(7.32760333, 3.88138333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_101', 'node_103'],
    ),
    'node_103': CampusNode(
      id: 'node_103',
      position: LatLng(7.32749167, 3.88122333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_102', 'node_104'],
    ),
    'node_104': CampusNode(
      id: 'node_104',
      position: LatLng(7.32737667, 3.88103667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_103', 'node_105'],
    ),
    'node_105': CampusNode(
      id: 'node_105',
      position: LatLng(7.32728167, 3.88085833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_070', 'node_104', 'node_106'],
    ),
    'node_106': CampusNode(
      id: 'node_106',
      position: LatLng(7.32721000, 3.88065833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_105', 'node_107'],
    ),
    'node_107': CampusNode(
      id: 'node_107',
      position: LatLng(7.32710833, 3.88047500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_009', 'node_106', 'node_108'],
    ),
    'node_108': CampusNode(
      id: 'node_108',
      position: LatLng(7.32702667, 3.88028167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_008', 'node_107', 'node_109'],
    ),
    'node_109': CampusNode(
      id: 'node_109',
      position: LatLng(7.32694333, 3.88008167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_108', 'node_110'],
    ),
    'node_110': CampusNode(
      id: 'node_110',
      position: LatLng(7.32686167, 3.87988500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_109', 'node_111'],
    ),
    'node_111': CampusNode(
      id: 'node_111',
      position: LatLng(7.32680667, 3.87969167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_110', 'node_112'],
    ),
    'node_112': CampusNode(
      id: 'node_112',
      position: LatLng(7.32669333, 3.87950667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_003', 'node_111', 'node_113'],
    ),
    'node_113': CampusNode(
      id: 'node_113',
      position: LatLng(7.32665500, 3.87930500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_002', 'node_112', 'node_114'],
    ),
    'node_114': CampusNode(
      id: 'node_114',
      position: LatLng(7.32660833, 3.87910167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_001', 'node_113', 'node_115'],
    ),
    'node_115': CampusNode(
      id: 'node_115',
      position: LatLng(7.32657833, 3.87890167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_114', 'node_116'],
    ),
    'node_116': CampusNode(
      id: 'node_116',
      position: LatLng(7.32656167, 3.87868500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_115', 'node_117'],
    ),
    'node_117': CampusNode(
      id: 'node_117',
      position: LatLng(7.32652000, 3.87848500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_116', 'node_118'],
    ),
    'node_118': CampusNode(
      id: 'node_118',
      position: LatLng(7.32651333, 3.87827167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_117', 'node_119'],
    ),
    'node_119': CampusNode(
      id: 'node_119',
      position: LatLng(7.32649000, 3.87806667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_118', 'node_120', 'node_127'],
    ),
    'node_120': CampusNode(
      id: 'node_120',
      position: LatLng(7.32631667, 3.87802667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_119', 'node_121', 'node_126'],
    ),
    'node_121': CampusNode(
      id: 'node_121',
      position: LatLng(7.32611333, 3.87800500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_120', 'node_122'],
    ),
    'node_122': CampusNode(
      id: 'node_122',
      position: LatLng(7.32593000, 3.87793000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_121', 'node_123'],
    ),
    'node_123': CampusNode(
      id: 'node_123',
      position: LatLng(7.32573500, 3.87798000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_122', 'node_124'],
    ),
    'node_124': CampusNode(
      id: 'node_124',
      position: LatLng(7.32554167, 3.87793667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_123', 'node_125'],
    ),
    'node_125': CampusNode(
      id: 'node_125',
      position: LatLng(7.32534167, 3.87791833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_124', 'node_126'],
    ),
    'node_126': CampusNode(
      id: 'node_126',
      position: LatLng(7.32623167, 3.87800500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_120', 'node_125', 'node_127'],
    ),
    'node_127': CampusNode(
      id: 'node_127',
      position: LatLng(7.32643000, 3.87798167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_119', 'node_126', 'node_128'],
    ),
    'node_128': CampusNode(
      id: 'node_128',
      position: LatLng(7.32663167, 3.87792500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_127', 'node_129'],
    ),
    'node_129': CampusNode(
      id: 'node_129',
      position: LatLng(7.32681333, 3.87783000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_128', 'node_130'],
    ),
    'node_130': CampusNode(
      id: 'node_130',
      position: LatLng(7.32698833, 3.87772500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_129', 'node_131'],
    ),
    'node_131': CampusNode(
      id: 'node_131',
      position: LatLng(7.32717333, 3.87764500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_130', 'node_132'],
    ),
    'node_132': CampusNode(
      id: 'node_132',
      position: LatLng(7.32735333, 3.87759167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_131', 'node_133', 'node_160'],
    ),
    'node_133': CampusNode(
      id: 'node_133',
      position: LatLng(7.32742667, 3.87742667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_132', 'node_134'],
    ),
    'node_134': CampusNode(
      id: 'node_134',
      position: LatLng(7.32762833, 3.87738667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_133', 'node_135'],
    ),
    'node_135': CampusNode(
      id: 'node_135',
      position: LatLng(7.32782500, 3.87734333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_134', 'node_136'],
    ),
    'node_136': CampusNode(
      id: 'node_136',
      position: LatLng(7.32801833, 3.87728667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_135', 'node_137'],
    ),
    'node_137': CampusNode(
      id: 'node_137',
      position: LatLng(7.32821167, 3.87724500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_136', 'node_138', 'node_141', 'node_142'],
    ),
    'node_138': CampusNode(
      id: 'node_138',
      position: LatLng(7.32837833, 3.87714833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_137', 'node_139'],
    ),
    'node_139': CampusNode(
      id: 'node_139',
      position: LatLng(7.32836667, 3.87772000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_138', 'node_140'],
    ),
    'node_140': CampusNode(
      id: 'node_140',
      position: LatLng(7.32830000, 3.87753500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_139', 'node_141'],
    ),
    'node_141': CampusNode(
      id: 'node_141',
      position: LatLng(7.32821000, 3.87735167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_137', 'node_140', 'node_142'],
    ),
    'node_142': CampusNode(
      id: 'node_142',
      position: LatLng(7.32817333, 3.87715333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_137', 'node_141', 'node_143'],
    ),
    'node_143': CampusNode(
      id: 'node_143',
      position: LatLng(7.32808500, 3.87698667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_142', 'node_144'],
    ),
    'node_144': CampusNode(
      id: 'node_144',
      position: LatLng(7.32802333, 3.87696000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_143', 'node_145'],
    ),
    'node_145': CampusNode(
      id: 'node_145',
      position: LatLng(7.32782333, 3.87699500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_144', 'node_146'],
    ),
    'node_146': CampusNode(
      id: 'node_146',
      position: LatLng(7.32761667, 3.87702000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_145', 'node_147'],
    ),
    'node_147': CampusNode(
      id: 'node_147',
      position: LatLng(7.32748333, 3.87694000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_146', 'node_148'],
    ),
    'node_148': CampusNode(
      id: 'node_148',
      position: LatLng(7.32744500, 3.87672833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_147', 'node_149', 'node_155'],
    ),
    'node_149': CampusNode(
      id: 'node_149',
      position: LatLng(7.32729000, 3.87660000),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_148', 'node_150'],
    ),
    'node_150': CampusNode(
      id: 'node_150',
      position: LatLng(7.32709833, 3.87655167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_149', 'node_151'],
    ),
    'node_151': CampusNode(
      id: 'node_151',
      position: LatLng(7.32690833, 3.87652500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_150', 'node_152'],
    ),
    'node_152': CampusNode(
      id: 'node_152',
      position: LatLng(7.32683333, 3.87663833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_151', 'node_153'],
    ),
    'node_153': CampusNode(
      id: 'node_153',
      position: LatLng(7.32700500, 3.87667667),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_152', 'node_154'],
    ),
    'node_154': CampusNode(
      id: 'node_154',
      position: LatLng(7.32720000, 3.87671167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_153', 'node_155'],
    ),
    'node_155': CampusNode(
      id: 'node_155',
      position: LatLng(7.32738333, 3.87676500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_148', 'node_154', 'node_156'],
    ),
    'node_156': CampusNode(
      id: 'node_156',
      position: LatLng(7.32737667, 3.87692167),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_155', 'node_157'],
    ),
    'node_157': CampusNode(
      id: 'node_157',
      position: LatLng(7.32725667, 3.87705833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_156', 'node_158'],
    ),
    'node_158': CampusNode(
      id: 'node_158',
      position: LatLng(7.32726833, 3.87725833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_157', 'node_159'],
    ),
    'node_159': CampusNode(
      id: 'node_159',
      position: LatLng(7.32730333, 3.87744833),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_158', 'node_160'],
    ),
    'node_160': CampusNode(
      id: 'node_160',
      position: LatLng(7.32733667, 3.87765333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_132', 'node_159', 'node_161'],
    ),
    'node_161': CampusNode(
      id: 'node_161',
      position: LatLng(7.32741667, 3.87784333),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_160', 'node_162'],
    ),
    'node_162': CampusNode(
      id: 'node_162',
      position: LatLng(7.32747500, 3.87802500),
      label: null,  // TODO: add landmark name if applicable
      connectedNodeIds: ['node_161', 'node_163'],
    ),
    'node_163': CampusNode(
      id: 'node_163',
      position: LatLng(7.32753167, 3.87821000),
      label: 'Route end',
      connectedNodeIds: ['node_162'],
    ),
    // --- ADD MORE NODES HERE ---
  },

  edges: [
    // node_000 → node_001 (25.2m)
    CampusEdge(
      fromId: 'node_000',
      toId: 'node_001',
      distanceMeters: 25.2,
      voiceInstruction: 'Head along the path',
    ),
    // node_001 → node_002 (19.3m)
    CampusEdge(
      fromId: 'node_001',
      toId: 'node_002',
      distanceMeters: 19.3,
      voiceInstruction: 'Bear left',
    ),
    // node_002 → node_003 (20.5m)
    CampusEdge(
      fromId: 'node_002',
      toId: 'node_003',
      distanceMeters: 20.5,
      voiceInstruction: 'Bear left',
    ),
    // node_003 → node_004 (22.5m)
    CampusEdge(
      fromId: 'node_003',
      toId: 'node_004',
      distanceMeters: 22.5,
      voiceInstruction: null,
    ),
    // node_004 → node_005 (21.2m)
    CampusEdge(
      fromId: 'node_004',
      toId: 'node_005',
      distanceMeters: 21.2,
      voiceInstruction: null,
    ),
    // node_005 → node_006 (22.2m)
    CampusEdge(
      fromId: 'node_005',
      toId: 'node_006',
      distanceMeters: 22.2,
      voiceInstruction: null,
    ),
    // node_006 → node_007 (21.3m)
    CampusEdge(
      fromId: 'node_006',
      toId: 'node_007',
      distanceMeters: 21.3,
      voiceInstruction: null,
    ),
    // node_007 → node_008 (21.1m)
    CampusEdge(
      fromId: 'node_007',
      toId: 'node_008',
      distanceMeters: 21.1,
      voiceInstruction: null,
    ),
    // node_008 → node_009 (21.4m)
    CampusEdge(
      fromId: 'node_008',
      toId: 'node_009',
      distanceMeters: 21.4,
      voiceInstruction: null,
    ),
    // node_009 → node_010 (21.7m)
    CampusEdge(
      fromId: 'node_009',
      toId: 'node_010',
      distanceMeters: 21.7,
      voiceInstruction: 'Bear right',
    ),
    // node_010 → node_011 (23.0m)
    CampusEdge(
      fromId: 'node_010',
      toId: 'node_011',
      distanceMeters: 23.0,
      voiceInstruction: 'Bear right',
    ),
    // node_011 → node_012 (22.4m)
    CampusEdge(
      fromId: 'node_011',
      toId: 'node_012',
      distanceMeters: 22.4,
      voiceInstruction: null,
    ),
    // node_012 → node_013 (21.8m)
    CampusEdge(
      fromId: 'node_012',
      toId: 'node_013',
      distanceMeters: 21.8,
      voiceInstruction: 'Bear right',
    ),
    // node_013 → node_014 (21.8m)
    CampusEdge(
      fromId: 'node_013',
      toId: 'node_014',
      distanceMeters: 21.8,
      voiceInstruction: null,
    ),
    // node_014 → node_015 (23.8m)
    CampusEdge(
      fromId: 'node_014',
      toId: 'node_015',
      distanceMeters: 23.8,
      voiceInstruction: null,
    ),
    // node_015 → node_016 (22.1m)
    CampusEdge(
      fromId: 'node_015',
      toId: 'node_016',
      distanceMeters: 22.1,
      voiceInstruction: null,
    ),
    // node_016 → node_017 (21.1m)
    CampusEdge(
      fromId: 'node_016',
      toId: 'node_017',
      distanceMeters: 21.1,
      voiceInstruction: null,
    ),
    // node_017 → node_018 (18.1m)
    CampusEdge(
      fromId: 'node_017',
      toId: 'node_018',
      distanceMeters: 18.1,
      voiceInstruction: null,
    ),
    // node_018 → node_019 (23.0m)
    CampusEdge(
      fromId: 'node_018',
      toId: 'node_019',
      distanceMeters: 23.0,
      voiceInstruction: 'Turn right',
    ),
    // node_019 → node_020 (22.7m)
    CampusEdge(
      fromId: 'node_019',
      toId: 'node_020',
      distanceMeters: 22.7,
      voiceInstruction: null,
    ),
    // node_020 → node_021 (4.7m)
    CampusEdge(
      fromId: 'node_020',
      toId: 'node_021',
      distanceMeters: 4.7,
      voiceInstruction: 'Turn left',
    ),
    // node_021 → node_022 (24.2m)
    CampusEdge(
      fromId: 'node_021',
      toId: 'node_022',
      distanceMeters: 24.2,
      voiceInstruction: 'Bear left',
    ),
    // node_022 → node_023 (21.4m)
    CampusEdge(
      fromId: 'node_022',
      toId: 'node_023',
      distanceMeters: 21.4,
      voiceInstruction: null,
    ),
    // node_023 → node_024 (17.0m)
    CampusEdge(
      fromId: 'node_023',
      toId: 'node_024',
      distanceMeters: 17.0,
      voiceInstruction: 'Bear right',
    ),
    // node_024 → node_025 (23.0m)
    CampusEdge(
      fromId: 'node_024',
      toId: 'node_025',
      distanceMeters: 23.0,
      voiceInstruction: 'Bear right',
    ),
    // node_025 → node_026 (22.0m)
    CampusEdge(
      fromId: 'node_025',
      toId: 'node_026',
      distanceMeters: 22.0,
      voiceInstruction: null,
    ),
    // node_026 → node_027 (22.8m)
    CampusEdge(
      fromId: 'node_026',
      toId: 'node_027',
      distanceMeters: 22.8,
      voiceInstruction: null,
    ),
    // node_027 → node_028 (22.5m)
    CampusEdge(
      fromId: 'node_027',
      toId: 'node_028',
      distanceMeters: 22.5,
      voiceInstruction: null,
    ),
    // node_028 → node_029 (22.3m)
    CampusEdge(
      fromId: 'node_028',
      toId: 'node_029',
      distanceMeters: 22.3,
      voiceInstruction: null,
    ),
    // node_029 → node_030 (22.7m)
    CampusEdge(
      fromId: 'node_029',
      toId: 'node_030',
      distanceMeters: 22.7,
      voiceInstruction: null,
    ),
    // node_030 → node_031 (21.9m)
    CampusEdge(
      fromId: 'node_030',
      toId: 'node_031',
      distanceMeters: 21.9,
      voiceInstruction: null,
    ),
    // node_031 → node_032 (22.6m)
    CampusEdge(
      fromId: 'node_031',
      toId: 'node_032',
      distanceMeters: 22.6,
      voiceInstruction: null,
    ),
    // node_032 → node_033 (18.7m)
    CampusEdge(
      fromId: 'node_032',
      toId: 'node_033',
      distanceMeters: 18.7,
      voiceInstruction: 'Bear right',
    ),
    // node_033 → node_034 (22.7m)
    CampusEdge(
      fromId: 'node_033',
      toId: 'node_034',
      distanceMeters: 22.7,
      voiceInstruction: 'Bear right',
    ),
    // node_034 → node_035 (23.3m)
    CampusEdge(
      fromId: 'node_034',
      toId: 'node_035',
      distanceMeters: 23.3,
      voiceInstruction: 'Bear right',
    ),
    // node_035 → node_036 (18.8m)
    CampusEdge(
      fromId: 'node_035',
      toId: 'node_036',
      distanceMeters: 18.8,
      voiceInstruction: 'Bear left',
    ),
    // node_036 → node_037 (22.2m)
    CampusEdge(
      fromId: 'node_036',
      toId: 'node_037',
      distanceMeters: 22.2,
      voiceInstruction: 'Bear left',
    ),
    // node_037 → node_038 (3.1m)
    CampusEdge(
      fromId: 'node_037',
      toId: 'node_038',
      distanceMeters: 3.1,
      voiceInstruction: 'Bear right',
    ),
    // node_038 → node_039 (22.5m)
    CampusEdge(
      fromId: 'node_038',
      toId: 'node_039',
      distanceMeters: 22.5,
      voiceInstruction: 'Turn right',
    ),
    // node_039 → node_040 (9.5m)
    CampusEdge(
      fromId: 'node_039',
      toId: 'node_040',
      distanceMeters: 9.5,
      voiceInstruction: 'Bear left',
    ),
    // node_040 → node_041 (17.4m)
    CampusEdge(
      fromId: 'node_040',
      toId: 'node_041',
      distanceMeters: 17.4,
      voiceInstruction: 'Turn left',
    ),
    // node_041 → node_042 (22.1m)
    CampusEdge(
      fromId: 'node_041',
      toId: 'node_042',
      distanceMeters: 22.1,
      voiceInstruction: 'Bear left',
    ),
    // node_042 → node_043 (22.0m)
    CampusEdge(
      fromId: 'node_042',
      toId: 'node_043',
      distanceMeters: 22.0,
      voiceInstruction: null,
    ),
    // node_043 → node_044 (21.3m)
    CampusEdge(
      fromId: 'node_043',
      toId: 'node_044',
      distanceMeters: 21.3,
      voiceInstruction: null,
    ),
    // node_044 → node_045 (21.6m)
    CampusEdge(
      fromId: 'node_044',
      toId: 'node_045',
      distanceMeters: 21.6,
      voiceInstruction: null,
    ),
    // node_045 → node_046 (11.1m)
    CampusEdge(
      fromId: 'node_045',
      toId: 'node_046',
      distanceMeters: 11.1,
      voiceInstruction: 'Turn left',
    ),
    // node_046 → node_047 (22.5m)
    CampusEdge(
      fromId: 'node_046',
      toId: 'node_047',
      distanceMeters: 22.5,
      voiceInstruction: null,
    ),
    // node_047 → node_048 (20.6m)
    CampusEdge(
      fromId: 'node_047',
      toId: 'node_048',
      distanceMeters: 20.6,
      voiceInstruction: 'Bear right',
    ),
    // node_048 → node_049 (18.7m)
    CampusEdge(
      fromId: 'node_048',
      toId: 'node_049',
      distanceMeters: 18.7,
      voiceInstruction: null,
    ),
    // node_049 → node_050 (22.4m)
    CampusEdge(
      fromId: 'node_049',
      toId: 'node_050',
      distanceMeters: 22.4,
      voiceInstruction: 'Bear left',
    ),
    // node_050 → node_051 (64.1m)
    CampusEdge(
      fromId: 'node_050',
      toId: 'node_051',
      distanceMeters: 64.1,
      voiceInstruction: 'Bear right',
    ),
    // node_051 → node_052 (2.9m)
    CampusEdge(
      fromId: 'node_051',
      toId: 'node_052',
      distanceMeters: 2.9,
      voiceInstruction: null,
    ),
    // node_052 → node_053 (22.1m)
    CampusEdge(
      fromId: 'node_052',
      toId: 'node_053',
      distanceMeters: 22.1,
      voiceInstruction: 'Bear left',
    ),
    // node_053 → node_054 (22.3m)
    CampusEdge(
      fromId: 'node_053',
      toId: 'node_054',
      distanceMeters: 22.3,
      voiceInstruction: 'Bear left',
    ),
    // node_054 → node_055 (22.3m)
    CampusEdge(
      fromId: 'node_054',
      toId: 'node_055',
      distanceMeters: 22.3,
      voiceInstruction: null,
    ),
    // node_055 → node_056 (23.1m)
    CampusEdge(
      fromId: 'node_055',
      toId: 'node_056',
      distanceMeters: 23.1,
      voiceInstruction: null,
    ),
    // node_056 → node_057 (20.8m)
    CampusEdge(
      fromId: 'node_056',
      toId: 'node_057',
      distanceMeters: 20.8,
      voiceInstruction: null,
    ),
    // node_057 → node_058 (22.4m)
    CampusEdge(
      fromId: 'node_057',
      toId: 'node_058',
      distanceMeters: 22.4,
      voiceInstruction: null,
    ),
    // node_058 → node_059 (22.0m)
    CampusEdge(
      fromId: 'node_058',
      toId: 'node_059',
      distanceMeters: 22.0,
      voiceInstruction: null,
    ),
    // node_059 → node_060 (22.1m)
    CampusEdge(
      fromId: 'node_059',
      toId: 'node_060',
      distanceMeters: 22.1,
      voiceInstruction: null,
    ),
    // node_060 → node_061 (21.6m)
    CampusEdge(
      fromId: 'node_060',
      toId: 'node_061',
      distanceMeters: 21.6,
      voiceInstruction: null,
    ),
    // node_061 → node_062 (21.9m)
    CampusEdge(
      fromId: 'node_061',
      toId: 'node_062',
      distanceMeters: 21.9,
      voiceInstruction: null,
    ),
    // node_062 → node_063 (22.1m)
    CampusEdge(
      fromId: 'node_062',
      toId: 'node_063',
      distanceMeters: 22.1,
      voiceInstruction: null,
    ),
    // node_063 → node_064 (21.9m)
    CampusEdge(
      fromId: 'node_063',
      toId: 'node_064',
      distanceMeters: 21.9,
      voiceInstruction: null,
    ),
    // node_064 → node_065 (22.2m)
    CampusEdge(
      fromId: 'node_064',
      toId: 'node_065',
      distanceMeters: 22.2,
      voiceInstruction: null,
    ),
    // node_065 → node_066 (21.2m)
    CampusEdge(
      fromId: 'node_065',
      toId: 'node_066',
      distanceMeters: 21.2,
      voiceInstruction: null,
    ),
    // node_066 → node_067 (23.3m)
    CampusEdge(
      fromId: 'node_066',
      toId: 'node_067',
      distanceMeters: 23.3,
      voiceInstruction: null,
    ),
    // node_067 → node_068 (21.9m)
    CampusEdge(
      fromId: 'node_067',
      toId: 'node_068',
      distanceMeters: 21.9,
      voiceInstruction: null,
    ),
    // node_068 → node_069 (22.5m)
    CampusEdge(
      fromId: 'node_068',
      toId: 'node_069',
      distanceMeters: 22.5,
      voiceInstruction: null,
    ),
    // node_069 → node_070 (21.3m)
    CampusEdge(
      fromId: 'node_069',
      toId: 'node_070',
      distanceMeters: 21.3,
      voiceInstruction: null,
    ),
    // node_070 → node_071 (22.6m)
    CampusEdge(
      fromId: 'node_070',
      toId: 'node_071',
      distanceMeters: 22.6,
      voiceInstruction: null,
    ),
    // node_071 → node_072 (21.1m)
    CampusEdge(
      fromId: 'node_071',
      toId: 'node_072',
      distanceMeters: 21.1,
      voiceInstruction: null,
    ),
    // node_072 → node_073 (21.9m)
    CampusEdge(
      fromId: 'node_072',
      toId: 'node_073',
      distanceMeters: 21.9,
      voiceInstruction: null,
    ),
    // node_073 → node_074 (21.6m)
    CampusEdge(
      fromId: 'node_073',
      toId: 'node_074',
      distanceMeters: 21.6,
      voiceInstruction: null,
    ),
    // node_074 → node_075 (23.7m)
    CampusEdge(
      fromId: 'node_074',
      toId: 'node_075',
      distanceMeters: 23.7,
      voiceInstruction: null,
    ),
    // node_075 → node_076 (9.8m)
    CampusEdge(
      fromId: 'node_075',
      toId: 'node_076',
      distanceMeters: 9.8,
      voiceInstruction: 'Turn right',
    ),
    // node_076 → node_077 (25.6m)
    CampusEdge(
      fromId: 'node_076',
      toId: 'node_077',
      distanceMeters: 25.6,
      voiceInstruction: 'Turn left',
    ),
    // node_077 → node_078 (22.5m)
    CampusEdge(
      fromId: 'node_077',
      toId: 'node_078',
      distanceMeters: 22.5,
      voiceInstruction: null,
    ),
    // node_078 → node_079 (20.7m)
    CampusEdge(
      fromId: 'node_078',
      toId: 'node_079',
      distanceMeters: 20.7,
      voiceInstruction: 'Bear right',
    ),
    // node_079 → node_080 (23.5m)
    CampusEdge(
      fromId: 'node_079',
      toId: 'node_080',
      distanceMeters: 23.5,
      voiceInstruction: 'Bear left',
    ),
    // node_080 → node_081 (21.8m)
    CampusEdge(
      fromId: 'node_080',
      toId: 'node_081',
      distanceMeters: 21.8,
      voiceInstruction: null,
    ),
    // node_081 → node_082 (19.1m)
    CampusEdge(
      fromId: 'node_081',
      toId: 'node_082',
      distanceMeters: 19.1,
      voiceInstruction: 'Turn left',
    ),
    // node_082 → node_083 (18.7m)
    CampusEdge(
      fromId: 'node_082',
      toId: 'node_083',
      distanceMeters: 18.7,
      voiceInstruction: null,
    ),
    // node_083 → node_084 (13.3m)
    CampusEdge(
      fromId: 'node_083',
      toId: 'node_084',
      distanceMeters: 13.3,
      voiceInstruction: 'Turn left',
    ),
    // node_084 → node_085 (19.1m)
    CampusEdge(
      fromId: 'node_084',
      toId: 'node_085',
      distanceMeters: 19.1,
      voiceInstruction: 'Bear left',
    ),
    // node_085 → node_086 (20.2m)
    CampusEdge(
      fromId: 'node_085',
      toId: 'node_086',
      distanceMeters: 20.2,
      voiceInstruction: 'Bear left',
    ),
    // node_086 → node_087 (24.5m)
    CampusEdge(
      fromId: 'node_086',
      toId: 'node_087',
      distanceMeters: 24.5,
      voiceInstruction: 'Bear right',
    ),
    // node_087 → node_088 (22.3m)
    CampusEdge(
      fromId: 'node_087',
      toId: 'node_088',
      distanceMeters: 22.3,
      voiceInstruction: 'Bear right',
    ),
    // node_088 → node_089 (22.5m)
    CampusEdge(
      fromId: 'node_088',
      toId: 'node_089',
      distanceMeters: 22.5,
      voiceInstruction: 'Bear right',
    ),
    // node_089 → node_090 (22.2m)
    CampusEdge(
      fromId: 'node_089',
      toId: 'node_090',
      distanceMeters: 22.2,
      voiceInstruction: null,
    ),
    // node_090 → node_091 (19.1m)
    CampusEdge(
      fromId: 'node_090',
      toId: 'node_091',
      distanceMeters: 19.1,
      voiceInstruction: 'Bear right',
    ),
    // node_091 → node_092 (21.4m)
    CampusEdge(
      fromId: 'node_091',
      toId: 'node_092',
      distanceMeters: 21.4,
      voiceInstruction: 'Bear right',
    ),
    // node_092 → node_093 (22.3m)
    CampusEdge(
      fromId: 'node_092',
      toId: 'node_093',
      distanceMeters: 22.3,
      voiceInstruction: 'Bear right',
    ),
    // node_093 → node_094 (54.1m)
    CampusEdge(
      fromId: 'node_093',
      toId: 'node_094',
      distanceMeters: 54.1,
      voiceInstruction: 'Turn right',
    ),
    // node_094 → node_095 (20.8m)
    CampusEdge(
      fromId: 'node_094',
      toId: 'node_095',
      distanceMeters: 20.8,
      voiceInstruction: 'Turn right',
    ),
    // node_095 → node_096 (4.0m)
    CampusEdge(
      fromId: 'node_095',
      toId: 'node_096',
      distanceMeters: 4.0,
      voiceInstruction: 'Turn left',
    ),
    // node_096 → node_097 (21.2m)
    CampusEdge(
      fromId: 'node_096',
      toId: 'node_097',
      distanceMeters: 21.2,
      voiceInstruction: 'Bear left',
    ),
    // node_097 → node_098 (23.7m)
    CampusEdge(
      fromId: 'node_097',
      toId: 'node_098',
      distanceMeters: 23.7,
      voiceInstruction: 'Bear left',
    ),
    // node_098 → node_099 (22.4m)
    CampusEdge(
      fromId: 'node_098',
      toId: 'node_099',
      distanceMeters: 22.4,
      voiceInstruction: null,
    ),
    // node_099 → node_100 (20.1m)
    CampusEdge(
      fromId: 'node_099',
      toId: 'node_100',
      distanceMeters: 20.1,
      voiceInstruction: 'Bear right',
    ),
    // node_100 → node_101 (22.6m)
    CampusEdge(
      fromId: 'node_100',
      toId: 'node_101',
      distanceMeters: 22.6,
      voiceInstruction: 'Turn right',
    ),
    // node_101 → node_102 (23.8m)
    CampusEdge(
      fromId: 'node_101',
      toId: 'node_102',
      distanceMeters: 23.8,
      voiceInstruction: null,
    ),
    // node_102 → node_103 (21.6m)
    CampusEdge(
      fromId: 'node_102',
      toId: 'node_103',
      distanceMeters: 21.6,
      voiceInstruction: null,
    ),
    // node_103 → node_104 (24.2m)
    CampusEdge(
      fromId: 'node_103',
      toId: 'node_104',
      distanceMeters: 24.2,
      voiceInstruction: null,
    ),
    // node_104 → node_105 (22.3m)
    CampusEdge(
      fromId: 'node_104',
      toId: 'node_105',
      distanceMeters: 22.3,
      voiceInstruction: null,
    ),
    // node_105 → node_106 (23.5m)
    CampusEdge(
      fromId: 'node_105',
      toId: 'node_106',
      distanceMeters: 23.5,
      voiceInstruction: null,
    ),
    // node_106 → node_107 (23.2m)
    CampusEdge(
      fromId: 'node_106',
      toId: 'node_107',
      distanceMeters: 23.2,
      voiceInstruction: null,
    ),
    // node_107 → node_108 (23.2m)
    CampusEdge(
      fromId: 'node_107',
      toId: 'node_108',
      distanceMeters: 23.2,
      voiceInstruction: null,
    ),
    // node_108 → node_109 (23.9m)
    CampusEdge(
      fromId: 'node_108',
      toId: 'node_109',
      distanceMeters: 23.9,
      voiceInstruction: null,
    ),
    // node_109 → node_110 (23.5m)
    CampusEdge(
      fromId: 'node_109',
      toId: 'node_110',
      distanceMeters: 23.5,
      voiceInstruction: null,
    ),
    // node_110 → node_111 (22.2m)
    CampusEdge(
      fromId: 'node_110',
      toId: 'node_111',
      distanceMeters: 22.2,
      voiceInstruction: null,
    ),
    // node_111 → node_112 (24.0m)
    CampusEdge(
      fromId: 'node_111',
      toId: 'node_112',
      distanceMeters: 24.0,
      voiceInstruction: 'Bear left',
    ),
    // node_112 → node_113 (22.6m)
    CampusEdge(
      fromId: 'node_112',
      toId: 'node_113',
      distanceMeters: 22.6,
      voiceInstruction: 'Bear right',
    ),
    // node_113 → node_114 (23.0m)
    CampusEdge(
      fromId: 'node_113',
      toId: 'node_114',
      distanceMeters: 23.0,
      voiceInstruction: null,
    ),
    // node_114 → node_115 (22.3m)
    CampusEdge(
      fromId: 'node_114',
      toId: 'node_115',
      distanceMeters: 22.3,
      voiceInstruction: null,
    ),
    // node_115 → node_116 (24.0m)
    CampusEdge(
      fromId: 'node_115',
      toId: 'node_116',
      distanceMeters: 24.0,
      voiceInstruction: null,
    ),
    // node_116 → node_117 (22.5m)
    CampusEdge(
      fromId: 'node_116',
      toId: 'node_117',
      distanceMeters: 22.5,
      voiceInstruction: null,
    ),
    // node_117 → node_118 (23.5m)
    CampusEdge(
      fromId: 'node_117',
      toId: 'node_118',
      distanceMeters: 23.5,
      voiceInstruction: null,
    ),
    // node_118 → node_119 (22.8m)
    CampusEdge(
      fromId: 'node_118',
      toId: 'node_119',
      distanceMeters: 22.8,
      voiceInstruction: null,
    ),
    // node_119 → node_120 (19.8m)
    CampusEdge(
      fromId: 'node_119',
      toId: 'node_120',
      distanceMeters: 19.8,
      voiceInstruction: 'Bear left',
    ),
    // node_120 → node_121 (22.7m)
    CampusEdge(
      fromId: 'node_120',
      toId: 'node_121',
      distanceMeters: 22.7,
      voiceInstruction: null,
    ),
    // node_121 → node_122 (22.0m)
    CampusEdge(
      fromId: 'node_121',
      toId: 'node_122',
      distanceMeters: 22.0,
      voiceInstruction: 'Bear right',
    ),
    // node_122 → node_123 (22.4m)
    CampusEdge(
      fromId: 'node_122',
      toId: 'node_123',
      distanceMeters: 22.4,
      voiceInstruction: 'Bear left',
    ),
    // node_123 → node_124 (22.0m)
    CampusEdge(
      fromId: 'node_123',
      toId: 'node_124',
      distanceMeters: 22.0,
      voiceInstruction: 'Bear right',
    ),
    // node_124 → node_125 (22.3m)
    CampusEdge(
      fromId: 'node_124',
      toId: 'node_125',
      distanceMeters: 22.3,
      voiceInstruction: null,
    ),
    // node_125 → node_126 (99.4m)
    CampusEdge(
      fromId: 'node_125',
      toId: 'node_126',
      distanceMeters: 99.4,
      voiceInstruction: 'Turn left',
    ),
    // node_126 → node_127 (22.2m)
    CampusEdge(
      fromId: 'node_126',
      toId: 'node_127',
      distanceMeters: 22.2,
      voiceInstruction: 'Bear left',
    ),
    // node_127 → node_128 (23.3m)
    CampusEdge(
      fromId: 'node_127',
      toId: 'node_128',
      distanceMeters: 23.3,
      voiceInstruction: null,
    ),
    // node_128 → node_129 (22.8m)
    CampusEdge(
      fromId: 'node_128',
      toId: 'node_129',
      distanceMeters: 22.8,
      voiceInstruction: null,
    ),
    // node_129 → node_130 (22.6m)
    CampusEdge(
      fromId: 'node_129',
      toId: 'node_130',
      distanceMeters: 22.6,
      voiceInstruction: null,
    ),
    // node_130 → node_131 (22.4m)
    CampusEdge(
      fromId: 'node_130',
      toId: 'node_131',
      distanceMeters: 22.4,
      voiceInstruction: null,
    ),
    // node_131 → node_132 (20.9m)
    CampusEdge(
      fromId: 'node_131',
      toId: 'node_132',
      distanceMeters: 20.9,
      voiceInstruction: null,
    ),
    // node_132 → node_133 (19.9m)
    CampusEdge(
      fromId: 'node_132',
      toId: 'node_133',
      distanceMeters: 19.9,
      voiceInstruction: 'Bear left',
    ),
    // node_133 → node_134 (22.9m)
    CampusEdge(
      fromId: 'node_133',
      toId: 'node_134',
      distanceMeters: 22.9,
      voiceInstruction: 'Bear right',
    ),
    // node_134 → node_135 (22.4m)
    CampusEdge(
      fromId: 'node_134',
      toId: 'node_135',
      distanceMeters: 22.4,
      voiceInstruction: null,
    ),
    // node_135 → node_136 (22.4m)
    CampusEdge(
      fromId: 'node_135',
      toId: 'node_136',
      distanceMeters: 22.4,
      voiceInstruction: null,
    ),
    // node_136 → node_137 (22.0m)
    CampusEdge(
      fromId: 'node_136',
      toId: 'node_137',
      distanceMeters: 22.0,
      voiceInstruction: null,
    ),
    // node_137 → node_138 (21.4m)
    CampusEdge(
      fromId: 'node_137',
      toId: 'node_138',
      distanceMeters: 21.4,
      voiceInstruction: 'Bear left',
    ),
    // node_138 → node_139 (63.1m)
    CampusEdge(
      fromId: 'node_138',
      toId: 'node_139',
      distanceMeters: 63.1,
      voiceInstruction: 'Turn right',
    ),
    // node_139 → node_140 (21.7m)
    CampusEdge(
      fromId: 'node_139',
      toId: 'node_140',
      distanceMeters: 21.7,
      voiceInstruction: 'Turn right',
    ),
    // node_140 → node_141 (22.6m)
    CampusEdge(
      fromId: 'node_140',
      toId: 'node_141',
      distanceMeters: 22.6,
      voiceInstruction: null,
    ),
    // node_141 → node_142 (22.3m)
    CampusEdge(
      fromId: 'node_141',
      toId: 'node_142',
      distanceMeters: 22.3,
      voiceInstruction: 'Bear right',
    ),
    // node_142 → node_143 (20.8m)
    CampusEdge(
      fromId: 'node_142',
      toId: 'node_143',
      distanceMeters: 20.8,
      voiceInstruction: 'Bear left',
    ),
    // node_143 → node_144 (7.5m)
    CampusEdge(
      fromId: 'node_143',
      toId: 'node_144',
      distanceMeters: 7.5,
      voiceInstruction: 'Bear left',
    ),
    // node_144 → node_145 (22.6m)
    CampusEdge(
      fromId: 'node_144',
      toId: 'node_145',
      distanceMeters: 22.6,
      voiceInstruction: 'Bear left',
    ),
    // node_145 → node_146 (23.1m)
    CampusEdge(
      fromId: 'node_145',
      toId: 'node_146',
      distanceMeters: 23.1,
      voiceInstruction: null,
    ),
    // node_146 → node_147 (17.3m)
    CampusEdge(
      fromId: 'node_146',
      toId: 'node_147',
      distanceMeters: 17.3,
      voiceInstruction: 'Bear right',
    ),
    // node_147 → node_148 (23.7m)
    CampusEdge(
      fromId: 'node_147',
      toId: 'node_148',
      distanceMeters: 23.7,
      voiceInstruction: 'Bear right',
    ),
    // node_148 → node_149 (22.3m)
    CampusEdge(
      fromId: 'node_148',
      toId: 'node_149',
      distanceMeters: 22.3,
      voiceInstruction: 'Bear left',
    ),
    // node_149 → node_150 (22.0m)
    CampusEdge(
      fromId: 'node_149',
      toId: 'node_150',
      distanceMeters: 22.0,
      voiceInstruction: 'Bear left',
    ),
    // node_150 → node_151 (21.3m)
    CampusEdge(
      fromId: 'node_150',
      toId: 'node_151',
      distanceMeters: 21.3,
      voiceInstruction: null,
    ),
    // node_151 → node_152 (15.0m)
    CampusEdge(
      fromId: 'node_151',
      toId: 'node_152',
      distanceMeters: 15.0,
      voiceInstruction: 'Bear left',
    ),
    // node_152 → node_153 (19.6m)
    CampusEdge(
      fromId: 'node_152',
      toId: 'node_153',
      distanceMeters: 19.6,
      voiceInstruction: 'Turn left',
    ),
    // node_153 → node_154 (22.0m)
    CampusEdge(
      fromId: 'node_153',
      toId: 'node_154',
      distanceMeters: 22.0,
      voiceInstruction: null,
    ),
    // node_154 → node_155 (21.2m)
    CampusEdge(
      fromId: 'node_154',
      toId: 'node_155',
      distanceMeters: 21.2,
      voiceInstruction: null,
    ),
    // node_155 → node_156 (17.3m)
    CampusEdge(
      fromId: 'node_155',
      toId: 'node_156',
      distanceMeters: 17.3,
      voiceInstruction: 'Turn right',
    ),
    // node_156 → node_157 (20.1m)
    CampusEdge(
      fromId: 'node_156',
      toId: 'node_157',
      distanceMeters: 20.1,
      voiceInstruction: 'Bear right',
    ),
    // node_157 → node_158 (22.1m)
    CampusEdge(
      fromId: 'node_157',
      toId: 'node_158',
      distanceMeters: 22.1,
      voiceInstruction: 'Bear left',
    ),
    // node_158 → node_159 (21.3m)
    CampusEdge(
      fromId: 'node_158',
      toId: 'node_159',
      distanceMeters: 21.3,
      voiceInstruction: null,
    ),
    // node_159 → node_160 (22.9m)
    CampusEdge(
      fromId: 'node_159',
      toId: 'node_160',
      distanceMeters: 22.9,
      voiceInstruction: null,
    ),
    // node_160 → node_161 (22.8m)
    CampusEdge(
      fromId: 'node_160',
      toId: 'node_161',
      distanceMeters: 22.8,
      voiceInstruction: 'Bear left',
    ),
    // node_161 → node_162 (21.1m)
    CampusEdge(
      fromId: 'node_161',
      toId: 'node_162',
      distanceMeters: 21.1,
      voiceInstruction: null,
    ),
    // node_162 → node_163 (21.4m)
    CampusEdge(
      fromId: 'node_162',
      toId: 'node_163',
      distanceMeters: 21.4,
      voiceInstruction: null,
    ),
    // Junction connection: node_001 <-> node_114 (7.1m)
    CampusEdge(fromId: 'node_001', toId: 'node_114', distanceMeters: 7.1, voiceInstruction: null),
    // Junction connection: node_002 <-> node_113 (7.0m)
    CampusEdge(fromId: 'node_002', toId: 'node_113', distanceMeters: 7.0, voiceInstruction: null),
    // Junction connection: node_003 <-> node_112 (10.0m)
    CampusEdge(fromId: 'node_003', toId: 'node_112', distanceMeters: 10.0, voiceInstruction: null),
    // Junction connection: node_008 <-> node_108 (9.1m)
    CampusEdge(fromId: 'node_008', toId: 'node_108', distanceMeters: 9.1, voiceInstruction: null),
    // Junction connection: node_009 <-> node_107 (7.9m)
    CampusEdge(fromId: 'node_009', toId: 'node_107', distanceMeters: 7.9, voiceInstruction: null),
    // Junction connection: node_018 <-> node_023 (2.1m)
    CampusEdge(fromId: 'node_018', toId: 'node_023', distanceMeters: 2.1, voiceInstruction: null),
    // Junction connection: node_019 <-> node_022 (4.1m)
    CampusEdge(fromId: 'node_019', toId: 'node_022', distanceMeters: 4.1, voiceInstruction: null),
    // Junction connection: node_024 <-> node_061 (5.2m)
    CampusEdge(fromId: 'node_024', toId: 'node_061', distanceMeters: 5.2, voiceInstruction: null),
    // Junction connection: node_025 <-> node_060 (5.3m)
    CampusEdge(fromId: 'node_025', toId: 'node_060', distanceMeters: 5.3, voiceInstruction: null),
    // Junction connection: node_026 <-> node_059 (5.1m)
    CampusEdge(fromId: 'node_026', toId: 'node_059', distanceMeters: 5.1, voiceInstruction: null),
    // Junction connection: node_027 <-> node_058 (5.6m)
    CampusEdge(fromId: 'node_027', toId: 'node_058', distanceMeters: 5.6, voiceInstruction: null),
    // Junction connection: node_028 <-> node_057 (5.1m)
    CampusEdge(fromId: 'node_028', toId: 'node_057', distanceMeters: 5.1, voiceInstruction: null),
    // Junction connection: node_029 <-> node_056 (6.6m)
    CampusEdge(fromId: 'node_029', toId: 'node_056', distanceMeters: 6.6, voiceInstruction: null),
    // Junction connection: node_030 <-> node_055 (6.3m)
    CampusEdge(fromId: 'node_030', toId: 'node_055', distanceMeters: 6.3, voiceInstruction: null),
    // Junction connection: node_031 <-> node_054 (5.9m)
    CampusEdge(fromId: 'node_031', toId: 'node_054', distanceMeters: 5.9, voiceInstruction: null),
    // Junction connection: node_032 <-> node_053 (6.2m)
    CampusEdge(fromId: 'node_032', toId: 'node_053', distanceMeters: 6.2, voiceInstruction: null),
    // Junction connection: node_033 <-> node_051 (1.4m)
    CampusEdge(fromId: 'node_033', toId: 'node_051', distanceMeters: 1.4, voiceInstruction: null),
    // Junction connection: node_033 <-> node_052 (2.9m)
    CampusEdge(fromId: 'node_033', toId: 'node_052', distanceMeters: 2.9, voiceInstruction: null),
    // Junction connection: node_036 <-> node_039 (1.7m)
    CampusEdge(fromId: 'node_036', toId: 'node_039', distanceMeters: 1.7, voiceInstruction: null),
    // Junction connection: node_036 <-> node_040 (8.2m)
    CampusEdge(fromId: 'node_036', toId: 'node_040', distanceMeters: 8.2, voiceInstruction: null),
    // Junction connection: node_036 <-> node_050 (5.4m)
    CampusEdge(fromId: 'node_036', toId: 'node_050', distanceMeters: 5.4, voiceInstruction: null),
    // Junction connection: node_037 <-> node_049 (5.3m)
    CampusEdge(fromId: 'node_037', toId: 'node_049', distanceMeters: 5.3, voiceInstruction: null),
    // Junction connection: node_038 <-> node_049 (4.2m)
    CampusEdge(fromId: 'node_038', toId: 'node_049', distanceMeters: 4.2, voiceInstruction: null),
    // Junction connection: node_039 <-> node_050 (3.8m)
    CampusEdge(fromId: 'node_039', toId: 'node_050', distanceMeters: 3.8, voiceInstruction: null),
    // Junction connection: node_043 <-> node_047 (9.5m)
    CampusEdge(fromId: 'node_043', toId: 'node_047', distanceMeters: 9.5, voiceInstruction: null),
    // Junction connection: node_044 <-> node_046 (10.7m)
    CampusEdge(fromId: 'node_044', toId: 'node_046', distanceMeters: 10.7, voiceInstruction: null),
    // Junction connection: node_070 <-> node_105 (6.7m)
    CampusEdge(fromId: 'node_070', toId: 'node_105', distanceMeters: 6.7, voiceInstruction: null),
    // Junction connection: node_078 <-> node_093 (10.7m)
    CampusEdge(fromId: 'node_078', toId: 'node_093', distanceMeters: 10.7, voiceInstruction: null),
    // Junction connection: node_082 <-> node_084 (5.4m)
    CampusEdge(fromId: 'node_082', toId: 'node_084', distanceMeters: 5.4, voiceInstruction: null),
    // Junction connection: node_091 <-> node_094 (11.0m)
    CampusEdge(fromId: 'node_091', toId: 'node_094', distanceMeters: 11.0, voiceInstruction: null),
    // Junction connection: node_091 <-> node_095 (9.9m)
    CampusEdge(fromId: 'node_091', toId: 'node_095', distanceMeters: 9.9, voiceInstruction: null),
    // Junction connection: node_091 <-> node_096 (6.8m)
    CampusEdge(fromId: 'node_091', toId: 'node_096', distanceMeters: 6.8, voiceInstruction: null),
    // Junction connection: node_092 <-> node_095 (11.7m)
    CampusEdge(fromId: 'node_092', toId: 'node_095', distanceMeters: 11.7, voiceInstruction: null),
    // Junction connection: node_094 <-> node_097 (3.6m)
    CampusEdge(fromId: 'node_094', toId: 'node_097', distanceMeters: 3.6, voiceInstruction: null),
    // Junction connection: node_119 <-> node_127 (11.5m)
    CampusEdge(fromId: 'node_119', toId: 'node_127', distanceMeters: 11.5, voiceInstruction: null),
    // Junction connection: node_120 <-> node_126 (9.7m)
    CampusEdge(fromId: 'node_120', toId: 'node_126', distanceMeters: 9.7, voiceInstruction: null),
    // Junction connection: node_132 <-> node_160 (7.0m)
    CampusEdge(fromId: 'node_132', toId: 'node_160', distanceMeters: 7.0, voiceInstruction: null),
    // Junction connection: node_137 <-> node_141 (11.8m)
    CampusEdge(fromId: 'node_137', toId: 'node_141', distanceMeters: 11.8, voiceInstruction: null),
    // Junction connection: node_137 <-> node_142 (11.0m)
    CampusEdge(fromId: 'node_137', toId: 'node_142', distanceMeters: 11.0, voiceInstruction: null),
    // Junction connection: node_148 <-> node_155 (8.0m)
    CampusEdge(fromId: 'node_148', toId: 'node_155', distanceMeters: 8.0, voiceInstruction: null),
    // --- ADD MORE EDGES HERE ---
  ],
);