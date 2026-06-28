/// premium_button.dart
///
/// Replaces raw ElevatedButton/TextButton calls in screens. Provides the
/// "Apple Pay style" pill button with a soft press-scale animation, an
/// optional gradient fill, loading spinner state, and icon support — used
/// for "Add to cart", "Checkout", "Accept order", POS "Charge", etc.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PremiumButtonVariant { primary, secondary, ghost, destructive, success }

enum PremiumButtonSize { regular, large, compact }

class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.size = PremiumButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final PremiumButtonSize size;
  final IconData? icon;
  final bool isLoading;

  /// If true, button fills available width (use inside a fixed-width
  /// parent — e.g. checkout sheet, POS charge button).
  final bool expand;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final verticalPad = switch (widget.size) {
      PremiumButtonSize.large => AppSpacing.lg,
      PremiumButtonSize.regular => AppSpacing.md,
      PremiumButtonSize.compact => AppSpacing.sm,
    };
    final fontSize = widget.size == PremiumButtonSize.compact ? 14.0 : 17.0;

    final colors = _resolveColors(isDark);

    Widget content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.foreground),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: fontSize + 2, color: colors.foreground),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: AppTypography.bodyEmphasis(colors.foreground).copyWith(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    final button = AnimatedScale(
      scale: _pressed && _enabled ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: widget.expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: verticalPad),
        decoration: BoxDecoration(
          color: colors.solidFill,
          gradient: colors.gradientFill,
          borderRadius: AppRadius.pillRadius,
          border: colors.border,
          boxShadow: _enabled && colors.glow != null ? AppShadows.glow(colors.glow!, opacity: 0.3) : null,
        ),
        child: Opacity(opacity: _enabled ? 1.0 : 0.45, child: content),
      ),
    );

    return GestureDetector(
      onTap: _enabled ? widget.onPressed : null,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: button,
    );
  }

  _ButtonColors _resolveColors(bool isDark) {
    switch (widget.variant) {
      case PremiumButtonVariant.primary:
        return _ButtonColors(
          foreground: Colors.white,
          gradientFill: AppColors.accentGradient,
          glow: AppColors.accentBlue,
        );
      case PremiumButtonVariant.success:
        return _ButtonColors(
          foreground: Colors.white,
          gradientFill: AppColors.successGradient,
          glow: AppColors.success,
        );
      case PremiumButtonVariant.destructive:
        return _ButtonColors(
          foreground: Colors.white,
          gradientFill: AppColors.dangerGradient,
          glow: AppColors.danger,
        );
      case PremiumButtonVariant.secondary:
        return _ButtonColors(
          foreground: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          solidFill: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          border: Border.all(color: isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong),
        );
      case PremiumButtonVariant.ghost:
        return _ButtonColors(
          foreground: AppColors.accentBlue,
          solidFill: Colors.transparent,
        );
    }
  }
}

class _ButtonColors {
  _ButtonColors({
    required this.foreground,
    this.solidFill,
    this.gradientFill,
    this.border,
    this.glow,
  });
  final Color foreground;
  final Color? solidFill;
  final Gradient? gradientFill;
  final BoxBorder? border;
  final Color? glow;
}
