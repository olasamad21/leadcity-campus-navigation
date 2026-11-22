import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'premium/gradient_button.dart';
import 'premium/motion.dart';

const _explainedKey = 'location_explained';

/// Explains why the app needs location before Android shows its own prompt.
///
/// Shown once; returns true to continue to the system prompt, false if the
/// user chose "Not now". Already-granted permission skips the sheet.
Future<bool> explainLocationIfNeeded(BuildContext context) async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_explainedKey) ?? false) return true;
    if (!context.mounted) return false;

    final allow = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LocationSheet(),
    );
    if (allow == true) await prefs.setBool(_explainedKey, true);
    return allow == true;
  } catch (_) {
    return true; // Never block the flow on a storage/plugin hiccup.
  }
}

/// Snackbar for a failed location request, with a shortcut to settings.
void showLocationUnavailable(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Settings',
        textColor: AppColors.accent,
        onPressed: () async {
          final serviceOn = await Geolocator.isLocationServiceEnabled();
          if (serviceOn) {
            await Geolocator.openAppSettings();
          } else {
            await Geolocator.openLocationSettings();
          }
        },
      ),
    ));
}

class _LocationSheet extends StatelessWidget {
  const _LocationSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(color: cs.surface, borderRadius: AppRadius.sheet),
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, 20 + MediaQuery.of(context).viewPadding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.route.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location_rounded,
                size: 42, color: AppColors.route),
          ).popIn(),
          const SizedBox(height: AppSpace.lg),
          Text('Use your location?', style: text.displayMedium)
              .fadeSlideIn(index: 1),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Your location is used only on this phone to show where you are '
            'and guide you turn by turn. It is never uploaded or shared.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ).fadeSlideIn(index: 2),
          const SizedBox(height: AppSpace.lg),
          GradientButton(
            label: 'Allow location',
            icon: Icons.check_rounded,
            onPressed: () => Navigator.pop(context, true),
          ).fadeSlideIn(index: 3),
          const SizedBox(height: AppSpace.xs),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
        ],
      ),
    );
  }
}
