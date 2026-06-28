import 'package:flutter/material.dart';

import '../../main.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/animated_navigation.dart';

import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);

    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) {
        final cart = state.customerCart;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Moja korpa",
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 20),

            if (cart.items.isEmpty)
              const GlassCard(
                child: ListTile(
                  leading: Icon(Icons.shopping_cart_outlined),
                  title: Text("Korpa je prazna"),
                  subtitle: Text("Dodajte proizvode za narudžbu"),
                ),
              ),

            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                        ),
                        child: const Icon(
                          Icons.fastfood,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.price.toStringAsFixed(2)} BAM x ${item.quantity}",
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () =>
                            bloc.updateCustomerCart(
                          item.productId,
                          item.quantity - 1,
                        ),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),

                      IconButton(
                        onPressed: () =>
                            bloc.updateCustomerCart(
                          item.productId,
                          item.quantity + 1,
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                      ),

                      IconButton(
                        onPressed: () =>
                            bloc.removeCustomerCart(
                          item.productId,
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ukupno za platiti",
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${cart.totalAmount.toStringAsFixed(2)} BAM",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            PremiumButton(
              expand: true,
              icon: Icons.payment,
              label: "Nastavi na plaćanje",
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        AppPageRoute(
                          child: const CheckoutScreen(),
                        ),
                      );
                    },
            ),
          ],
        );
      },
    );
  }
}