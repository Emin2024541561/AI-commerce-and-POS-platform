enum UserRole { admin, manager, cashier, customer }
enum PaymentMethod { cash, card, digital }
enum OrderStatus { pending, preparing, ready, completed }

class UserSession {

  const UserSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });


  final String accessToken;
  final String refreshToken;
  final AppUser user;


  factory UserSession.fromJson(
      Map<String,dynamic> json)
  {

    return UserSession(

      accessToken:
      json['accessToken'],

      refreshToken:
      json['refreshToken'],

      user:
      AppUser.fromJson(
        json['user']
      ),

    );

  }

}

class AppUser {
  const AppUser({required this.id, required this.fullName, required this.email, required this.role});
  final String id;
  final String fullName;
  final String email;
  final UserRole role;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'].toString(),
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        role: _role(json['role'].toString()),
      );
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.categoryId,
    required this.categoryName,
    required this.isActive,
  });

  final int id;
  final String name;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final int reorderLevel;
  final int categoryId;
  final String categoryName;
  final bool isActive;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        costPrice: (json['costPrice'] as num).toDouble(),
        stockQuantity: json['stockQuantity'],
        reorderLevel: json['reorderLevel'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'] ?? '',
        isActive: json['isActive'] ?? true,
      );
}

class CartLine {
  const CartLine({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  double get total => product.price * quantity;
  CartLine copyWith({int? quantity}) => CartLine(product: product, quantity: quantity ?? this.quantity);
}

class ProductSales {
  const ProductSales({required this.productName, required this.quantitySold, required this.revenue});
  final String productName;
  final int quantitySold;
  final double revenue;
  factory ProductSales.fromJson(Map<String, dynamic> json) => ProductSales(
        productName: json['productName'],
        quantitySold: json['quantitySold'],
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class DailyRevenue {
  const DailyRevenue({required this.date, required this.revenue, required this.salesCount});
  final String date;
  final double revenue;
  final int salesCount;
  factory DailyRevenue.fromJson(Map<String, dynamic> json) => DailyRevenue(
        date: json['date'].toString(),
        revenue: (json['revenue'] as num).toDouble(),
        salesCount: json['salesCount'],
      );
}

class DashboardStats {
  const DashboardStats({
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalSalesCount,
    required this.activeProducts,
    required this.lowStockAlerts,
    required this.topSellingProducts,
    required this.dailyRevenue,
  });

  final double totalRevenue;
  final double totalProfit;
  final int totalSalesCount;
  final int activeProducts;
  final int lowStockAlerts;
  final List<ProductSales> topSellingProducts;
  final List<DailyRevenue> dailyRevenue;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalRevenue: (json['totalRevenue'] as num).toDouble(),
        totalProfit: (json['totalProfit'] as num).toDouble(),
        totalSalesCount: json['totalSalesCount'],
        activeProducts: json['activeProducts'],
        lowStockAlerts: json['lowStockAlerts'],
        topSellingProducts: (json['topSellingProducts'] as List).map((x) => ProductSales.fromJson(x)).toList(),
        dailyRevenue: (json['dailyRevenue'] as List).map((x) => DailyRevenue.fromJson(x)).toList(),
      );
}

class AIInsight {
  const AIInsight({required this.type, required this.message, required this.date});
  final String type;
  final String message;
  final String date;
  factory AIInsight.fromJson(Map<String, dynamic> json) => AIInsight(type: json['type'].toString(), message: json['message'], date: json['date'].toString());
}

class CustomerProduct {

  const CustomerProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.isAvailable,
    required this.popularityScore,
  });



  final int id;
  final String name;
  final double price;
  final int stockQuantity;
  final int categoryId;
  final String categoryName;
  final String imageUrl;
  final bool isAvailable;
  final int popularityScore;



  factory CustomerProduct.fromJson(
      Map<String,dynamic> json
      )
  {

    return CustomerProduct(

      id:

      json['id']
      ??
      json['productId']
      ??
      0,



      name:

      json['name']
      ??
      json['productName']
      ??
      '',




      price:

      (json['price'] ?? 0)
      .toDouble(),





      stockQuantity:

      json['stockQuantity']
      ??
      999,





      categoryId:

      json['categoryId']
      ??
      0,





      categoryName:

      json['categoryName']
      ??
      json['category']
      ??
      '',





      imageUrl:

      json['imageUrl']
      ??
      '',





      isAvailable:

      json['isAvailable']
      ??
      true,





      popularityScore:

      json['popularityScore']
      ??
      0,

    );


  }


}

class ProductDetails {
  const ProductDetails({
    required this.product,
    required this.relatedProducts,
  });

  final CustomerProduct product;
  final List<CustomerProduct> relatedProducts;

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
        product: CustomerProduct.fromJson(json),
        relatedProducts: (json['relatedProducts'] as List? ?? []).map((x) => CustomerProduct.fromJson(x)).toList(),
      );
}

class CustomerProductPage {
  const CustomerProductPage({required this.items, required this.page, required this.pageSize, required this.totalCount});

  final List<CustomerProduct> items;
  final int page;
  final int pageSize;
  final int totalCount;
  bool get hasMore => page * pageSize < totalCount;

  factory CustomerProductPage.fromJson(Map<String, dynamic> json) => CustomerProductPage(
        items: (json['items'] as List).map((x) => CustomerProduct.fromJson(x)).toList(),
        page: json['page'],
        pageSize: json['pageSize'],
        totalCount: json['totalCount'],
      );
}

class CustomerCartLine {
  const CustomerCartLine({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.lineTotal,
    required this.stockQuantity,
    required this.imageUrl,
  });

  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double lineTotal;
  final int stockQuantity;
  final String imageUrl;

  factory CustomerCartLine.fromJson(Map<String, dynamic> json) => CustomerCartLine(
        productId: json['productId'],
        productName: json['productName'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
        lineTotal: (json['lineTotal'] as num).toDouble(),
        stockQuantity: json['stockQuantity'],
        imageUrl: json['imageUrl'] ?? '',
      );
}

class CustomerCart {
  const CustomerCart({required this.items, required this.totalAmount});

  final List<CustomerCartLine> items;
  final double totalAmount;

  factory CustomerCart.fromJson(Map<String, dynamic> json) => CustomerCart(
        items: (json['items'] as List? ?? []).map((x) => CustomerCartLine.fromJson(x)).toList(),
        totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      );
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final OrderStatus status;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String createdAt;
  final List<CustomerOrderItem> items;

  factory CustomerOrder.fromJson(Map<String, dynamic> json) => CustomerOrder(
        id: json['id'].toString(),
        status: _orderStatus(json['status'].toString()),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentMethod: _paymentMethod(json['paymentMethod'].toString()),
        createdAt: json['createdAt'].toString(),
        items: (json['items'] as List? ?? []).map((x) => CustomerOrderItem.fromJson(x)).toList(),
      );
}

class CustomerOrderItem {
  const CustomerOrderItem({required this.productName, required this.quantity, required this.lineTotal});

  final String productName;
  final int quantity;
  final double lineTotal;

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) => CustomerOrderItem(
        productName: json['productName'] ?? '',
        quantity: json['quantity'],
        lineTotal: (json['lineTotal'] as num).toDouble(),
      );
}

UserRole _role(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('admin')) return UserRole.admin;
  if (normalized.contains('manager')) return UserRole.manager;
  if (normalized.contains('customer')) return UserRole.customer;
  return UserRole.cashier;
}

OrderStatus _orderStatus(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('preparing')) return OrderStatus.preparing;
  if (normalized.contains('ready')) return OrderStatus.ready;
  if (normalized.contains('completed')) return OrderStatus.completed;
  return OrderStatus.pending;
}

PaymentMethod _paymentMethod(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('card')) return PaymentMethod.card;
  if (normalized.contains('digital')) return PaymentMethod.digital;
  return PaymentMethod.cash;
}
class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}
class SaleReceipt {
  final String id;
  final String receiptNumber;
  final double totalAmount;
  final double profitAmount;
  final String cashierName;
  final String paymentMethod;
  final DateTime date;
  final List<SaleReceiptItem> items;

  SaleReceipt({
    required this.id,
    required this.receiptNumber,
    required this.totalAmount,
    required this.profitAmount,
    required this.cashierName,
    required this.paymentMethod,
    required this.date,
    required this.items,
  });


  factory SaleReceipt.fromJson(Map<String,dynamic> json) {
    return SaleReceipt(
      id: json['id'],
      receiptNumber: json['receiptNumber'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      profitAmount: (json['profitAmount'] as num).toDouble(),
      cashierName: json['cashierName'],
      paymentMethod: json['paymentMethod'],
      date: DateTime.parse(json['date']),

      items: (json['items'] as List)
          .map(
            (x)=>SaleReceiptItem.fromJson(x)
          )
          .toList(),
    );
  }
}



class SaleReceiptItem {

  final String productName;
  final int quantity;
  final double price;
  final double lineTotal;


  SaleReceiptItem({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.lineTotal,
  });


  factory SaleReceiptItem.fromJson(
      Map<String,dynamic> json)
  {
    return SaleReceiptItem(

      productName:
          json['productName'],

      quantity:
          json['quantity'],

      price:
          (json['price'] as num)
              .toDouble(),

      lineTotal:
          (json['lineTotal'] as num)
              .toDouble(),
    );
  }
}
// ===========================
// AI PROFIT ANALYZER
// ===========================

class ProfitAnalysis {
  final int productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double cost;
  final double profit;
  final double marginPercent;
  final String aiMessage;

  ProfitAnalysis({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.marginPercent,
    required this.aiMessage,
  });

  factory ProfitAnalysis.fromJson(Map<String,dynamic> json){
    return ProfitAnalysis(
      productId: json['productId'],
      productName: json['productName'],
      quantitySold: json['quantitySold'],
      revenue: (json['revenue']).toDouble(),
      cost: (json['cost']).toDouble(),
      profit: (json['profit']).toDouble(),
      marginPercent: (json['marginPercent']).toDouble(),
      aiMessage: json['aiMessage'],
    );
  }
}



// ===========================
// AI SMART DEAL
// ===========================

class SmartDeal {

 final String mainProductName;
 final String secondProductName;
 final double dealPrice;
 final double expectedProfit;
 final String aiReason;


 SmartDeal({
  required this.mainProductName,
  required this.secondProductName,
  required this.dealPrice,
  required this.expectedProfit,
  required this.aiReason
 });


 factory SmartDeal.fromJson(Map<String,dynamic> json){
  return SmartDeal(
    mainProductName: json['mainProductName'],
    secondProductName: json['secondProductName'],
    dealPrice: (json['dealPrice']).toDouble(),
    expectedProfit: (json['expectedProfit']).toDouble(),
    aiReason: json['aiReason'],
  );
 }

}



// CUSTOMER AI CHAT

class AiAssistantResponse {

 final String message;
 final double totalPrice;
 final List<CustomerProduct> products;


 AiAssistantResponse({
  required this.message,
  required this.totalPrice,
  required this.products
 });


 factory AiAssistantResponse.fromJson(Map<String,dynamic> json){

 return AiAssistantResponse(

  message: json['message'],
totalPrice:
(json['totalPrice'] ?? 0)
.toDouble(),

  products:
  (json['products'] as List)
  .map((x)=>CustomerProduct.fromJson(x))
  .toList()

 );

 }

}

// CUSTOMER RECOMMENDATION AI


class AiRecommendation {

 final String productName;
 final String category;
 final double price;
 final String reason;


 AiRecommendation({
  required this.productName,
  required this.category,
  required this.price,
  required this.reason
 });


 factory AiRecommendation.fromJson(Map<String,dynamic> json){

 return AiRecommendation(

 productName: json['productName'],
 category: json['category'],
 price:(json['price']).toDouble(),
 reason:json['reason']

 );

 }


}
// BEST SELLERS AI


class BestSellerProduct {

  final int productId;
  final String productName;
  final int quantitySold;
  final double revenue;


  BestSellerProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });


  factory BestSellerProduct.fromJson(
      Map<String,dynamic> json)
  {
    return BestSellerProduct(

      productId:
      json['productId'],

      productName:
      json['productName'],

      quantitySold:
      json['quantitySold'],

      revenue:
      (json['revenue']).toDouble(),

    );
  }

}




class BestSellerAI {

 final List<BestSellerProduct> products;
 final List<String> suggestions;


 BestSellerAI({
  required this.products,
  required this.suggestions
 });



 factory BestSellerAI.fromJson(
 Map<String,dynamic> json)
 {

 return BestSellerAI(

 products:
 (json['bestSellingProducts'] as List)
 .map(
 (x)=>BestSellerProduct.fromJson(x)
 )
 .toList(),


 suggestions:
 List<String>.from(
 json['bundleSuggestions']
 )

 );

 }


}
// ==========================
// ADMIN ORDERS
// ==========================


class AdminOrder {

 final String id;
 final String customerName;
 final String phone;
 final String address;
 final double totalAmount;
 final String status;
 final List<AdminOrderItem> items;


 AdminOrder({
  required this.id,
  required this.customerName,
  required this.phone,
  required this.address,
  required this.totalAmount,
  required this.status,
  required this.items
 });



 factory AdminOrder.fromJson(
 Map<String,dynamic> json)
 {

 return AdminOrder(

 id:
 json['id'],


 customerName:
 json['customerName'] ?? '',


 phone:
 json['phone'] ?? '',


 address:
 json['address'] ?? '',


 totalAmount:
 (json['totalAmount'] as num)
 .toDouble(),


 status:
 json['status'].toString(),


 items:
 (json['items'] as List)
 .map(
 (x)=>AdminOrderItem.fromJson(x)
 )
 .toList()

 );

 }

}







class AdminOrderItem {

 final String productName;
 final int quantity;
 final double price;


 AdminOrderItem({
 required this.productName,
 required this.quantity,
 required this.price
 });



 factory AdminOrderItem.fromJson(
 Map<String,dynamic> json)
 {

 return AdminOrderItem(

 productName:
 json['productName'],


 quantity:
 json['quantity'],


 price:
 (json['price'] as num)
 .toDouble()

 );

 }


}
