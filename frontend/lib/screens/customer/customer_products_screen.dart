import 'package:flutter/material.dart';

import '../../main.dart';
import 'customer_widgets.dart';
import '../../models/models.dart';

class CustomerProductsScreen extends StatefulWidget {
  const CustomerProductsScreen({super.key, this.initialSearch});

  final String? initialSearch;

  @override
  State<CustomerProductsScreen> createState() => _CustomerProductsScreenState();
}

class _CustomerProductsScreenState extends State<CustomerProductsScreen> {
  late final TextEditingController search = TextEditingController(text: widget.initialSearch ?? '');
  String sort = 'newest';
  double maxPrice = 50;
int? selectedCategoryId;
List<Category> categories = [];
  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {

    final bloc = AppScope.of(context);

    categories =
        await bloc.api.categories();

    setState(() {});

    _load();
  });
}

void _load() {

  AppScope.of(context)
      .loadCustomerProducts(

    search: search.text,

    maxPrice: maxPrice,

    sort: sort,

    categoryId:
        selectedCategoryId,
  );
}

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search products'), onChanged: (_) => _load()),
                const SizedBox(height: 8),
                const SizedBox(height: 8),

DropdownButtonFormField<int?>(
  initialValue: selectedCategoryId,

  decoration:
      const InputDecoration(
    labelText: 'Category',
  ),


  items: [

    const DropdownMenuItem<int?>(
      value: null,
      child: Text('All'),
    ),


    ...categories.map(
      (c) =>
          DropdownMenuItem<int?>(
        value: c.id,
        child: Text(c.name),
      ),
    ),
  ],


  onChanged: (value) {

    setState(() {

      selectedCategoryId =
          value;

      _load();

    });

  },
),


const SizedBox(height: 8),

                Row(
                  
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: sort,
                        decoration: const InputDecoration(labelText: 'Sort'),
                        items: const [
                          DropdownMenuItem(value: 'newest', child: Text('Newest')),
                          DropdownMenuItem(value: 'cheapest', child: Text('Cheapest')),
                          DropdownMenuItem(value: 'popular', child: Text('Popular')),
                        ],
                        onChanged: (value) => setState(() {
                          sort = value ?? 'newest';
                          _load();
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: maxPrice,
                        min: 2,
                        max: 100,
                        divisions: 49,
                        label: 'Max ${maxPrice.round()} BAM',
                        onChanged: (value) => setState(() {
                          maxPrice = value;
                          _load();
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.loading) const LinearProgressIndicator(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 230, mainAxisExtent: 260, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: state.customerProducts.length,
              itemBuilder: (context, index) {
                final product = state.customerProducts[index];
                return CustomerProductCard(product: product, onAdd: () => bloc.addCustomerProductToCart(product));
              },
            ),
          ),
        ],
      ),
    );
  }
}
