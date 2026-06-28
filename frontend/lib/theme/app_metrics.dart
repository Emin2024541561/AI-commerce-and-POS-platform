/// app_metrics.dart
///
/// Spacing, radius, elevation/shadow, and blur tokens. Keeping these as
/// named constants (instead of magic numbers like `16.0` scattered through
/// screens) is what makes the "premium spacing" consistent app-wide and
/// lets you retune the entire app's density from one place.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Outer page padding — matches iOS's standard 16–20pt margins, widens
  /// slightly on tablet/desktop via [responsivePagePadding].
  static EdgeInsets responsivePagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 24);
    } else if (width >= 700) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  }
}

class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

class AppBlur {
  AppBlur._();

  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 36;
}

class AppShadows {
  AppShadows._();

  /// Soft, low-opacity shadow for cards at rest. Apple-style shadows are
  /// large, soft, and faint — never the harsh `black 0.3` Material default.
  static List<BoxShadow> card(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withOpacity(0.45)
        : Colors.black.withOpacity(0.08);
    return [
      BoxShadow(color: color, blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -4),
    ];
  }

  /// Slightly stronger shadow for raised / pressed-state elements (floating
  /// nav bar, modals, popovers).
  static List<BoxShadow> elevated(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withOpacity(0.55)
        : Colors.black.withOpacity(0.12);
    return [
      BoxShadow(color: color, blurRadius: 32, offset: const Offset(0, 12), spreadRadius: -6),
    ];
  }

  /// Colored glow used behind AI surfaces / primary CTAs to suggest depth
  /// and energy without a hard shadow. Use sparingly — one glow per screen.
  static List<BoxShadow> glow(Color color, {double opacity = 0.35}) {
    return [
      BoxShadow(color: color.withOpacity(opacity), blurRadius: 32, spreadRadius: -4),
    ];
  }

  static List<BoxShadow> none = const [];
}

/// Convenience gradient borders for glass panels — a 1px gradient stroke
/// reads as "glass catching light" far better than a flat hairline.
class AppGradients {
  AppGradients._();

  static LinearGradient glassBorder(Brightness brightness) {
    return brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF)],
          );
  }

  static LinearGradient scrim(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        (brightness == Brightness.dark ? AppColors.darkBackground : Colors.black)
            .withOpacity(0.55),
      ],
    );
  }
}
