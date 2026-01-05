import '../models/building.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/kml_parser_service.dart';

/// Campus building data
/// Loads buildings from KML file, with fallback to hardcoded data
class BuildingsData {
  // Lead City University approximate center coordinates
  static const LatLng _campusCenter = LatLng(7.3964, 3.9167);
  
  // Cache for KML-loaded buildings
  static List<Building>? _kmlBuildings;
  static bool _isLoading = false;
  static bool _loadAttempted = false;

  /// Load buildings from KML file
  static Future<List<Building>> loadFromKml() async {
    if (_kmlBuildings != null) {
      return _kmlBuildings!;
    }
    
    if (_isLoading) {
      // Wait for ongoing load
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _kmlBuildings ?? _getHardcodedBuildings();
    }
    
    _isLoading = true;
    _loadAttempted = true;
    
    try {
      final parser = KmlParserService();
      _kmlBuildings = await parser.parseKmlFile(
        'assets/Lead City University Campus Map.kml',
      );
      _isLoading = false;
      return _kmlBuildings!;
    } catch (e) {
      _isLoading = false;
      // Fallback to hardcoded data on error
      return _getHardcodedBuildings();
    }
  }

  /// Get all buildings (uses KML if loaded, otherwise hardcoded)
  static List<Building> getAllBuildings() {
    // If KML data is available, use it
    if (_kmlBuildings != null) {
      return _kmlBuildings!;
    }
    
    // If KML loading hasn't been attempted yet, return hardcoded
    // (KML will be loaded asynchronously in app startup)
    if (!_loadAttempted) {
      return _getHardcodedBuildings();
    }
    
    // If loading failed, return hardcoded as fallback
    return _getHardcodedBuildings();
  }

  /// Get hardcoded buildings (fallback data)
  static List<Building> _getHardcodedBuildings() {
    return [
      // Academic Buildings (17)
      Building(
        id: 'library',
        name: 'Library',
        type: 'Academic',
        entrancePoint: const LatLng(7.3960, 3.9165),
        polygonCoordinates: [
          const LatLng(7.3958, 3.9163),
          const LatLng(7.3962, 3.9163),
          const LatLng(7.3962, 3.9167),
          const LatLng(7.3958, 3.9167),
        ],
      ),
      Building(
        id: 'faculty_of_law',
        name: 'Faculty of Law',
        type: 'Academic',
        entrancePoint: const LatLng(7.3965, 3.9170),
        polygonCoordinates: [
          const LatLng(7.3963, 3.9168),
          const LatLng(7.3967, 3.9168),
          const LatLng(7.3967, 3.9172),
          const LatLng(7.3963, 3.9172),
        ],
      ),
      Building(
        id: 'faculty_of_engineering',
        name: 'Faculty of Engineering',
        type: 'Academic',
        entrancePoint: const LatLng(7.3970, 3.9165),
        polygonCoordinates: [
          const LatLng(7.3968, 3.9163),
          const LatLng(7.3972, 3.9163),
          const LatLng(7.3972, 3.9167),
          const LatLng(7.3968, 3.9167),
        ],
      ),
      Building(
        id: 'faculty_of_nursing_engineering',
        name: 'Faculty of Nursing/Engineering',
        type: 'Academic',
        entrancePoint: const LatLng(7.3975, 3.9170),
        polygonCoordinates: [
          const LatLng(7.3973, 3.9168),
          const LatLng(7.3977, 3.9168),
          const LatLng(7.3977, 3.9172),
          const LatLng(7.3973, 3.9172),
        ],
      ),
      Building(
        id: 'faculty_of_social_science',
        name: 'Faculty of Social Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3955, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3953, 3.9173),
          const LatLng(7.3957, 3.9173),
          const LatLng(7.3957, 3.9177),
          const LatLng(7.3953, 3.9177),
        ],
      ),
      Building(
        id: 'faculty_of_art',
        name: 'Faculty of Art',
        type: 'Academic',
        entrancePoint: const LatLng(7.3960, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3958, 3.9173),
          const LatLng(7.3962, 3.9173),
          const LatLng(7.3962, 3.9177),
          const LatLng(7.3958, 3.9177),
        ],
      ),
      Building(
        id: 'faculty_of_environmental_science',
        name: 'Faculty of Environmental Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3965, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3963, 3.9173),
          const LatLng(7.3967, 3.9173),
          const LatLng(7.3967, 3.9177),
          const LatLng(7.3963, 3.9177),
        ],
      ),
      Building(
        id: 'faculty_of_natural_applied_science',
        name: 'Faculty of Natural and Applied Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3970, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3968, 3.9173),
          const LatLng(7.3972, 3.9173),
          const LatLng(7.3972, 3.9177),
          const LatLng(7.3968, 3.9177),
        ],
      ),
      Building(
        id: 'faculty_of_dentistry',
        name: 'Faculty of Dentistry',
        type: 'Academic',
        entrancePoint: const LatLng(7.3975, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3973, 3.9173),
          const LatLng(7.3977, 3.9173),
          const LatLng(7.3977, 3.9177),
          const LatLng(7.3973, 3.9177),
        ],
      ),
      Building(
        id: 'computer_science',
        name: 'Department of Computer Science',
        type: 'Academic',
        entrancePoint: const LatLng(7.3950, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3948, 3.9158),
          const LatLng(7.3952, 3.9158),
          const LatLng(7.3952, 3.9162),
          const LatLng(7.3948, 3.9162),
        ],
      ),
      Building(
        id: 'college_of_medicine',
        name: 'College of Medicine',
        type: 'Academic',
        entrancePoint: const LatLng(7.3955, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3953, 3.9158),
          const LatLng(7.3957, 3.9158),
          const LatLng(7.3957, 3.9162),
          const LatLng(7.3953, 3.9162),
        ],
      ),
      Building(
        id: 'college_of_medicine_lecture_hub',
        name: 'College of Medicine Lecture Hub',
        type: 'Academic',
        entrancePoint: const LatLng(7.3960, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3958, 3.9158),
          const LatLng(7.3962, 3.9158),
          const LatLng(7.3962, 3.9162),
          const LatLng(7.3958, 3.9162),
        ],
      ),
      Building(
        id: 'law_theatre',
        name: 'Law Theatre',
        type: 'Academic',
        entrancePoint: const LatLng(7.3965, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3963, 3.9158),
          const LatLng(7.3967, 3.9158),
          const LatLng(7.3967, 3.9162),
          const LatLng(7.3963, 3.9162),
        ],
      ),
      Building(
        id: 'lecture_rooms_11_13',
        name: 'Lecture Rooms 11-13',
        type: 'Academic',
        entrancePoint: const LatLng(7.3970, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3968, 3.9158),
          const LatLng(7.3972, 3.9158),
          const LatLng(7.3972, 3.9162),
          const LatLng(7.3968, 3.9162),
        ],
      ),
      Building(
        id: 'lecture_rooms_14_16',
        name: 'Lecture Rooms 14-16',
        type: 'Academic',
        entrancePoint: const LatLng(7.3975, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3973, 3.9158),
          const LatLng(7.3977, 3.9158),
          const LatLng(7.3977, 3.9162),
          const LatLng(7.3973, 3.9162),
        ],
      ),
      Building(
        id: 'adeline_hall',
        name: 'Adeline Hall',
        type: 'Academic',
        entrancePoint: const LatLng(7.3950, 3.9170),
        polygonCoordinates: [
          const LatLng(7.3948, 3.9168),
          const LatLng(7.3952, 3.9168),
          const LatLng(7.3952, 3.9172),
          const LatLng(7.3948, 3.9172),
        ],
      ),
      Building(
        id: 'conference_center',
        name: 'Conference Center',
        type: 'Academic',
        entrancePoint: const LatLng(7.3950, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3948, 3.9173),
          const LatLng(7.3952, 3.9173),
          const LatLng(7.3952, 3.9177),
          const LatLng(7.3948, 3.9177),
        ],
      ),
      
      // Administrative (2)
      Building(
        id: 'senate_building',
        name: 'Senate Building',
        type: 'Administrative',
        entrancePoint: const LatLng(7.3955, 3.9155),
        polygonCoordinates: [
          const LatLng(7.3953, 3.9153),
          const LatLng(7.3957, 3.9153),
          const LatLng(7.3957, 3.9157),
          const LatLng(7.3953, 3.9157),
        ],
      ),
      Building(
        id: 'radio_station',
        name: 'Radio Station',
        type: 'Administrative',
        entrancePoint: const LatLng(7.3960, 3.9155),
        polygonCoordinates: [
          const LatLng(7.3958, 3.9153),
          const LatLng(7.3962, 3.9153),
          const LatLng(7.3962, 3.9157),
          const LatLng(7.3958, 3.9157),
        ],
      ),
      
      // Religious (2)
      Building(
        id: 'chapel',
        name: 'Chapel',
        type: 'Religious',
        entrancePoint: const LatLng(7.3965, 3.9155),
        polygonCoordinates: [
          const LatLng(7.3963, 3.9153),
          const LatLng(7.3967, 3.9153),
          const LatLng(7.3967, 3.9157),
          const LatLng(7.3963, 3.9157),
        ],
      ),
      Building(
        id: 'mosque',
        name: 'Mosque',
        type: 'Religious',
        entrancePoint: const LatLng(7.3970, 3.9155),
        polygonCoordinates: [
          const LatLng(7.3968, 3.9153),
          const LatLng(7.3972, 3.9153),
          const LatLng(7.3972, 3.9157),
          const LatLng(7.3968, 3.9157),
        ],
      ),
      
      // Medical (1)
      Building(
        id: 'clinic',
        name: 'Clinic',
        type: 'Medical',
        entrancePoint: const LatLng(7.3975, 3.9155),
        polygonCoordinates: [
          const LatLng(7.3973, 3.9153),
          const LatLng(7.3977, 3.9153),
          const LatLng(7.3977, 3.9157),
          const LatLng(7.3973, 3.9157),
        ],
      ),
      
      // Residential (3)
      Building(
        id: 'champions_hostel',
        name: 'Champions Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3945, 3.9165),
        polygonCoordinates: [
          const LatLng(7.3943, 3.9163),
          const LatLng(7.3947, 3.9163),
          const LatLng(7.3947, 3.9167),
          const LatLng(7.3943, 3.9167),
        ],
      ),
      Building(
        id: 'wisdom_hostel',
        name: 'Wisdom Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3945, 3.9170),
        polygonCoordinates: [
          const LatLng(7.3943, 3.9168),
          const LatLng(7.3947, 3.9168),
          const LatLng(7.3947, 3.9172),
          const LatLng(7.3943, 3.9172),
        ],
      ),
      Building(
        id: 'independence_hostel',
        name: 'Independence Hostel',
        type: 'Residential',
        entrancePoint: const LatLng(7.3945, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3943, 3.9173),
          const LatLng(7.3947, 3.9173),
          const LatLng(7.3947, 3.9177),
          const LatLng(7.3943, 3.9177),
        ],
      ),
      
      // Recreation & Dining (4)
      Building(
        id: 'tasty_vine',
        name: 'Tasty Vine',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3980, 3.9165),
        polygonCoordinates: [
          const LatLng(7.3978, 3.9163),
          const LatLng(7.3982, 3.9163),
          const LatLng(7.3982, 3.9167),
          const LatLng(7.3978, 3.9167),
        ],
      ),
      Building(
        id: 'new_tasty_vine',
        name: 'New Tasty Vine',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3980, 3.9170),
        polygonCoordinates: [
          const LatLng(7.3978, 3.9168),
          const LatLng(7.3982, 3.9168),
          const LatLng(7.3982, 3.9172),
          const LatLng(7.3978, 3.9172),
        ],
      ),
      Building(
        id: 'cresta',
        name: 'Cresta',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3980, 3.9175),
        polygonCoordinates: [
          const LatLng(7.3978, 3.9173),
          const LatLng(7.3982, 3.9173),
          const LatLng(7.3982, 3.9177),
          const LatLng(7.3978, 3.9177),
        ],
      ),
      Building(
        id: 'stadium',
        name: 'Stadium',
        type: 'Recreation/Dining',
        entrancePoint: const LatLng(7.3980, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3978, 3.9158),
          const LatLng(7.3982, 3.9158),
          const LatLng(7.3982, 3.9162),
          const LatLng(7.3978, 3.9162),
        ],
      ),
      
      // Facilities (1)
      Building(
        id: 'car_park',
        name: 'Car Park',
        type: 'Facilities',
        entrancePoint: const LatLng(7.3940, 3.9160),
        polygonCoordinates: [
          const LatLng(7.3938, 3.9158),
          const LatLng(7.3942, 3.9158),
          const LatLng(7.3942, 3.9162),
          const LatLng(7.3938, 3.9162),
        ],
      ),
    ];
  }

  /// Get building by ID
  static Building? getBuildingById(String id) {
    try {
      return getAllBuildings().firstWhere(
        (building) => building.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get building by name
  static Building? getBuildingByName(String name) {
    try {
      return getAllBuildings().firstWhere(
        (building) => building.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Search buildings by query
  static List<Building> searchBuildings(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllBuildings().where((building) {
      return building.name.toLowerCase().contains(lowerQuery) ||
          building.type.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

