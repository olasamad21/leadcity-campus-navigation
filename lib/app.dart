import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/navigation_service.dart';
import 'data/buildings_data.dart';

/// Main app widget with MaterialApp configuration
class LeadCityNavigationApp extends StatefulWidget {
  const LeadCityNavigationApp({super.key});

  @override
  State<LeadCityNavigationApp> createState() => _LeadCityNavigationAppState();
}

class _LeadCityNavigationAppState extends State<LeadCityNavigationApp> {
  @override
  void initState() {
    super.initState();
    
    // Initialize API key from platform channel (Android/iOS native)
    // This allows the key to be stored in native code, not in Dart source
    _initializeApiKey();
    
    // Load KML data on app startup
    _loadKmlData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead City Navigation',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }

  /// Load KML building data asynchronously
  void _loadKmlData() {
    // Fire and forget - load asynchronously without blocking build
    Future.microtask(() async {
      try {
        await BuildingsData.loadFromKml();
      } catch (e) {
        // Silently fallback to hardcoded data on error
        debugPrint('Failed to load KML data: $e');
      }
    });
  }

  /// Initialize API key from native platform or environment
  /// In production, this should read from secure storage or native config
  /// 
  /// Priority:
  /// 1. Native method channel (if implemented in MainActivity)
  /// 2. Environment variable GOOGLE_MAPS_API_KEY
  /// 3. Fallback: Use the same key as Maps SDK (not recommended for production)
  void _initializeApiKey() {
    // Fire and forget - initialize asynchronously without blocking build
    Future.microtask(() async {
      try {
        // Try to get from native platform channel first
        const platform = MethodChannel('com.leadcity.navigation/api_key');
        final String? apiKey = await platform.invokeMethod('getApiKey');
        if (apiKey != null && apiKey.isNotEmpty) {
          NavigationService.setApiKey(apiKey);
          return;
        }
      } catch (e) {
        // Native method not implemented, continue to fallback
      }
      
      // Check if already set from environment variable
      if (NavigationService.apiKey.isEmpty) {
        // For development: Set API key manually for testing
        // TODO: Remove this before production - use secure storage instead
        // Uncomment and set your Directions API key for testing:
        // NavigationService.setApiKey('YOUR_DIRECTIONS_API_KEY_HERE');
      }
    });
  }
}

