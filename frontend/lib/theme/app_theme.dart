/// app_theme.dart
///
/// The single entry point the rest of the app should import for theming.
/// Builds heavily-customized Material 3 ThemeData for both brightnesses so
/// default widgets (AppBar, TextField, Card, NavigationBar, etc.) already
/// look right even before you swap them for the custom widgets in
/// lib/widgets/. Wire this into MaterialApp in main.dart:
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system, // or drive from your existing app_bloc
///   ...
/// )
/// ```
///
/// Existing dark/light toggle logic in app_bloc / main.dart does NOT need
/// to change — it just needs to point at AppTheme.light / AppTheme.dark
/// instead of whatever ThemeData was being built inline before.
library app_theme;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_metrics.dart';

export 'app_colors.dart';
export 'app_typography.dart';
export 'app_metrics.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accentBlue,
      onPrimary: Colors.white,
      secondary: AppColors.accentViolet,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      // ignore: deprecated_member_use
      background: background,
      // ignore: deprecated_member_use
      onBackground: textPrimary,
      tertiary: AppColors.accentTeal,
      onTertiary: Colors.white,
      outline: border,
      surfaceContainerHighest: isDark
          ? AppColors.darkSurfaceElevated
          : AppColors.lightSurfaceElevated,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(brightness),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: AppTypography.title3(textPrimary),
      ),

      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgRadius,
          side: BorderSide(color: border, width: 1),
        ),
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      iconTheme: IconThemeData(color: textPrimary, size: 22),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: (isDark ? AppColors.darkSurfaceHigh : AppColors.lightBorderStrong),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: AppTypography.bodyEmphasis(Colors.white),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          textStyle: AppTypography.bodyEmphasis(AppColors.accentBlue),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        hintStyle: AppTypography.body(textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.6),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.caption2(selected ? AppColors.accentBlue : textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? AppColors.accentBlue : textSecondary, size: 24);
        }),
        indicatorColor: Colors.transparent,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        modalElevation: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        titleTextStyle: AppTypography.title3(textPrimary),
        contentTextStyle: AppTypography.body(textSecondary),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        side: BorderSide(color: border),
        labelStyle: AppTypography.footnote(textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.lightTextPrimary,
        contentTextStyle: AppTypography.body(isDark ? textPrimary : Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
