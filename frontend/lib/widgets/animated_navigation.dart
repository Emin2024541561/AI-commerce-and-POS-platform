/// animated_navigation.dart
///
/// Page transition builder used for Navigator.push calls between screens
/// that aren't part of the bottom-tab shells (e.g. product_details_screen,
/// checkout_screen, cart_screen). Tab switches inside home_shell /
/// customer_shell are handled by AnimatedNavBar + an IndexedStack/
/// PageView, not by these routes.
///
/// Usage — replace:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(...)));
/// ```
/// with:
/// ```dart
/// Navigator.push(context, AppPageRoute(child: ProductDetailsScreen(...)));
/// ```
///
/// For a bottom-sheet-style modal push (e.g. cart, filters), use
/// `AppPageRoute.modal(...)` instead — slides up from the bottom with a
/// scrim, iOS modal-sheet style.
import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required Widget child, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
            final slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved);
            final fade = Tween<double>(begin: 0, end: 1).animate(curved);
            // Outgoing page subtly recedes — mirrors iOS push behavior.
            final secondarySlide = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.04, 0))
                .animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic));

            return SlideTransition(
              position: secondarySlide,
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              ),
            );
          },
        );

  /// iOS-style modal sheet push: slides up from the bottom with a scrim
  /// fade behind it. Use for cart_screen, checkout_screen, filter sheets.
  static Route<T> modal<T>({required Widget child}) {
    return PageRouteBuilder<T>(
      opaque: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: child,
        );
      },
    );
  }
}

/// Crossfade + scale used for tab content swaps inside IndexedStack-based
/// shells, and for swapping AI result panels in place.
class FadeThroughSwitcher extends StatelessWidget {
  const FadeThroughSwitcher({super.key, required this.child, required this.indexKey});
  final Widget child;
  final Object indexKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(indexKey), child: child),
    );
  }
}
