using System.ComponentModel.DataAnnotations;

namespace SmartAiPos.Api.Models;

public sealed class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    [MaxLength(160)] public required string FullName { get; set; }
    [MaxLength(180)] public required string Email { get; set; }
    [MaxLength(512)] public required string PasswordHash { get; set; }
    public UserRole Role { get; set; }
    public CustomerProfile? CustomerProfile { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public ICollection<Sale> Sales { get; set; } = new List<Sale>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
}

public sealed class RefreshToken
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    [MaxLength(256)] public required string TokenHash { get; set; }
    public DateTimeOffset ExpiresAt { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? RevokedAt { get; set; }
    public User? User { get; set; }
}

public sealed class Category
{
    public int Id { get; set; }
    [MaxLength(120)] public required string Name { get; set; }
    public ICollection<Product> Products { get; set; } = new List<Product>();
}

public sealed class Product
{
    public int Id { get; set; }
    [MaxLength(180)] public required string Name { get; set; }
    public decimal Price { get; set; }
    public decimal CostPrice { get; set; }
    public int StockQuantity { get; set; }
    public int ReorderLevel { get; set; } = 10;
    public bool IsActive { get; set; } = true;
    public int CategoryId { get; set; }
    public Category? Category { get; set; }
    public ICollection<SaleItem> SaleItems { get; set; } = new List<SaleItem>();
    public ICollection<InventoryLog> InventoryLogs { get; set; } = new List<InventoryLog>();
    public ICollection<OrderItem> OrderItems { get; set; }
    = new List<OrderItem>();
}

public sealed class Sale
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public decimal Subtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal ProfitAmount { get; set; }
    public DateTimeOffset Date { get; set; } = DateTimeOffset.UtcNow;
    public Guid CashierId { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    [MaxLength(40)] public required string ReceiptNumber { get; set; }
    public User? Cashier { get; set; }
    public ICollection<SaleItem> Items { get; set; } = new List<SaleItem>();
}

public sealed class SaleItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid SaleId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public decimal CostPrice { get; set; }
    public Sale? Sale { get; set; }
    public Product? Product { get; set; }
}

public sealed class InventoryLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public int ProductId { get; set; }
    public int ChangeAmount { get; set; }
    [MaxLength(240)] public required string Reason { get; set; }
    public DateTimeOffset Date { get; set; } = DateTimeOffset.UtcNow;
    public Product? Product { get; set; }
}

public sealed class AIInsight
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public InsightType Type { get; set; }
    [MaxLength(4000)] public required string Message { get; set; }
    public DateTimeOffset Date { get; set; } = DateTimeOffset.UtcNow;
}
