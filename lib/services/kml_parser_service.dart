import 'dart:async';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/building.dart';

/// Service for parsing KML files from Google My Maps
class KmlParserService {
  static final KmlParserService _instance = KmlParserService._internal();
  factory KmlParserService() => _instance;
  KmlParserService._internal();

  /// Parse KML file and return list of buildings
  Future<List<Building>> parseKmlFile(String assetPath) async {
    try {
      // Load KML file from assets
      final String kmlString = await rootBundle.loadString(assetPath);
      
      // Parse XML
      final XmlDocument document = XmlDocument.parse(kmlString);
      
      // Extract all Placemarks
      final List<XmlElement> placemarks = document
          .findAllElements('Placemark')
          .whereType<XmlElement>()
          .toList();

      // Separate buildings and entrances
      final Map<String, XmlElement> buildings = {};
      final Map<String, LatLng> entrances = {};

      for (var placemark in placemarks) {
        final nameElement = placemark.findElements('name').firstOrNull;
        if (nameElement == null) continue;

        final name = nameElement.innerText.trim();
        
        // Check if it's a building (has Polygon)
        final polygon = placemark.findElements('Polygon').firstOrNull;
        if (polygon != null) {
          buildings[name] = placemark;
        }
        
        // Check if it's an entrance (has Point and name contains "Entrance")
        final point = placemark.findElements('Point').firstOrNull;
        if (point != null && name.toLowerCase().contains('entrance')) {
          final coordinates = point.findElements('coordinates').firstOrNull;
          if (coordinates != null) {
            final latLng = _parseCoordinates(coordinates.innerText.trim());
            if (latLng != null) {
              // Extract building name from entrance name
              // e.g., "Clinic Entrance" -> "Clinic"
              // Handle variations: "Entrance", " Entrance", etc.
              String buildingName = name
                  .replaceAll(RegExp(r'\s*[Ee]ntrance\s*$'), '')
                  .trim();
              
              // Handle special cases
              if (buildingName.toLowerCase().contains('boys hostel')) {
                buildingName = 'Champions Hostel';
              } else if (buildingName.toLowerCase() == 'department of computer science') {
                buildingName = 'Department of Computer Science';
              }
              
              // Store entrance (use first one found if multiple)
              if (!entrances.containsKey(buildingName)) {
                entrances[buildingName] = latLng;
              }
            }
          }
        }
      }

      // Create Building objects
      final List<Building> buildingList = [];
      
      for (var entry in buildings.entries) {
        final buildingName = entry.key;
        final placemark = entry.value;
        
        // Parse polygon coordinates with validation
        final polygon = placemark.findElements('Polygon').firstOrNull;
        if (polygon == null) {
          // Skip buildings without polygon
          continue;
        }
        
        final outerBoundary = polygon.findElements('outerBoundaryIs').firstOrNull;
        if (outerBoundary == null) {
          // Skip buildings without outer boundary
          continue;
        }
        
        final linearRing = outerBoundary.findElements('LinearRing').firstOrNull;
        if (linearRing == null) {
          // Skip buildings without linear ring
          continue;
        }
        
        final coordinatesElement = linearRing.findElements('coordinates').firstOrNull;
        if (coordinatesElement == null) {
          // Skip buildings without coordinates
          continue;
        }
        
        final polygonCoordinates = _parsePolygonCoordinates(
          coordinatesElement.innerText.trim(),
        );
        
        if (polygonCoordinates.isEmpty) {
          // Skip buildings with empty coordinates
          continue;
        }
        
        // Get entrance point (match by building name)
        LatLng entrancePoint;
        if (entrances.containsKey(buildingName)) {
          entrancePoint = entrances[buildingName]!;
        } else {
          // Try fuzzy matching for entrance names
          LatLng? matchedEntrance = _findMatchingEntrance(buildingName, entrances);
          if (matchedEntrance != null) {
            entrancePoint = matchedEntrance;
          } else {
            // Calculate centroid if no entrance found
            entrancePoint = _calculateCentroid(polygonCoordinates);
          }
        }
        
        // Infer building type from name
        final buildingType = _inferBuildingType(buildingName);
        
        // Generate ID from name
        final id = _generateId(buildingName);
        
        buildingList.add(
          Building(
            id: id,
            name: buildingName,
            type: buildingType,
            entrancePoint: entrancePoint,
            polygonCoordinates: polygonCoordinates,
          ),
        );
      }

      return buildingList;
    } catch (e) {
      throw Exception('Failed to parse KML file: $e');
    }
  }

  /// Parse coordinate string from KML format (longitude,latitude,altitude)
  /// Returns LatLng (latitude, longitude)
  LatLng? _parseCoordinates(String coordinateString) {
    try {
      // KML format: "longitude,latitude,altitude"
      // May have multiple coordinates separated by spaces or newlines
      final parts = coordinateString.trim().split(RegExp(r'[\s\n]+'));
      if (parts.isEmpty) return null;
      
      // Take first coordinate
      final coordParts = parts[0].split(',');
      if (coordParts.length < 2) return null;
      
      final longitude = double.parse(coordParts[0].trim());
      final latitude = double.parse(coordParts[1].trim());
      
      // Convert from KML (lon,lat) to LatLng (lat,lon)
      return LatLng(latitude, longitude);
    } catch (e) {
      return null;
    }
  }

  /// Parse polygon coordinates from KML
  List<LatLng> _parsePolygonCoordinates(String coordinatesString) {
    final List<LatLng> coordinates = [];
    
    // Split by whitespace (KML coordinates are space-separated)
    final parts = coordinatesString.trim().split(RegExp(r'[\s\n]+'));
    
    for (var part in parts) {
      if (part.trim().isEmpty) continue;
      
      final latLng = _parseCoordinates(part);
      if (latLng != null) {
        coordinates.add(latLng);
      }
    }
    
    return coordinates;
  }

  /// Calculate centroid of polygon
  LatLng _calculateCentroid(List<LatLng> coordinates) {
    if (coordinates.isEmpty) {
      return const LatLng(7.3964, 3.9167); // Default campus center
    }
    
    double sumLat = 0;
    double sumLng = 0;
    
    for (var coord in coordinates) {
      sumLat += coord.latitude;
      sumLng += coord.longitude;
    }
    
    return LatLng(
      sumLat / coordinates.length,
      sumLng / coordinates.length,
    );
  }

  /// Infer building type from name
  String _inferBuildingType(String name) {
    final lower = name.toLowerCase();
    
    if (lower.contains('faculty') || 
        lower.contains('college') || 
        lower.contains('department') || 
        lower.contains('lecture') ||
        lower.contains('library') ||
        lower.contains('theatre') ||
        lower.contains('hall') && !lower.contains('hostel')) {
      return 'Academic';
    } else if (lower.contains('hostel')) {
      return 'Residential';
    } else if (lower.contains('clinic') || lower.contains('medical') || lower.contains('nursing')) {
      return 'Medical';
    } else if (lower.contains('chapel') || lower.contains('mosque')) {
      return 'Religious';
    } else if (lower.contains('stadium') || 
               lower.contains('vine') || 
               lower.contains('cresta') || 
               lower.contains('restaurant') ||
               lower.contains('cafeteria')) {
      return 'Recreation/Dining';
    } else if (lower.contains('senate') || lower.contains('radio')) {
      return 'Administrative';
    } else if (lower.contains('park')) {
      return 'Facilities';
    }
    
    return 'Academic'; // Default
  }

  /// Generate ID from building name
  String _generateId(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Find matching entrance using fuzzy matching
  LatLng? _findMatchingEntrance(String buildingName, Map<String, LatLng> entrances) {
    final lowerBuildingName = buildingName.toLowerCase();
    
    // Try exact match first
    for (var entry in entrances.entries) {
      if (entry.key.toLowerCase() == lowerBuildingName) {
        return entry.value;
      }
    }
    
    // Try partial match
    for (var entry in entrances.entries) {
      final lowerEntranceName = entry.key.toLowerCase();
      if (lowerBuildingName.contains(lowerEntranceName) || 
          lowerEntranceName.contains(lowerBuildingName)) {
        return entry.value;
      }
    }
    
    return null;
  }
}

