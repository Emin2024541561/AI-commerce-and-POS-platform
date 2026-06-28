/// blurred_container.dart
///
/// The lowest-level glass primitive: a BackdropFilter blur + translucent
/// fill + soft border, wrapped in a rounded clip. GlassCard, AnimatedNavBar,
/// and AiChatWidget all build on top of this — it's the one place that
/// actually calls ImageFilter.blur, so blur tuning happens in one spot.
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BlurredContainer extends StatelessWidget {
  const BlurredContainer({
    super.key,
    required this.child,
    this.blur = AppBlur.md,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.padding,
    this.width,
    this.height,
    this.gradientBorder = false,
  });

  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// When true, draws a 1px gradient stroke instead of a flat border —
  /// reads as glass catching ambient light. Use for hero surfaces (nav
  /// bar, AI panel), not every minor chip — it costs one extra layer.
  final bool gradientBorder;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.lgRadius;
    final fill = fillColor ?? (isDark ? AppColors.darkGlassFill : AppColors.lightGlassFill);
    final flatBorder = borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    Widget panel = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: gradientBorder ? null : radius,
        border: gradientBorder ? null : Border.all(color: flatBorder, width: 1),
      ),
      child: child,
    );

    final blurred = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: panel,
      ),
    );

    if (!gradientBorder) return blurred;

    // 1px gradient "stroke" achieved by padding a gradient-filled box and
    // clipping the blurred content inside it.
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppGradients.glassBorder(brightness),
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(borderRadius: radius, child: blurred),
    );
  }
}
