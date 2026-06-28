using Microsoft.EntityFrameworkCore;
using SmartAiPos.Api.Models;

namespace SmartAiPos.Api.Data;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Sale> Sales => Set<Sale>();
    public DbSet<SaleItem> SaleItems => Set<SaleItem>();
    public DbSet<InventoryLog> InventoryLogs => Set<InventoryLog>();
    public DbSet<AIInsight> AIInsights => Set<AIInsight>();
    public DbSet<CustomerProfile> CustomerProfiles => Set<CustomerProfile>();
    public DbSet<CartItem> CartItems => Set<CartItem>();

    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // USER
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(x => x.Email).IsUnique();
            entity.Property(x => x.Role).HasConversion<string>().HasMaxLength(40);
        });

        modelBuilder.Entity<CustomerProfile>(entity =>
        {
            entity.HasIndex(x => x.UserId).IsUnique();
            entity.HasOne(x => x.User)
                .WithOne(x => x.CustomerProfile)
                .HasForeignKey<CustomerProfile>(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // REFRESH TOKEN
        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.HasIndex(x => x.TokenHash).IsUnique();

            entity.HasOne(x => x.User)
                .WithMany(x => x.RefreshTokens)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // CATEGORY
        modelBuilder.Entity<Category>()
            .HasIndex(x => x.Name)
            .IsUnique();

        // PRODUCT
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasIndex(x => x.Name);
            entity.HasIndex(x => new { x.CategoryId, x.IsActive });

            entity.Property(x => x.Price).HasPrecision(18, 2);
            entity.Property(x => x.CostPrice).HasPrecision(18, 2);

            entity.HasOne(x => x.Category)
                .WithMany(x => x.Products)
                .HasForeignKey(x => x.CategoryId);
        });

        // SALE
        modelBuilder.Entity<Sale>(entity =>
        {
            entity.HasIndex(x => x.Date);
            entity.HasIndex(x => x.CashierId);
            entity.HasIndex(x => x.ReceiptNumber).IsUnique();

            entity.Property(x => x.PaymentMethod).HasConversion<string>().HasMaxLength(40);
            entity.Property(x => x.Subtotal).HasPrecision(18, 2);
            entity.Property(x => x.DiscountAmount).HasPrecision(18, 2);
            entity.Property(x => x.TotalAmount).HasPrecision(18, 2);
            entity.Property(x => x.ProfitAmount).HasPrecision(18, 2);

            entity.HasOne(x => x.Cashier)
                .WithMany(x => x.Sales)
                .HasForeignKey(x => x.CashierId);
        });

        // SALE ITEM
        modelBuilder.Entity<SaleItem>(entity =>
        {
            entity.HasIndex(x => new { x.SaleId, x.ProductId });

            entity.Property(x => x.Price).HasPrecision(18, 2);
            entity.Property(x => x.CostPrice).HasPrecision(18, 2);

            entity.HasOne(x => x.Sale)
                .WithMany(x => x.Items)
                .HasForeignKey(x => x.SaleId);

            entity.HasOne(x => x.Product)
                .WithMany(x => x.SaleItems)
                .HasForeignKey(x => x.ProductId);
        });

        modelBuilder.Entity<CartItem>(entity =>
        {
            entity.HasIndex(x => new { x.UserId, x.ProductId }).IsUnique();
            entity.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(x => x.Product)
                .WithMany()
                .HasForeignKey(x => x.ProductId);
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => x.CreatedAt);
            entity.HasIndex(x => x.Status);
            entity.Property(x => x.TotalAmount).HasPrecision(18, 2);
            entity.Property(x => x.PaymentMethod).HasConversion<string>().HasMaxLength(40);
            entity.Property(x => x.Status).HasConversion<string>().HasMaxLength(40);
            entity.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId);
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasIndex(x => new { x.OrderId, x.ProductId });
            entity.Property(x => x.Price).HasPrecision(18, 2);
            entity.HasOne(x => x.Order)
                .WithMany(x => x.Items)
                .HasForeignKey(x => x.OrderId);
            entity.HasOne(x => x.Product)
                .WithMany(x => x.OrderItems)
                .HasForeignKey(x => x.ProductId);
        });

        // INVENTORY LOG
        modelBuilder.Entity<InventoryLog>(entity =>
        {
            entity.HasIndex(x => x.ProductId);
            entity.HasIndex(x => x.Date);

            entity.HasOne(x => x.Product)
                .WithMany(x => x.InventoryLogs)
                .HasForeignKey(x => x.ProductId);
        });

        // AI INSIGHT
        modelBuilder.Entity<AIInsight>(entity =>
        {
            entity.HasIndex(x => x.Date);
            entity.Property(x => x.Type).HasConversion<string>().HasMaxLength(60);
        });
    }

}
