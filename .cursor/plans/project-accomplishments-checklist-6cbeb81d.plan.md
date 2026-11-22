<!-- 6cbeb81d-2ab4-428c-aef9-9fa015da59a2 862a92a6-7f27-487b-8763-0e5abfe099ce -->
# KML Integration Implementation Plan

## Current Status

### ✅ Completed

- KML file located: `assets/Lead City University Campus Map.kml`
- File structure analyzed

### KML File Analysis Results

**File Structure:**

- **Total Placemarks:** 122
- **Building Polygons:** ~42 (one per building)
- **Entrance Points:** ~80 (multiple entrances per building in some cases)

**Structure Details:**

- Each building has a `<Placemark>` with:
  - `<name>` - Building name (e.g., "Clinic", "Champions Hostel")
  - `<Polygon>` - Building footprint with coordinates
- Each entrance has a separate `<Placemark>` with:
  - `<name>` - Building name + " Entrance" (e.g., "Clinic Entrance")
  - `<Point>` - Entrance coordinates

**Coordinate Format:**

- KML uses: `longitude,latitude,altitude`
- Flutter LatLng needs: `LatLng(latitude, longitude)`
- **Critical:** Must swap coordinate order when converting!

## Implementation Steps

### Step 1: Update pubspec.yaml

- [ ] Add XML parser dependency: `xml: ^6.0.0`
- [ ] Add KML file to assets section: `- assets/Lead City University Campus Map.kml`
- [ ] Run `flutter pub get`

### Step 2: Create KML Parser Service

**File:** `lib/services/kml_parser_service.dart`

**Required Features:**

- Parse KML XML structure
- Extract all Placemark elements
- Identify building Placemarks (contain Polygon)
- Identify entrance Placemarks (contain Point + name ends with "Entrance")
- Match entrances to buildings by name
- Convert coordinates: KML `lon,lat` → Flutter `LatLng(lat, lon)`
- Infer building type from name (e.g., "Faculty of..." = Academic)
- Return List<Building> with matched entrances

**Parser Logic:**

1. Load KML file from assets
2. Parse XML structure
3. Separate Placemarks into:

   - Buildings (has Polygon)
   - Entrances (has Point + name contains "Entrance")

4. Match entrances to buildings:

   - Extract building name from entrance name (remove " Entrance")
   - Find matching building Placemark
   - Use first entrance found, or calculate centroid if multiple

5. Convert coordinates and create Building objects

### Step 3: Refactor BuildingsData

**File:** `lib/data/buildings_data.dart`

**Changes:**

- Add static variable to cache parsed buildings
- Add async method `loadFromKml()` that:
  - Calls KmlParserService
  - Caches results
  - Returns List<Building>
- Modify `getAllBuildings()` to:
  - Check if KML data is loaded
  - Return KML data if available
  - Fallback to hardcoded data if KML fails
- Keep hardcoded data as fallback for error cases

### Step 4: Initialize KML Loading

**File:** `lib/app.dart` or `lib/main.dart`

**Changes:**

- Load KML data on app startup
- Use Future.microtask or initState
- Handle errors gracefully (fallback to hardcoded)

### Step 5: Testing

- [ ] Verify all 42 buildings load correctly
- [ ] Test coordinate accuracy (check lon/lat swap)
- [ ] Validate polygon rendering on map
- [ ] Verify entrance points match buildings
- [ ] Test error handling (invalid KML, missing file)

## Key Implementation Details

### Coordinate Conversion

```dart
// KML format: "longitude,latitude,altitude"
// Example: "3.8778471,7.3273049,0"
final parts = coordinateString.split(',');
final longitude = double.parse(parts[0]);
final latitude = double.parse(parts[1]);
// Flutter LatLng: LatLng(latitude, longitude)
return LatLng(latitude, longitude);
```

### Building Type Inference

```dart
String inferBuildingType(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('faculty') || lower.contains('college') || 
      lower.contains('department') || lower.contains('lecture')) {
    return 'Academic';
  } else if (lower.contains('hostel')) {
    return 'Residential';
  } else if (lower.contains('clinic') || lower.contains('medical')) {
    return 'Medical';
  } else if (lower.contains('chapel') || lower.contains('mosque')) {
    return 'Religious';
  } else if (lower.contains('stadium') || lower.contains('vine') || 
             lower.contains('cresta') || lower.contains('restaurant')) {
    return 'Recreation/Dining';
  } else if (lower.contains('senate') || lower.contains('radio')) {
    return 'Administrative';
  } else if (lower.contains('park')) {
    return 'Facilities';
  }
  return 'Academic'; // Default
}
```

### Entrance Matching

```dart
// Entrance name: "Clinic Entrance"
// Building name: "Clinic"
// Match by removing " Entrance" and comparing
String buildingName = entranceName.replaceAll(' Entrance', '').trim();
```

## Files to Create/Modify

1. **NEW:** `lib/services/kml_parser_service.dart`
2. **MODIFY:** `lib/data/buildings_data.dart`
3. **MODIFY:** `pubspec.yaml`
4. **MODIFY:** `lib/app.dart` (or `lib/main.dart`)

## Priority

**HIGH** - This is the critical missing GIS data integration

## Estimated Effort

- KML Parser: 2-3 hours
- BuildingsData refactor: 1 hour
- Testing & debugging: 1-2 hours
- **Total: 4-6 hours**

---

**Ready to implement when you give the go-ahead!**