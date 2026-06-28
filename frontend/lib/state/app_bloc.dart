import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_client.dart';

class AppState {
  const AppState({
    this.session,
    this.products = const [],
    this.cart = const [],
    this.dashboard,
    this.insights = const [],
    this.featuredProducts = const [],
    this.popularProducts = const [],
    this.dealProducts = const [],
    this.customerProducts = const [],
    this.customerCart = const CustomerCart(items: [], totalAmount: 0),
    this.customerOrders = const [],
    this.loading = false,
    this.error,
    this.themeMode = ThemeMode.system,
  });

  final UserSession? session;
  final List<Product> products;
  final List<CartLine> cart;
  final DashboardStats? dashboard;
  final List<AIInsight> insights;
  final List<CustomerProduct> featuredProducts;
  final List<CustomerProduct> popularProducts;
  final List<CustomerProduct> dealProducts;
  final List<CustomerProduct> customerProducts;
  final CustomerCart customerCart;
  final List<CustomerOrder> customerOrders;
  final bool loading;
  final String? error;
  final ThemeMode themeMode;

  AppState copyWith({
    UserSession? session,
    List<Product>? products,
    List<CartLine>? cart,
    DashboardStats? dashboard,
    List<AIInsight>? insights,
    List<CustomerProduct>? featuredProducts,
    List<CustomerProduct>? popularProducts,
    List<CustomerProduct>? dealProducts,
    List<CustomerProduct>? customerProducts,
    CustomerCart? customerCart,
    List<CustomerOrder>? customerOrders,
    bool? loading,
    String? error,
    ThemeMode? themeMode,
    bool clearError = false,
  }) {
    return AppState(
      session: session ?? this.session,
      products: products ?? this.products,
      cart: cart ?? this.cart,
      dashboard: dashboard ?? this.dashboard,
      insights: insights ?? this.insights,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      dealProducts: dealProducts ?? this.dealProducts,
      customerProducts: customerProducts ?? this.customerProducts,
      customerCart: customerCart ?? this.customerCart,
      customerOrders: customerOrders ?? this.customerOrders,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppBloc extends ValueNotifier<AppState> {
  AppBloc(this.api) : super(const AppState());

  final ApiClient api;

 Future<void> login(
  String email,
  String password,
) async {
  value = value.copyWith(
    loading: true,
    clearError: true,
  );

  try {
    final session = await api.login(
      email,
      password,
    );

    value = value.copyWith(
      session: session,
    );

    await refresh();

    value = value.copyWith(
      loading: false,
    );
  } catch (e) {
    value = value.copyWith(
      loading: false,
      error: e.toString(),
    );
  }
}
  Future<void> register(String name, String email, String password) async => _run(() async {
        final session = await api.register(name, email, password);
        value = value.copyWith(session: session);
        await refresh();
      });

  Future<void> refresh() async => _run(() async {
        if (value.session?.user.role == UserRole.customer) {
          await loadCustomerHome();
          return;
        }

        final products = await api.products();
        DashboardStats? dashboard;
        List<AIInsight> insights = const [];
        if (value.session?.user.role != UserRole.cashier) {
          dashboard = await api.dashboard();
          insights = await api.insights();
        }
        value = value.copyWith(products: products, dashboard: dashboard, insights: insights);
      });

  Future<void> loadCustomerHome() async => _run(() async {
        final featured = await api.featuredProducts();
        final popular = await api.popularProducts();
        final deals = await api.dealsProducts();
        final cart = await api.customerCart();
        final orders = await api.myOrders();
        value = value.copyWith(
          featuredProducts: featured,
          popularProducts: popular,
          dealProducts: deals,
          customerCart: cart,
          customerOrders: orders,
        );
      });

  Future<void> loadCustomerProducts({String? search, int? categoryId, double? minPrice, double? maxPrice, String? sort}) async => _run(() async {
        final page = await api.publicProducts(search: search, categoryId: categoryId, minPrice: minPrice, maxPrice: maxPrice, sort: sort);
        value = value.copyWith(customerProducts: page.items);
      });

  Future<ProductDetails> customerProductDetails(int id) => api.publicProductDetails(id);

  Future<void> addCustomerProductToCart(CustomerProduct product) async => _run(() async {
        final cart = await api.addCustomerCart(product.id);
        value = value.copyWith(customerCart: cart);
      });

  Future<void> updateCustomerCart(int productId, int quantity) async => _run(() async {
        final cart = await api.updateCustomerCart(productId, quantity);
        value = value.copyWith(customerCart: cart);
      });

  Future<void> removeCustomerCart(int productId) async => _run(() async {
        final cart = await api.removeCustomerCart(productId);
        value = value.copyWith(customerCart: cart);
      });

  Future<CustomerOrder?> createCustomerOrder({String? name, String? phone, String? address, required PaymentMethod paymentMethod}) async {
    CustomerOrder? created;
    await _run(() async {
      created = await api.createCustomerOrder(name: name, phone: phone, address: address, paymentMethod: paymentMethod);
      final cart = await api.customerCart();
      final orders = await api.myOrders();
      value = value.copyWith(customerCart: cart, customerOrders: orders);
    });
    return created;
  }

  void addToCart(Product product) {
    final lines = [...value.cart];
    final index = lines.indexWhere((x) => x.product.id == product.id);
    if (index >= 0) {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    } else {
      lines.add(CartLine(product: product, quantity: 1));
    }
    value = value.copyWith(cart: lines, clearError: true);
  }

  void removeFromCart(Product product) {
    final lines = [...value.cart];
    final index = lines.indexWhere((x) => x.product.id == product.id);
    if (index < 0) return;
    final quantity = lines[index].quantity - 1;
    if (quantity <= 0) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: quantity);
    }
    value = value.copyWith(cart: lines);
  }

  Future<void> checkout(double discount, PaymentMethod method) async => _run(() async {
        final session = value.session;
        if (session == null || value.cart.isEmpty) return;
        await api.createSale(session.user.id, value.cart, discount, method);
        value = value.copyWith(cart: const []);
        await refresh();
      });

  void toggleTheme() {
    value = value.copyWith(themeMode: value.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void logout() {
    api.clearToken();
    value = AppState(themeMode: value.themeMode);
  }

  Future<void> _run(Future<void> Function() action) async {
    value = value.copyWith(loading: true, clearError: true);
    try {
      await action();
      value = value.copyWith(loading: false);
    } catch (error) {
      value = value.copyWith(loading: false, error: error.toString());
    }
  }
}
