import 'package:flutter/material.dart';

import '../main.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = state.products[index];
          return Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(product.name),
              subtitle: Text('${product.categoryName} - Cost ${product.costPrice.toStringAsFixed(2)} BAM'),
              trailing: Text('${product.price.toStringAsFixed(2)} BAM\nStock ${product.stockQuantity}', textAlign: TextAlign.end),
            ),
          );
        },
      ),
    );
  }
}
