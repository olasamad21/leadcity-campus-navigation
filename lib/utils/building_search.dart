import '../models/building.dart';

/// Ranked, forgiving building search.
///
/// Matches whole-name prefixes first, then word prefixes ("law" → "Faculty of
/// Law"), then substrings, then category ("hostel", "food"). Spaces,
/// punctuation and case are ignored, so "lecture room 11" and "lectureroom11"
/// both work.
List<Building> searchBuildings(List<Building> buildings, String query) {
  final q = _norm(query);
  if (q.isEmpty) return List.of(buildings);

  final scored = <(Building, int)>[];
  for (final b in buildings) {
    final score = _score(b, q, query.trim().toLowerCase());
    if (score > 0) scored.add((b, score));
  }
  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    return byScore != 0 ? byScore : a.$1.name.compareTo(b.$1.name);
  });
  return [for (final s in scored) s.$1];
}

int _score(Building b, String q, String rawQuery) {
  final name = _norm(b.name);
  if (name == q) return 100;
  if (name.startsWith(q)) return 80;

  final words = b.name.toLowerCase().split(RegExp(r'[^a-z0-9]+'))
    ..removeWhere((w) => w.isEmpty);
  if (words.any((w) => w.startsWith(rawQuery))) return 60;

  // Initials, e.g. "cs" → Computer Science, "pg" → PG Hostel.
  final initials = words
      .where((w) => !const {'of', 'and', 'the'}.contains(w))
      .map((w) => w[0])
      .join();
  if (q.length >= 2 && initials.contains(q)) return 45;

  if (name.contains(q)) return 40;

  final cat = b.category;
  if (_norm(cat.label).startsWith(q) || _norm(cat.pluralLabel).startsWith(q)) {
    return 20;
  }
  return 0;
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
