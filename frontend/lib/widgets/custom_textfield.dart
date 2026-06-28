/// custom_textfield.dart
///
/// iOS-style input field with animated focus glow border. Used for the
/// home screen search bar, login/auth forms, checkout address fields, etc.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.glass = false,
    this.autofocus = false,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;

  /// Custom trailing widget (e.g. a clear button) — if null and
  /// [obscureText] is true, a show/hide password toggle is auto-added.
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// If true, renders as a translucent glass field (for use over imagery /
  /// inside the AI panel) instead of the standard solid surface field.
  final bool glass;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = widget.glass
        ? (isDark ? AppColors.darkGlassFillLight : AppColors.lightGlassFillLight)
        : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    Widget? trailing = widget.suffixIcon;
    if (trailing == null && widget.obscureText) {
      trailing = GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: hintColor),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: _focused ? AppColors.accentBlue : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: _focused ? AppShadows.glow(AppColors.accentBlue, opacity: 0.18) : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        textInputAction: widget.textInputAction,
        style: AppTypography.body(textColor),
        cursorColor: AppColors.accentBlue,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.body(hintColor),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: 20, color: _focused ? AppColors.accentBlue : hintColor)
              : null,
          suffixIcon: trailing != null ? Padding(padding: const EdgeInsets.only(right: AppSpacing.sm), child: trailing) : null,
        ),
      ),
    );
  }
}

/// Pre-configured search field for customer_home_screen / products screen
/// top bar — same widget, just sane defaults baked in.
class SearchField extends StatelessWidget {
  const SearchField({super.key, this.controller, this.onChanged, this.hintText = 'Search products…'});
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      prefixIcon: Icons.search_rounded,
    );
  }
}
