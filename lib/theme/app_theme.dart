import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'page_transitions.dart';

/// Light and dark themes built from the shared tokens.
///
/// Text roles used across the app:
///  displayLarge  – hero titles        displayMedium – screen titles
///  displaySmall  – card / section titles
///  bodyLarge/Medium/Small – body copy  labelLarge – buttons
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final canvas = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final card = isDark ? AppColors.darkSurface : AppColors.background;
    final field = isDark ? AppColors.darkSurfaceHigh : AppColors.surface;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final brandOnSurface = isDark ? AppColors.primaryLight : AppColors.primary;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF8D9CE0) : AppColors.primary,
      onPrimary: isDark ? AppColors.primaryDeep : Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.primaryDeep,
      tertiary: AppColors.route,
      surface: card,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: field,
      outline: divider,
      outlineVariant: divider,
      error: AppColors.error,
      onError: Colors.white,
    );

    final base = GoogleFonts.plusJakartaSansTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final textTheme = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.15,
        color: isDark ? textPrimary : AppColors.primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: isDark ? textPrimary : AppColors.primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        color: textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        color: textPrimary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.4,
        color: textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: textSecondary,
      ),
    );

    const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    const buttonSize = Size(double.infinity, 54);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: canvas,
      splashFactory: InkSparkle.splashFactory,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(),
          TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: divider.withValues(alpha: isDark ? 1 : 0.7)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: divider,
          elevation: 0,
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandOnSurface,
          side: BorderSide(color: divider, width: 1.5),
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandOnSurface,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: brandOnSurface, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.error, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: field,
        selectedColor: AppColors.primary,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: textPrimary),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: card,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.primaryDeep,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brandOnSurface,
        linearTrackColor: divider,
        circularTrackColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),

      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),
    );
  }
}
