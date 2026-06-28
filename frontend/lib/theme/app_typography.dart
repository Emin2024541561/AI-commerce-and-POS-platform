/// app_typography.dart
///
/// Apple-style type scale. Uses the system font (SF Pro on iOS/macOS,
/// Roboto/Segoe fallback elsewhere) via `fontFamily: null` + platform
/// defaults, which is the closest free approximation of SF Pro without
/// bundling licensed font files.
///
/// OPTIONAL UPGRADE: if you want every platform (incl. web/Android) to
/// render the exact same geometric sans, add the `google_fonts` package
/// and swap the `_base` TextStyle's fontFamily for GoogleFonts.inter() or
/// GoogleFonts.plusJakartaSans() — both read as close SF Pro cousins.
/// Nothing else in this file needs to change if you do that swap.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String? fontFamily = null; // null = platform system font

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing ?? 0,
      height: height,
      color: color,
    );
  }

  // Large, hero-style numbers/headlines (dashboard stat, product price hero)
  static TextStyle largeTitle(Color color) =>
      _base(size: 34, weight: FontWeight.w700, letterSpacing: 0.37, color: color, height: 1.1);

  static TextStyle title1(Color color) =>
      _base(size: 28, weight: FontWeight.w700, letterSpacing: 0.36, color: color, height: 1.15);

  static TextStyle title2(Color color) =>
      _base(size: 22, weight: FontWeight.w700, letterSpacing: 0.35, color: color, height: 1.2);

  static TextStyle title3(Color color) =>
      _base(size: 20, weight: FontWeight.w600, letterSpacing: 0.38, color: color, height: 1.2);

  static TextStyle headline(Color color) =>
      _base(size: 17, weight: FontWeight.w600, letterSpacing: -0.41, color: color, height: 1.3);

  static TextStyle body(Color color) =>
      _base(size: 17, weight: FontWeight.w400, letterSpacing: -0.41, color: color, height: 1.4);

  static TextStyle bodyEmphasis(Color color) =>
      _base(size: 17, weight: FontWeight.w600, letterSpacing: -0.41, color: color, height: 1.4);

  static TextStyle callout(Color color) =>
      _base(size: 16, weight: FontWeight.w400, letterSpacing: -0.32, color: color, height: 1.35);

  static TextStyle subheadline(Color color) =>
      _base(size: 15, weight: FontWeight.w400, letterSpacing: -0.24, color: color, height: 1.3);

  static TextStyle footnote(Color color) =>
      _base(size: 13, weight: FontWeight.w400, letterSpacing: -0.08, color: color, height: 1.3);

  static TextStyle caption1(Color color) =>
      _base(size: 12, weight: FontWeight.w500, letterSpacing: 0, color: color, height: 1.25);

  static TextStyle caption2(Color color) =>
      _base(size: 11, weight: FontWeight.w600, letterSpacing: 0.06, color: color, height: 1.2);

  // Pill labels, badges, nav captions — uppercase tracked-out micro text
  static TextStyle eyebrow(Color color) => _base(
        size: 11,
        weight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color,
        height: 1.2,
      );

  /// Builds a full Material `TextTheme` for the given brightness, used
  /// inside AppTheme so widgets that read Theme.of(context).textTheme
  /// (e.g. default Text widgets, some Material internals) stay consistent.
  static TextTheme textTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondary = brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return TextTheme(
      displayLarge: largeTitle(primary),
      displayMedium: title1(primary),
      displaySmall: title2(primary),
      headlineMedium: title3(primary),
      headlineSmall: headline(primary),
      titleLarge: headline(primary),
      titleMedium: bodyEmphasis(primary),
      titleSmall: subheadline(primary),
      bodyLarge: body(primary),
      bodyMedium: callout(primary),
      bodySmall: subheadline(secondary),
      labelLarge: bodyEmphasis(primary),
      labelMedium: footnote(secondary),
      labelSmall: caption2(secondary),
    );
  }
}
