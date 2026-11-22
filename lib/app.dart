import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

/// Root widget. Campus data and saved places are loaded by [SplashScreen];
/// the Google Maps key is supplied natively (android/local.properties).
class LeadCityNavigationApp extends StatelessWidget {
  const LeadCityNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead City Navigation',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
