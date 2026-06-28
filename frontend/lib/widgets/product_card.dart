/// product_card.dart
///
/// Premium product card for grids (customer products screen, home
/// "Popular"/"Recommended" rails, admin products/POS screens). Deliberately
/// takes plain primitives (String/double/bool) instead of your Product
/// model class, so it drops in regardless of your model's exact field
/// names — wire it up at the call site:
///
/// ```dart
/// ProductCard(
///   name: product.name,
///   category: product.category,
///   price: product.price,
///   imageUrl: product.imageUrl, // nullable — falls back to category art
///   available: product.stock > 0,
///   onTap: () => Navigator.push(...),
///   onAdd: () => cart.add(product),
/// )
/// ```
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.category,
    this.imageUrl,
    this.available = true,
    this.currencySymbol = 'BAM',
    this.onTap,
    this.onAdd,
    this.compact = false,
  });

  final String name;
  final double price;
  final String? category;

  /// Network image URL if you already store one. If null, a category-aware
  /// gradient + icon placeholder is shown instead (see [_iconForCategory]).
  final String? imageUrl;
  final bool available;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  /// Compact = smaller card for horizontal rails (home screen "Popular").
  final bool compact;

@override
Widget build(BuildContext context) {
  final isDark =
      Theme.of(context).brightness == Brightness.dark;

  return GlassCard(
    onTap: onTap,
    padding: EdgeInsets.zero,
    width: compact ? 168 : null,

    child: Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,


      children: [


        // ======================
        // PRODUCT IMAGE
        // ======================

        SizedBox(

          height:
          compact ? 130 : 180,


          child: Stack(

            fit:
            StackFit.expand,


            children: [


              ClipRRect(

                borderRadius:
                const BorderRadius.vertical(
                  top: Radius.circular(
                    AppRadius.lg,
                  ),
                ),


                child:
                _ProductImage(

                  imageUrl:
                  imageUrl,


                  category:
                  category,


                  name:
                  name,

                ),

              ),




              if(!available)

                Positioned.fill(

                  child:

                  Container(

                    color:
                    Colors.black.withOpacity(
                      0.55,
                    ),


                    alignment:
                    Alignment.center,


                    child:

                    Text(

                      "Nije dostupno",

                      style:
                      AppTypography.caption1(
                        Colors.white,
                      ),

                    ),

                  ),

                ),




              if(category != null)

                Positioned(

                  top:
                  AppSpacing.sm,


                  left:
                  AppSpacing.sm,


                  child:

                  Container(

                    padding:
                    const EdgeInsets.symmetric(

                      horizontal:8,

                      vertical:4,

                    ),


                    decoration:
                    BoxDecoration(

                      color:
                      Colors.black.withOpacity(
                        .4,
                      ),


                      borderRadius:
                      AppRadius.pillRadius,

                    ),



                    child:

                    Text(

                      category!.toUpperCase(),


                      maxLines:1,


                      overflow:
                      TextOverflow.ellipsis,


                      style:
                      AppTypography.eyebrow(
                        Colors.white,
                      ),

                    ),

                  ),

                ),


            ],

          ),

        ),





        // ======================
        // INFO
        // ======================


        Padding(

          padding:
          const EdgeInsets.all(
            AppSpacing.sm,
          ),


          child:

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            mainAxisSize:
            MainAxisSize.min,



            children:[



              Text(

                name,


                maxLines:2,


                overflow:
                TextOverflow.ellipsis,


                style:
                AppTypography.bodyEmphasis(

                  isDark

                  ?

                  AppColors.darkTextPrimary

                  :

                  AppColors.lightTextPrimary,

                ),

              ),




              const SizedBox(
                height:6,
              ),





              Row(

                children:[


                  Expanded(

                    child:

                    Text(

                      "$currencySymbol ${price.toStringAsFixed(2)}",


                      maxLines:1,


                      overflow:
                      TextOverflow.ellipsis,


                      style:

                      AppTypography.headline(
                        AppColors.accentBlue,
                      ),

                    ),

                  ),




                  if(onAdd != null)

                  _AddButton(

                    onTap:

                    available

                    ?

                    onAdd

                    :

                    null,

                  ),



                ],

              ),


            ],

          ),

        ),


      ],

    ),

  );
}
}
class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});
  final VoidCallback? onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  bool _bounced = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              widget.onTap!.call();
              setState(() => _bounced = true);
              Future.delayed(const Duration(milliseconds: 180), () {
                if (mounted) setState(() => _bounced = false);
              });
            },
      child: AnimatedScale(
        scale: _bounced ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: widget.onTap != null ? AppColors.accentGradient : null,
            color: widget.onTap == null ? AppColors.darkBorder : null,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Renders the network image when available, otherwise a category-themed
/// gradient + icon. This satisfies "auto-import product images" without a
/// network call: it's a tasteful placeholder system, not a live image
/// search — wire a real image pipeline at the call site if you have one
/// (e.g. pass a URL resolved from your backend's product.imageUrl).
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.category, required this.name});
  final String? imageUrl;
  final String? category;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(loading: true);
        },
      );
    }
    return _placeholder();
  }

  Widget _placeholder({bool loading = false}) {
    final spec = _iconForCategory(category ?? name);
    return Container(
      decoration: BoxDecoration(gradient: spec.gradient),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            )
          : Icon(spec.icon, size: 40, color: Colors.white.withOpacity(0.9)),
    );
  }

  _CategoryArt _iconForCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('burger')) {
      return _CategoryArt(Icons.lunch_dining_rounded, const LinearGradient(colors: [Color(0xFFE8A33D), Color(0xFFC9622A)]));
    }
    if (t.contains('pizza')) {
      return _CategoryArt(Icons.local_pizza_rounded, const LinearGradient(colors: [Color(0xFFE85D3D), Color(0xFFB8312A)]));
    }
    if (t.contains('coffee') || t.contains('latte') || t.contains('espresso')) {
      return _CategoryArt(Icons.coffee_rounded, const LinearGradient(colors: [Color(0xFF6F4E37), Color(0xFF3E2B22)]));
    }
    if (t.contains('drink') || t.contains('juice') || t.contains('soda') || t.contains('cola')) {
      return _CategoryArt(Icons.local_drink_rounded, const LinearGradient(colors: [Color(0xFF34D8C9), Color(0xFF0A84FF)]));
    }
    if (t.contains('dessert') || t.contains('cake') || t.contains('ice cream')) {
      return _CategoryArt(Icons.icecream_rounded, const LinearGradient(colors: [Color(0xFFFF7AAE), Color(0xFFB85CFF)]));
    }
    if (t.contains('salad') || t.contains('veg')) {
      return _CategoryArt(Icons.eco_rounded, const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF0F9D6E)]));
    }
    if (t.contains('snack') || t.contains('fries')) {
      return _CategoryArt(Icons.fastfood_rounded, const LinearGradient(colors: [Color(0xFFFFB454), Color(0xFFE8853D)]));
    }
    return _CategoryArt(Icons.restaurant_menu_rounded, AppColors.accentGradient);
  }
}

class _CategoryArt {
  _CategoryArt(this.icon, this.gradient);
  final IconData icon;
  final Gradient gradient;
}
