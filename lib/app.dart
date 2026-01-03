import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/navigation_service.dart';

/// Main app widget with MaterialApp configuration
class LeadCityNavigationApp extends StatelessWidget {
  const LeadCityNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API key from platform channel (Android/iOS native)
    // This allows the key to be stored in native code, not in Dart source
    _initializeApiKey();
    
    return MaterialApp(
      title: 'Lead City Navigation',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
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

