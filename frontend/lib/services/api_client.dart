import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiClient {
  ApiClient({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:5065',
    ),
  });

  final String baseUrl;
  String? token;

  void clearToken() {
    token = null;
  }
Future<List<SaleReceipt>> sales() async {
  final json = await _send(
    'GET',
    '/sales',
  );

  return (json as List)
      .map(
        (x) => SaleReceipt.fromJson(x),
      )
      .toList();
}
  Future<UserSession> login(
String email,
String password
) async {

final json =
await _send(
'POST',
'/auth/login',
body:{
'email':email,
'password':password
},
authenticated:false
);


final session =
UserSession.fromJson(json);


token=session.accessToken;


return session;

}
  Future<UserSession> register(
    String fullName,
    String email,
    String password,
  ) async {
    final json = await _send(
      'POST',
      '/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': 'Customer',
      },
      authenticated: false,
    );

    token = json['accessToken'];

    return UserSession.fromJson(json);
  }

 Future<List<Product>> products({
  String? search,
  int? categoryId,
}) async {

  final query = <String, String>{};


  if (search != null && search.isNotEmpty) {
    query['search'] = search;
  }


  if (categoryId != null) {
    query['categoryId'] = categoryId.toString();
  }


  final uri = Uri(
    path: '/products',
    queryParameters:
        query.isEmpty ? null : query,
  );


  final json = await _send(
    'GET',
    uri.toString(),
  );


  return (json as List)
      .map(
        (x) => Product.fromJson(x),
      )
      .toList();
}
Future<List<Category>> categories() async {

  final json = await _send(
    'GET',
    '/products/categories',
  );


  return (json as List)
      .map(
        (x) => Category.fromJson(x),
      )
      .toList();
}

  Future<DashboardStats> dashboard() async =>
      DashboardStats.fromJson(await _send('GET', '/dashboard/stats'));

  Future<List<AIInsight>> insights() async =>
      (await _send('GET', '/ai/insights') as List)
          .map((x) => AIInsight.fromJson(x))
          .toList();

  Future<Map<String, dynamic>> forecast() async =>
      await _send('GET', '/ai/forecast-sales');

  Future<List<dynamic>> restock() async =>
      await _send('GET', '/ai/recommend-restock');
// =======================
// ADMIN ORDERS
// =======================


Future<List<AdminOrder>> pendingOrders()
async {

final json =
await _send(
'GET',
'/api/orders/pending'
);


return (json as List)

.map(
(x)=>AdminOrder.fromJson(x)
)

.toList();

}







Future<void> approveOrder(
String id)
async {

await _send(
'PUT',
'/api/orders/approve/$id'
);

}






Future<void> rejectOrder(
String id)
async {

await _send(
'PUT',
'/api/orders/reject/$id'
);

}
  Future<Map<String, dynamic>> createSale(
    String cashierId,
    List<CartLine> lines,
    double discount,
    PaymentMethod method,
  ) async {
    return await _send(
      'POST',
      '/sales/create',
      body: {
        'cashierId': cashierId,
        'discountAmount': discount,
        'paymentMethod': method.name,
        'items':
            lines
                .map(
                  (x) => {'productId': x.product.id, 'quantity': x.quantity},
                )
                .toList(),
      },
    );
  }

  Future<CustomerProductPage> publicProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'categoryId': '$categoryId',
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };
    final uri = Uri(path: '/api/public/products', queryParameters: query);
    return CustomerProductPage.fromJson(await _send('GET', uri.toString(), authenticated: false));
  }

  Future<ProductDetails> publicProductDetails(int id) async =>
      ProductDetails.fromJson(await _send('GET', '/api/public/products/$id', authenticated: false));

  Future<List<CustomerProduct>> featuredProducts() async =>
      (await _send('GET', '/api/public/products/featured', authenticated: false) as List).map((x) => CustomerProduct.fromJson(x)).toList();

  Future<List<CustomerProduct>> popularProducts() async =>
      (await _send('GET', '/api/public/products/popular', authenticated: false) as List).map((x) => CustomerProduct.fromJson(x)).toList();

  Future<List<CustomerProduct>> dealsProducts() async =>
      (await _send('GET', '/api/public/products/deals', authenticated: false) as List).map((x) => CustomerProduct.fromJson(x)).toList();

  Future<List<CustomerProduct>> searchProducts(String query) async =>
      (await _send('GET', '/api/public/products/search?q=${Uri.encodeComponent(query)}', authenticated: false) as List).map((x) => CustomerProduct.fromJson(x)).toList();

  Future<CustomerCart> customerCart() async => CustomerCart.fromJson(await _send('GET', '/api/cart'));

  Future<CustomerCart> addCustomerCart(int productId, {int quantity = 1}) async =>
      CustomerCart.fromJson(await _send('POST', '/api/cart/add', body: {'productId': productId, 'quantity': quantity}));

  Future<CustomerCart> updateCustomerCart(int productId, int quantity) async =>
      CustomerCart.fromJson(await _send('PUT', '/api/cart/update', body: {'productId': productId, 'quantity': quantity}));

  Future<CustomerCart> removeCustomerCart(int productId) async =>
      CustomerCart.fromJson(await _send('POST', '/api/cart/remove', body: {'productId': productId, 'quantity': 0}));

  Future<CustomerOrder> createCustomerOrder({
    String? name,
    String? phone,
    String? address,
    required PaymentMethod paymentMethod,
  }) async =>
      CustomerOrder.fromJson(await _send('POST', '/api/orders/create', body: {
        'name': name,
        'phone': phone,
        'address': address,
        'paymentMethod': paymentMethod.name,
      }));

  Future<List<CustomerOrder>> myOrders() async =>
      (await _send('GET', '/api/orders/my-orders') as List).map((x) => CustomerOrder.fromJson(x)).toList();
// ===========================
// BEST SELLERS AI
// ===========================


Future<BestSellerAI> bestSellers() async =>
    BestSellerAI.fromJson(
      await _send(
        'GET',
        '/ai/popularity',
      ),
    );




// ===========================
// PROFIT ANALYZER
// ===========================


Future<List<ProfitAnalysis>> profitAnalysis() async =>
    (await _send(
      'GET',
      '/ai/profit-analysis',
    ) as List)
        .map(
          (x) => ProfitAnalysis.fromJson(x),
        )
        .toList();




// ===========================
// SMART DEALS
// ===========================


Future<List<SmartDeal>> smartDeals() async =>
    (await _send(
      'GET',
      '/ai/smart-deals',
    ) as List)
        .map(
          (x) => SmartDeal.fromJson(x),
        )
        .toList();




// ===========================
// CUSTOMER AI RECOMMENDATIONS
// ===========================


Future<List<AiRecommendation>> aiRecommendations(
    String userId) async =>
    (await _send(
      'GET',
      '/ai/recommendations/$userId',
    ) as List)
        .map(
          (x)=>AiRecommendation.fromJson(x),
        )
        .toList();




// ===========================
// SMART AI CHAT
// ===========================


Future<AiAssistantResponse> aiAssistant(
  String userId,
  String message,
) async =>
    AiAssistantResponse.fromJson(
      await _send(
        'POST',
        '/ai/assistant',
        body: {
          'userId': userId,
          'message': message,
        },
      ),
    );
  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    bool authenticated = true,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (authenticated && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('$baseUrl$path');
    final payload = body == null ? null : jsonEncode(body);

    final response =
        switch (method) {
          'GET' => await http.get(uri, headers: headers),
          'POST' => await http.post(uri, headers: headers, body: payload),
          'PUT' => await http.put(uri, headers: headers, body: payload),
          'DELETE' => await http.delete(uri, headers: headers),
          _ => throw ApiException('Unsupported method $method'),
        };

    final text = response.body;

    if (response.statusCode >= 400) {
      throw ApiException(
        text.isEmpty ? 'HTTP ${response.statusCode}' : text,
      );
    }

    if (text.isEmpty) return {};

    return jsonDecode(text);
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
