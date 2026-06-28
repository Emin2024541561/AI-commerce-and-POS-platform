using Microsoft.EntityFrameworkCore;
using SmartAiPos.Api.Data;
using SmartAiPos.Api.Models;

namespace SmartAiPos.Api.Repositories;

public interface IAppRepository
{
    IQueryable<User> Users { get; }
    IQueryable<RefreshToken> RefreshTokens { get; }
    IQueryable<Product> Products { get; }
    IQueryable<Category> Categories { get; }
    IQueryable<Sale> Sales { get; }
    IQueryable<AIInsight> AIInsights { get; }

    IQueryable<CartItem> CartItems { get; }

    IQueryable<Order> Orders { get; }
    IQueryable<OrderItem> OrderItems { get; }

    Task AddAsync<T>(T entity) where T : class;
    void Remove<T>(T entity) where T : class;
    Task<int> SaveChangesAsync();
}

public sealed class EfAppRepository : IAppRepository
{
    private readonly AppDbContext db;

    public EfAppRepository(AppDbContext db)
    {
        this.db = db;
    }

    public IQueryable<User> Users => db.Users;
    public IQueryable<RefreshToken> RefreshTokens => db.RefreshTokens;
    public IQueryable<Product> Products => db.Products;
    public IQueryable<Category> Categories => db.Categories;
    public IQueryable<Sale> Sales => db.Sales;
    public IQueryable<AIInsight> AIInsights => db.AIInsights;

    public IQueryable<CartItem> CartItems => db.CartItems;

    public IQueryable<Order> Orders => db.Orders;
    public IQueryable<OrderItem> OrderItems => db.OrderItems;

    public Task AddAsync<T>(T entity) where T : class
    {
        return db.Set<T>().AddAsync(entity).AsTask();
    }

    public void Remove<T>(T entity) where T : class
    {
        db.Set<T>().Remove(entity);
    }

    public Task<int> SaveChangesAsync()
    {
        return db.SaveChangesAsync();
    }
}
