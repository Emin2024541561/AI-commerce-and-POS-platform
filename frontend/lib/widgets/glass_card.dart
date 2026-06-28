/// glass_card.dart
///
/// The default card surface for the whole app — product cards, dashboard
/// stat cards, AI result cards, list rows, etc. all wrap their content in
/// a GlassCard rather than a raw Container/Card so spacing, radius, blur,
/// and shadow stay consistent everywhere.
///
/// Two modes:
///  - GlassCard()              -> solid elevated surface with soft shadow
///                                 (use for most cards; cheap to render)
///  - GlassCard(translucent: true) -> true frosted glass with backdrop blur
///                                 (use sparingly — nav bar, AI panel,
///                                 modals over imagery — blur is costlier)
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'blurred_container.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius,
    this.translucent = false,
    this.onTap,
    this.glowColor,
    this.width,
    this.height,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool translucent;
  final VoidCallback? onTap;

  /// Optional soft colored glow behind the card (e.g. AppColors.accentViolet
  /// for AI cards). Leave null for standard cards.
  final Color? glowColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.lgRadius;

    Widget surface;
    if (translucent) {
      surface = BlurredContainer(
        blur: AppBlur.md,
        borderRadius: radius,
        padding: padding,
        width: width,
        height: height,
        gradientBorder: true,
        child: child,
      );
    } else {
      surface = Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          borderRadius: radius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: child,
      );
    }

    final wrapped = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: glowColor != null
            ? AppShadows.glow(glowColor!)
            : AppShadows.card(brightness),
      ),
      child: surface,
    );

    if (onTap == null) return wrapped;

    return _PressableScale(onTap: onTap!, child: wrapped);
  }
}

/// Shared "press to shrink slightly" interaction used by GlassCard and
/// PremiumButton — this is the tactile, springy feel that makes taps feel
/// alive instead of an instant Material ripple.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
