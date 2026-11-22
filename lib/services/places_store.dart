import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/buildings_data.dart';
import '../models/building.dart';

/// Recent destinations and saved (favourite) places, stored on the phone.
///
/// Screens listen to [recentIds] / [favoriteIds] and rebuild when they change.
class PlacesStore {
  PlacesStore._();
  static final PlacesStore instance = PlacesStore._();

  static const _recentKey = 'recent_destinations';
  static const _favoritesKey = 'favorite_places';
  static const maxRecents = 6;

  final ValueNotifier<List<String>> recentIds = ValueNotifier(const []);
  final ValueNotifier<List<String>> favoriteIds = ValueNotifier(const []);

  SharedPreferences? _prefs;

  /// Loads saved lists; safe to call more than once. Never throws.
  Future<void> load() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      recentIds.value = _prefs!.getStringList(_recentKey) ?? const [];
      favoriteIds.value = _prefs!.getStringList(_favoritesKey) ?? const [];
    } catch (e) {
      debugPrint('PlacesStore.load failed: $e');
    }
  }

  /// Puts [building] at the front of the recent list.
  Future<void> addRecent(Building building) async {
    if (building.id.startsWith('__')) return; // GPS / placeholders
    final next = [
      building.id,
      ...recentIds.value.where((id) => id != building.id),
    ].take(maxRecents).toList();
    recentIds.value = next;
    await _save(_recentKey, next);
  }

  Future<void> clearRecents() async {
    recentIds.value = const [];
    await _save(_recentKey, const []);
  }

  bool isFavorite(Building building) =>
      favoriteIds.value.contains(building.id);

  /// Saves or un-saves [building]; returns the new saved state.
  Future<bool> toggleFavorite(Building building) async {
    final saved = isFavorite(building);
    final next = saved
        ? favoriteIds.value.where((id) => id != building.id).toList()
        : [building.id, ...favoriteIds.value];
    favoriteIds.value = next;
    await _save(_favoritesKey, next);
    return !saved;
  }

  /// Resolves stored ids to buildings, skipping any no longer on the map.
  static List<Building> resolve(List<String> ids) => ids
      .map(BuildingsData.getBuildingById)
      .whereType<Building>()
      .toList();

  Future<void> _save(String key, List<String> value) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setStringList(key, value);
    } catch (e) {
      debugPrint('PlacesStore save failed: $e');
    }
  }
}
