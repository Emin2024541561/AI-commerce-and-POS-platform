import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) {
        final total = state.cart.fold<double>(0, (sum, x) => sum + x.total);
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 850;
            final catalog = _Catalog(products: state.products);
            final cart = _Cart(total: total);
            return wide ? Row(children: [Expanded(flex: 3, child: catalog), Expanded(flex: 2, child: cart)]) : Column(children: [Expanded(child: catalog), SizedBox(height: 320, child: cart)]);
          },
        );
      },
    );
  }
}

class _Catalog extends StatefulWidget {
  const _Catalog({required this.products});

  final List<Product> products;

  @override
  State<_Catalog> createState() => _CatalogState();
}


class _CatalogState extends State<_Catalog> {

  String selectedCategory = 'All';


  @override
  Widget build(BuildContext context) {

    final bloc = AppScope.of(context);


    final categories =
        widget.products
            .map((x) => x.categoryName)
            .toSet()
            .toList()
          ..sort();


    final filteredProducts =
        selectedCategory == 'All'
            ? widget.products
            : widget.products
                .where(
                  (x) =>
                      x.categoryName ==
                      selectedCategory,
                )
                .toList();


    return Column(
      children: [


        // CATEGORY FILTER BAR
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection:
                Axis.horizontal,
            padding:
                const EdgeInsets.all(10),

            children: [

              Padding(
                padding:
                    const EdgeInsets.only(
                        right: 8),
                child: ChoiceChip(
                  label:
                      const Text('All'),

                  selected:
                      selectedCategory ==
                          'All',

                  onSelected: (_) {
                    setState(() {
                      selectedCategory =
                          'All';
                    });
                  },
                ),
              ),


              ...categories.map(
                (category) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                          right: 8),

                  child: ChoiceChip(

                    label:
                        Text(category),

                    selected:
                        selectedCategory ==
                            category,

                    onSelected: (_) {

                      setState(() {
                        selectedCategory =
                            category;
                      });

                    },
                  ),
                ),
              ),
            ],
          ),
        ),



        // PRODUCT GRID
        Expanded(
          child: GridView.builder(

            padding:
                const EdgeInsets.all(16),

            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  220,

              mainAxisExtent:
                  150,

              crossAxisSpacing:
                  12,

              mainAxisSpacing:
                  12,
            ),


            itemCount:
                filteredProducts.length,


            itemBuilder:
                (context, index) {

              final product =
                  filteredProducts[index];


              return Card(
                elevation: 0,

                child: InkWell(

                  onTap:
                      product.stockQuantity <=
                              0
                          ? null
                          : () =>
                              bloc.addToCart(
                                  product),

                  child: Padding(

                    padding:
                        const EdgeInsets
                            .all(14),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,


                      children: [


                        Text(
                          product.name,

                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                        ),


                        Text(
                          product.categoryName,

                          style:
                              Theme.of(context)
                                  .textTheme
                                  .labelMedium,
                        ),


                        const Spacer(),


                        Text(
                          '${product.price.toStringAsFixed(2)} BAM',

                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                        ),


                        Text(
                          'Stock ${product.stockQuantity}',

                          style:
                              TextStyle(

                            color:
                                product.stockQuantity <=
                                        product
                                            .reorderLevel
                                    ? Colors.orange
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Cart extends StatefulWidget {
  const _Cart({required this.total});
  final double total;

  @override
  State<_Cart> createState() => _CartState();
}

class _CartState extends State<_Cart> {
  final discount = TextEditingController(text: '0');
  PaymentMethod method = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    final state = bloc.value;
    final discountAmount = double.tryParse(discount.text) ?? 0;
    final payable = (widget.total - discountAmount).clamp(0, double.infinity);
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Cart', style: Theme.of(context).textTheme.titleLarge),
          Expanded(child: ListView(children: state.cart.map((line) => ListTile(title: Text(line.product.name), subtitle: Text('${line.quantity} x ${line.product.price.toStringAsFixed(2)}'), trailing: IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => bloc.removeFromCart(line.product)))).toList())),
          TextField(controller: discount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount BAM')),
          const SizedBox(height: 8),
          SegmentedButton<PaymentMethod>(segments: const [ButtonSegment(value: PaymentMethod.cash, label: Text('Cash')), ButtonSegment(value: PaymentMethod.card, label: Text('Card')), ButtonSegment(value: PaymentMethod.digital, label: Text('Digital'))], selected: {method}, onSelectionChanged: (value) => setState(() => method = value.first)),
          const SizedBox(height: 12),
          Text('Total ${payable.toStringAsFixed(2)} BAM', style: Theme.of(context).textTheme.headlineSmall),
          FilledButton.icon(onPressed: state.cart.isEmpty || state.loading ? null : () => bloc.checkout(discountAmount, method), icon: const Icon(Icons.check_circle), label: const Text('Charge and save receipt')),
        ]),
      ),
    );
  }
}
