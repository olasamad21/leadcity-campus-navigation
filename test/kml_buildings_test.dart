import 'package:flutter_test/flutter_test.dart';

import 'package:leadcity_navigation/services/kml_parser_service.dart';

/// Checks the bundled campus KML parses into usable, uniquely named buildings.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('campus KML parses into uniquely identified buildings', () async {
    final buildings = await KmlParserService()
        .parseKmlFile('assets/Lead City University Campus Map.kml');

    expect(buildings, isNotEmpty);

    final ids = buildings.map((b) => b.id).toList();
    final duplicates =
        ids.where((id) => ids.indexOf(id) != ids.lastIndexOf(id)).toSet();
    expect(duplicates, isEmpty, reason: 'duplicate building ids: $duplicates');

    for (final b in buildings) {
      expect(b.name.trim(), b.name, reason: 'untrimmed name "${b.name}"');
      expect(b.polygonCoordinates.length, greaterThanOrEqualTo(3),
          reason: '${b.name} has no usable polygon');
    }

    final names = buildings.map((b) => b.name).toSet();
    expect(names, containsAll(['Rebelation hall 1', 'Rebelation hall 2']));
  });
}
