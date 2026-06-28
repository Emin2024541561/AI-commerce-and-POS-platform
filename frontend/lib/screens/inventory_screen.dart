import 'package:flutter/material.dart';

import '../main.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) {
        final low = state.products.where((x) => x.stockQuantity <= x.reorderLevel).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Low stock alerts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (low.isEmpty) const Card(elevation: 0, child: ListTile(leading: Icon(Icons.check_circle), title: Text('No low-stock products'))),
            ...low.map((p) => Card(elevation: 0, child: ListTile(leading: const Icon(Icons.warning_amber), title: Text(p.name), subtitle: Text('Current ${p.stockQuantity}, reorder at ${p.reorderLevel}'), trailing: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_shopping_cart), label: const Text('Restock'))))),
          ],
        );
      },
    );
  }
}
