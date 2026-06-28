using Microsoft.EntityFrameworkCore;
using SmartAiPos.Api.Models;
using SmartAiPos.Api.Services;

namespace SmartAiPos.Api.Data;

public static class SeedData
{
    public static async Task InitializeAsync(AppDbContext db)
    {
        await db.Database.EnsureCreatedAsync();

        if (await db.Users.AnyAsync()) return;

        // =========================
        // USERS
        // =========================

        var admin = new User
        {
            Id = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            FullName = "Amina Hadzic",
            Email = "admin@smartpos.ba",
            Role = UserRole.Admin,
            PasswordHash = PasswordHasher.Hash("Admin123!")
        };

        var manager = new User
        {
            Id = Guid.Parse("22222222-2222-2222-2222-222222222222"),
            FullName = "Marko Ilic",
            Email = "manager@smartpos.ba",
            Role = UserRole.Manager,
            PasswordHash = PasswordHasher.Hash("Manager123!")
        };

        var cashier1 = new User
        {
            Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            FullName = "Emir Music",
            Email = "cashier1@smartpos.ba",
            Role = UserRole.Cashier,
            PasswordHash = PasswordHasher.Hash("Cashier123!")
        };

        var cashier2 = new User
        {
            Id = Guid.Parse("44444444-4444-4444-4444-444444444444"),
            FullName = "Lejla Kovacevic",
            Email = "cashier2@smartpos.ba",
            Role = UserRole.Cashier,
            PasswordHash = PasswordHasher.Hash("Cashier123!")
        };

        // ?? CUSTOMER (NEW - SHOP SYSTEM)
        var customer = new User
        {
            Id = Guid.Parse("55555555-5555-5555-5555-555555555555"),
            FullName = "Test Customer",
            Email = "customer@smartpos.ba",
            Role = UserRole.Customer,
            PasswordHash = PasswordHasher.Hash("Customer123!")
        };

        db.Users.AddRange(admin, manager, cashier1, cashier2, customer);

        // =========================
        // CATEGORIES
        // =========================

        var drinks = new Category { Name = "Drinks" };
        var food = new Category { Name = "Food" };

        db.Categories.AddRange(drinks, food);
        await db.SaveChangesAsync();

        // =========================
        // PRODUCTS (SHARED POS + SHOP)
        // =========================

        var products = new List<Product>
        {
            new Product { Name = "Coffee", Price = 3.50m, CostPrice = 1.10m, StockQuantity = 120, ReorderLevel = 25, CategoryId = drinks.Id },
            new Product { Name = "Coca Cola", Price = 4.00m, CostPrice = 1.80m, StockQuantity = 18, ReorderLevel = 30, CategoryId = drinks.Id },
            new Product { Name = "Water", Price = 2.00m, CostPrice = 0.70m, StockQuantity = 80, ReorderLevel = 30, CategoryId = drinks.Id },

            new Product { Name = "Burger", Price = 9.50m, CostPrice = 4.10m, StockQuantity = 35, ReorderLevel = 15, CategoryId = food.Id },
            new Product { Name = "Pizza", Price = 11.00m, CostPrice = 4.90m, StockQuantity = 25, ReorderLevel = 12, CategoryId = food.Id },
            new Product { Name = "Sandwich", Price = 6.00m, CostPrice = 2.40m, StockQuantity = 12, ReorderLevel = 20, CategoryId = food.Id }
        };

        db.Products.AddRange(products);
        await db.SaveChangesAsync();

        // =========================
        // SALES (POS HISTORY SEED)
        // =========================

        var random = new Random(42);

        for (var i = 0; i < 45; i++)
        {
            var cashier = i % 2 == 0 ? cashier1 : cashier2;

            var date = DateTimeOffset.UtcNow.Date
                .AddDays(-random.Next(0, 30))
                .AddHours(random.Next(8, 22))
                .AddMinutes(random.Next(0, 59));

            var count = random.Next(1, 4);
            var selected = products.OrderBy(_ => random.Next()).Take(count).ToList();

            var sale = new Sale
            {
                CashierId = cashier.Id,
                Date = date,
                PaymentMethod = random.NextDouble() > 0.5 ? PaymentMethod.Card : PaymentMethod.Cash,
                ReceiptNumber = $"R-{date:yyyyMMdd}-{i + 1:0000}",
                Items = new List<SaleItem>()
            };

            foreach (var product in selected)
            {
                var quantity = random.Next(1, product.Name is "Coffee" or "Water" ? 5 : 3);

                sale.Items.Add(new SaleItem
                {
                    ProductId = product.Id,
                    Quantity = quantity,
                    Price = product.Price,
                    CostPrice = product.CostPrice
                });
            }

            sale.Subtotal = sale.Items.Sum(x => x.Price * x.Quantity);
            sale.DiscountAmount = i % 11 == 0 ? Math.Round(sale.Subtotal * 0.08m, 2) : 0m;
            sale.TotalAmount = sale.Subtotal - sale.DiscountAmount;
            sale.ProfitAmount = sale.Items.Sum(x => (x.Price - x.CostPrice) * x.Quantity) - sale.DiscountAmount;

            db.Sales.Add(sale);
        }

        // =========================
        // AI INSIGHT SEED
        // =========================

        db.AIInsights.Add(new AIInsight
        {
            Type = InsightType.BusinessSummary,
            Message = "Coffee and soft drinks dominate morning and lunch demand."
        });

        await db.SaveChangesAsync();
    }
}