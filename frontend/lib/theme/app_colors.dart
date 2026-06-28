/// app_colors.dart
///
/// Central color tokens for the entire app.
/// Nothing outside lib/theme should hardcode a Color(0x...) value —
/// always reference AppColors.* so the whole app re-themes from one file.
///
/// Dark mode is intentionally NOT pure black (#000000). Apple's own dark
/// surfaces sit around #0B0B0F–#1C1C22 so content has depth and shadows
/// still read. Pure black flattens everything and looks like a default
/// Material "invert the colors" dark mode, which is what we're avoiding.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // BRAND / ACCENT
  // ---------------------------------------------------------------------
  // A blue → violet accent gradient, used sparingly for primary actions,
  // active nav indicator, AI surfaces, and key CTAs. Not used as a flat
  // fill everywhere — that's what makes it feel premium instead of loud.
  static const Color accentBlue = Color(0xFF0A84FF); // iOS system blue
  static const Color accentViolet = Color(0xFF7C5CFF);
  static const Color accentTeal = Color(0xFF34D8C9); // secondary accent (AI / success)
  static const Color accentPink = Color(0xFFFF5C8A); // tertiary accent (deals/alerts)

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentViolet],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentViolet, accentTeal],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB454), Color(0xFFFF8A3D)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6961), Color(0xFFE8453C)],
  );

  // ---------------------------------------------------------------------
  // DARK MODE SURFACES (the primary theme)
  // ---------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0B0B0F);   // app scaffold
  static const Color darkBackgroundAlt = Color(0xFF101014); // secondary regions
  static const Color darkSurface = Color(0xFF1A1A20);       // cards, sheets
  static const Color darkSurfaceElevated = Color(0xFF22222A); // raised cards
  static const Color darkSurfaceHigh = Color(0xFF2B2B34);   // popovers/modals
  static const Color darkBorder = Color(0x14FFFFFF);        // 8% white hairline
  static const Color darkBorderStrong = Color(0x29FFFFFF);  // 16% white

  // Glass overlays for BackdropFilter panels (use with blur)
  static const Color darkGlassFill = Color(0x99161619);     // ~60% opaque panel
  static const Color darkGlassFillLight = Color(0x66222228); // lighter glass

  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextTertiary = Color(0xFF6E6E76);

  // ---------------------------------------------------------------------
  // LIGHT MODE SURFACES
  // ---------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF5F5F8);
  static const Color lightBackgroundAlt = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0x14000000);
  static const Color lightBorderStrong = Color(0x29000000);

  static const Color lightGlassFill = Color(0xCCFFFFFF);
  static const Color lightGlassFillLight = Color(0x99FFFFFF);

  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightTextTertiary = Color(0xFFA1A1A6);

  // ---------------------------------------------------------------------
  // SEMANTIC (shared across themes)
  // ---------------------------------------------------------------------
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFFB454);
  static const Color danger = Color(0xFFFF6961);
  static const Color info = Color(0xFF0A84FF);

  // Order/status specific
  static const Color statusPending = Color(0xFFFFB454);
  static const Color statusPreparing = Color(0xFF0A84FF);
  static const Color statusCompleted = Color(0xFF34D399);
  static const Color statusRejected = Color(0xFFFF6961);

  // ---------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------
  /// Returns the right color for the current theme brightness.
  static Color adaptive(BuildContext context, {required Color light, required Color dark}) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
