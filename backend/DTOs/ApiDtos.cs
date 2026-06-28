using SmartAiPos.Api.Models;

namespace SmartAiPos.Api.DTOs;

public sealed record RegisterRequest(string FullName, string Email, string Password);
public sealed record LoginRequest(string Email, string Password);
public sealed record RefreshRequest(string RefreshToken);
public sealed record AuthResponse(
    string AccessToken,
    string RefreshToken,
    DateTimeOffset ExpiresAt,
    UserDto User
);
public sealed record UserDto(Guid Id, string FullName, string Email, UserRole Role);

public sealed record ProductDto(int Id, string Name, decimal Price, decimal CostPrice, int StockQuantity, int ReorderLevel, int CategoryId, string CategoryName, bool IsActive);
public sealed record UpsertProductRequest(string Name, decimal Price, decimal CostPrice, int StockQuantity, int ReorderLevel, int CategoryId, bool IsActive);
public sealed record CategoryDto(int Id, string Name);

public sealed record SaleItemRequest(int ProductId, int Quantity);
public sealed record CreateSaleRequest(Guid CashierId, decimal DiscountAmount, PaymentMethod PaymentMethod, IReadOnlyList<SaleItemRequest> Items);
public sealed record SaleItemDto(int ProductId, string ProductName, int Quantity, decimal Price, decimal LineTotal);
public sealed record SaleDto(Guid Id, string ReceiptNumber, decimal Subtotal, decimal DiscountAmount, decimal TotalAmount, decimal ProfitAmount, DateTimeOffset Date, string CashierName, PaymentMethod PaymentMethod, IReadOnlyList<SaleItemDto> Items);

public sealed record InventoryUpdateRequest(int ProductId, int ChangeAmount, string Reason);
public sealed record LowStockDto(int ProductId, string ProductName, int StockQuantity, int ReorderLevel);

public sealed record DashboardStatsDto(decimal TotalRevenue, decimal TotalProfit, int TotalSalesCount, int ActiveProducts, int LowStockAlerts, IReadOnlyList<ProductSalesDto> TopSellingProducts, IReadOnlyList<DailyRevenueDto> DailyRevenue);
public sealed record ProductSalesDto(int ProductId, string ProductName, int QuantitySold, decimal Revenue);
public sealed record DailyRevenueDto(DateOnly Date, decimal Revenue, int SalesCount);

public sealed record SalesForecastDto(decimal NextDaySales, IReadOnlyList<DailyRevenueDto> WeeklyTrend, string Confidence, string Summary);
public sealed record RestockSuggestionDto(int ProductId, string ProductName, int CurrentStock, int RecommendedOrderQuantity, int EstimatedRunoutDays, string Reason);
public sealed record PopularityAnalysisDto(IReadOnlyList<ProductSalesDto> BestSellingProducts, IReadOnlyList<string> BundleSuggestions);
public sealed record AnomalyDto(string Type, string Severity, string Message);
public sealed record AIInsightDto(InsightType Type, string Message, DateTimeOffset Date);

public sealed record PublicProductDto(int Id, string Name, decimal Price, int StockQuantity, int CategoryId, string CategoryName, string ImageUrl, bool IsAvailable, int PopularityScore);
public sealed record ProductDetailsDto(int Id, string Name, decimal Price, int StockQuantity, int CategoryId, string CategoryName, string ImageUrl, bool IsAvailable, IReadOnlyList<PublicProductDto> RelatedProducts);
public sealed record PagedResult<T>(IReadOnlyList<T> Items, int Page, int PageSize, int TotalCount);

public sealed record CartMutationRequest(int ProductId, int Quantity = 1);
public sealed record CartLineDto(int ProductId, string ProductName, decimal Price, int Quantity, decimal LineTotal, int StockQuantity, string ImageUrl);
public sealed record CartDto(IReadOnlyList<CartLineDto> Items, decimal TotalAmount);

public sealed record CreateOrderRequest(string? Name, string? Phone, string? Address, PaymentMethod PaymentMethod);
public sealed record OrderItemDto(int ProductId, string ProductName, int Quantity, decimal Price, decimal LineTotal);
public sealed record OrderDto(Guid Id, OrderStatus Status, decimal TotalAmount, PaymentMethod PaymentMethod, DateTimeOffset CreatedAt, string? CustomerName, string? Phone, string? Address, IReadOnlyList<OrderItemDto> Items);
public sealed record OrderStatusDto(Guid Id, OrderStatus Status, DateTimeOffset CreatedAt, DateTimeOffset? CompletedAt);
public sealed record BestSellerDto(
    int Rank,
    int ProductId,
    string ProductName,
    string Category,
    int QuantitySold,
    decimal Revenue,
    decimal Profit,
    decimal MarginPercent,
    string AiMessage
);
public sealed record ProfitAnalysisDto(
    int ProductId,
    string ProductName,
    int QuantitySold,
    decimal Revenue,
    decimal Cost,
    decimal Profit,
    decimal MarginPercent,
    string AiMessage
);
public sealed record SmartDealDto(
    int MainProductId,
    string MainProductName,

    int SecondProductId,
    string SecondProductName,

    decimal OriginalPrice,
    decimal DealPrice,
    decimal DiscountPercent,

    decimal ExpectedProfit,

    string AiReason
);
public sealed record CustomerRecommendationDto(
    int ProductId,
    string ProductName,
    string Category,
    decimal Price,
    string Reason
);
public sealed record AiAssistantRequest(
    Guid UserId,
    string Message
);


public sealed record AiAssistantProductDto(
    int ProductId,
    string ProductName,
    decimal Price,
    string Category
);


public sealed record AiAssistantResponse(
    string Message,
    decimal TotalPrice,
    IReadOnlyList<AiAssistantProductDto> Products
);
public sealed record AdminOrderDto(
    Guid Id,
    string CustomerName,
    string Phone,
    string Address,
    decimal TotalAmount,
    OrderStatus Status,
    DateTimeOffset CreatedAt,
    IReadOnlyList<OrderItemDto> Items
);
