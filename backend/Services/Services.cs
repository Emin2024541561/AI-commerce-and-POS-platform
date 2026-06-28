using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SmartAiPos.Api.Data;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Models;
using SmartAiPos.Api.Repositories;

namespace SmartAiPos.Api.Services;

public sealed class JwtTokenService(IConfiguration configuration)
{
    public (string token, DateTimeOffset expiresAt) CreateAccessToken(User user)
    {
        var jwtKey = configuration["Jwt:Key"];

        if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
            throw new InvalidOperationException("JWT Key is missing or too weak.");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var expires = DateTimeOffset.UtcNow.AddMinutes(
            int.Parse(configuration["Jwt:AccessTokenMinutes"] ?? "60"));

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.FullName),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        var token = new JwtSecurityToken(
            configuration["Jwt:Issuer"],
            configuration["Jwt:Audience"],
            claims,
            expires: expires.UtcDateTime,
            signingCredentials: credentials
        );

        return (new JwtSecurityTokenHandler().WriteToken(token), expires);
    }

    public static string CreateRefreshToken()
        => Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

    public static string HashToken(string token)
        => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
}

public sealed class AuthService(IAppRepository repo, JwtTokenService jwt)
{
    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        if (await repo.Users.AnyAsync(x => x.Email == request.Email))
            throw new InvalidOperationException("Email already exists.");

        var user = new User
        {
            FullName = request.FullName,
            Email = request.Email.Trim().ToLowerInvariant(),
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = UserRole.Customer,
            RefreshTokens = new List<RefreshToken>()
        };

        await repo.AddAsync(user);
        await repo.SaveChangesAsync();

        return await IssueTokensAsync(user);
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var user = await repo.Users
            .FirstOrDefaultAsync(x => x.Email == request.Email.Trim().ToLowerInvariant())
            ?? throw new UnauthorizedAccessException("Invalid credentials.");

        if (!PasswordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        return await IssueTokensAsync(user);
    }

    public async Task<AuthResponse> RefreshAsync(RefreshRequest request)
    {
        var hash = JwtTokenService.HashToken(request.RefreshToken);

        var token = await repo.RefreshTokens
            .Include(x => x.User)
            .FirstOrDefaultAsync(x =>
                x.TokenHash == hash &&
                x.RevokedAt == null &&
                x.ExpiresAt > DateTimeOffset.UtcNow)
            ?? throw new UnauthorizedAccessException("Refresh token is invalid.");

        token.RevokedAt = DateTimeOffset.UtcNow;

        await repo.SaveChangesAsync();

        return await IssueTokensAsync(token.User!);
    }

    private async Task<AuthResponse> IssueTokensAsync(User user)
    {
        var access = jwt.CreateAccessToken(user);
        var refresh = JwtTokenService.CreateRefreshToken();

        var refreshToken = new RefreshToken
        {
            TokenHash = JwtTokenService.HashToken(refresh),
            ExpiresAt = DateTimeOffset.UtcNow.AddDays(14),
            UserId = user.Id
        };

        await repo.AddAsync(refreshToken);
        await repo.SaveChangesAsync();

        return new AuthResponse(
            access.token,
            refresh,
            access.expiresAt,
            new UserDto(user.Id, user.FullName, user.Email, user.Role)
        );
    }
}

public sealed class ProductService(IAppRepository repo)
{
    public async Task<IReadOnlyList<CategoryDto>> CategoriesAsync()
        => await repo.Categories.OrderBy(x => x.Name)
            .Select(x => new CategoryDto(x.Id, x.Name))
            .ToListAsync();

    public async Task<IReadOnlyList<ProductDto>> GetAsync(
    string? search = null,
    int? categoryId = null)
    {
        var query = repo.Products
            .Include(x => x.Category)
            .AsNoTracking()
            .Where(x => x.IsActive);


        // FILTER PO KATEGORIJI
        if (categoryId.HasValue)
        {
            query = query.Where(x =>
                x.CategoryId == categoryId.Value);
        }


        // SEARCH
        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(x =>
                EF.Functions.Like(
                    x.Name,
                    $"%{search}%"
                ));
        }


        return await query
            .OrderBy(x => x.Name)
            .Select(x => new ProductDto(
                x.Id,
                x.Name,
                x.Price,
                x.CostPrice,
                x.StockQuantity,
                x.ReorderLevel,
                x.CategoryId,
                x.Category!.Name,
                x.IsActive
            ))
            .ToListAsync();
    }

    public async Task<ProductDto> UpsertAsync(int? id, UpsertProductRequest request)
    {
        var product = id is null
            ? new Product { Name = request.Name }
            : await repo.Products.FirstOrDefaultAsync(x => x.Id == id)
              ?? throw new KeyNotFoundException("Product not found.");

        product.Name = request.Name;
        product.Price = request.Price;
        product.CostPrice = request.CostPrice;
        product.StockQuantity = request.StockQuantity;
        product.ReorderLevel = request.ReorderLevel;
        product.CategoryId = request.CategoryId;
        product.IsActive = request.IsActive;

        if (id is null)
            await repo.AddAsync(product);

        await repo.SaveChangesAsync();

        var saved = await repo.Products.Include(x => x.Category)
            .FirstAsync(x => x.Id == product.Id);

        return new ProductDto(
            saved.Id, saved.Name, saved.Price, saved.CostPrice,
            saved.StockQuantity, saved.ReorderLevel,
            saved.CategoryId, saved.Category!.Name, saved.IsActive);
    }

    public async Task DeleteAsync(int id)
    {
        var product = await repo.Products.FirstOrDefaultAsync(x => x.Id == id)
            ?? throw new KeyNotFoundException("Product not found.");

        product.IsActive = false;
        await repo.SaveChangesAsync();
    }
}

public sealed class SaleService(IAppRepository repo)
{
    public async Task<SaleDto> CreateAsync(CreateSaleRequest request)
    {
        if (request.Items.Count == 0)
            throw new InvalidOperationException("Sale must include at least one item.");

        var productIds = request.Items.Select(x => x.ProductId).ToHashSet();

        var products = await repo.Products
            .Where(x => productIds.Contains(x.Id) && x.IsActive)
            .ToDictionaryAsync(x => x.Id);

        var sale = new Sale
        {
            CashierId = request.CashierId,
            PaymentMethod = request.PaymentMethod,
            ReceiptNumber = $"R-{DateTimeOffset.UtcNow:yyyyMMddHHmmssfff}",
            Items = new List<SaleItem>()
        };

        foreach (var item in request.Items)
        {
            if (item.Quantity <= 0)
                throw new InvalidOperationException("Invalid quantity.");

            if (!products.TryGetValue(item.ProductId, out var product))
                throw new KeyNotFoundException($"Product {item.ProductId} not found.");

            if (product.StockQuantity < item.Quantity)
                throw new InvalidOperationException($"{product.Name} has insufficient stock.");

            product.StockQuantity -= item.Quantity;

            sale.Items.Add(new SaleItem
            {
                ProductId = product.Id,
                Quantity = item.Quantity,
                Price = product.Price,
                CostPrice = product.CostPrice
            });

            await repo.AddAsync(new InventoryLog
            {
                ProductId = product.Id,
                ChangeAmount = -item.Quantity,
                Reason = $"Sale {sale.ReceiptNumber}"
            });
        }

        sale.Subtotal = sale.Items.Sum(x => x.Price * x.Quantity);

        var discount = Math.Min(request.DiscountAmount, sale.Subtotal);

        sale.DiscountAmount = discount;
        sale.TotalAmount = sale.Subtotal - discount;

        sale.ProfitAmount =
            sale.Items.Sum(x => (x.Price - x.CostPrice) * x.Quantity) - discount;

        await repo.AddAsync(sale);
        await repo.SaveChangesAsync();

        return await GetAsync(sale.Id);
    }

    public async Task<IReadOnlyList<SaleDto>> GetAsync(DateTimeOffset? from = null, DateTimeOffset? to = null)
    {
        var query = repo.Sales.Include(x => x.Cashier)
            .Include(x => x.Items).ThenInclude(x => x.Product)
            .AsNoTracking();

        if (from is not null)
            query = query.Where(x => x.Date >= from);

        if (to is not null)
            query = query.Where(x => x.Date <= to);

        return await query.OrderByDescending(x => x.Date)
            .Take(250)
            .Select(x => ToDto(x))
            .ToListAsync();
    }

    public async Task<SaleDto> GetAsync(Guid id)
    {
        var sale = await repo.Sales.Include(x => x.Cashier)
            .Include(x => x.Items).ThenInclude(x => x.Product)
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id)
            ?? throw new KeyNotFoundException("Sale not found.");

        return ToDto(sale);
    }

    private static SaleDto ToDto(Sale sale)
        => new(
            sale.Id,
            sale.ReceiptNumber,
            sale.Subtotal,
            sale.DiscountAmount,
            sale.TotalAmount,
            sale.ProfitAmount,
            sale.Date,
            sale.Cashier?.FullName ?? "Unknown",
            sale.PaymentMethod,
            sale.Items.Select(x =>
                new SaleItemDto(
                    x.ProductId,
                    x.Product?.Name ?? "Product",
                    x.Quantity,
                    x.Price,
                    x.Price * x.Quantity
                )).ToList()
        );
}

public sealed class InventoryService(IAppRepository repo)
{
    public async Task<IReadOnlyList<LowStockDto>> LowStockAsync()
        => await repo.Products.AsNoTracking()
            .Where(x => x.IsActive && x.StockQuantity <= x.ReorderLevel)
            .OrderBy(x => x.StockQuantity)
            .Select(x => new LowStockDto(x.Id, x.Name, x.StockQuantity, x.ReorderLevel))
            .ToListAsync();

    public async Task UpdateAsync(InventoryUpdateRequest request)
    {
        var product = await repo.Products.FirstOrDefaultAsync(x => x.Id == request.ProductId)
            ?? throw new KeyNotFoundException("Product not found.");

        product.StockQuantity += request.ChangeAmount;

        if (product.StockQuantity < 0)
            product.StockQuantity = 0;

        await repo.AddAsync(new InventoryLog
        {
            ProductId = request.ProductId,
            ChangeAmount = request.ChangeAmount,
            Reason = request.Reason
        });

        await repo.SaveChangesAsync();
    }
}

public sealed class DashboardService(IAppRepository repo)
{
    public async Task<DashboardStatsDto> StatsAsync()
    {
        var from = DateTimeOffset.UtcNow.AddDays(-30);
        var sales = repo.Sales.Where(x => x.Date >= from);

        var top = (await repo.Sales
            .SelectMany(x => x.Items)
            .Include(x => x.Product)
            .ToListAsync())
            .GroupBy(x => new { x.ProductId, Name = x.Product?.Name ?? "Unknown" })
            .Select(g => new ProductSalesDto(
                g.Key.ProductId,
                g.Key.Name,
                g.Sum(x => x.Quantity),
                g.Sum(x => x.Price * x.Quantity)
            ))
            .OrderByDescending(x => x.QuantitySold)
            .Take(5)
            .ToList();

        var dailyData = await sales.ToListAsync();

        var daily = dailyData
            .GroupBy(x => x.Date.Date)
            .Select(g => new DailyRevenueDto(
                DateOnly.FromDateTime(g.Key),
                g.Sum(x => x.TotalAmount),
                g.Count()))
            .OrderBy(x => x.Date)
            .ToList();

        return new DashboardStatsDto(
            await repo.Sales.SumAsync(x => (decimal?)x.TotalAmount) ?? 0m,
            await repo.Sales.SumAsync(x => (decimal?)x.ProfitAmount) ?? 0m,
            await repo.Sales.CountAsync(),
            await repo.Products.CountAsync(x => x.IsActive),
            await repo.Products.CountAsync(x => x.IsActive && x.StockQuantity <= x.ReorderLevel),
            top,
            daily
        );
    }
}

public sealed class AiService(IAppRepository repo, DashboardService dashboard)
{
    public async Task<SalesForecastDto> ForecastSalesAsync()
    {
        var stats = await dashboard.StatsAsync();
        var avg = stats.DailyRevenue.Count == 0 ? 0 : stats.DailyRevenue.Average(x => x.Revenue);
        var recent = stats.DailyRevenue.TakeLast(7).ToList();
        var next = Math.Round((recent.Count == 0 ? avg : recent.Average(x => x.Revenue)) * 1.06m, 2);

        var message = $"Next day forecast is {next} BAM based on the last {recent.Count} trading days.";

        await SaveInsightAsync(InsightType.SalesForecast, message);

        return new SalesForecastDto(next, recent, "medium", message);
    }

    public async Task<IReadOnlyList<RestockSuggestionDto>> RecommendRestockAsync()
    {
        var sold = await repo.Sales.Where(x => x.Date >= DateTimeOffset.UtcNow.AddDays(-14))
            .SelectMany(x => x.Items)
            .GroupBy(x => x.ProductId)
            .Select(g => new { ProductId = g.Key, Daily = g.Sum(x => x.Quantity) / 14.0 })
            .ToListAsync();

        var velocity = sold.ToDictionary(x => x.ProductId, x => Math.Max(0.3, x.Daily));

        var products = await repo.Products.Where(x => x.IsActive && x.StockQuantity <= x.ReorderLevel * 2).ToListAsync();

        var suggestions = products.Select(p =>
        {
            var daily = velocity.GetValueOrDefault(p.Id, 0.5);
            var runout = Math.Max(1, (int)Math.Ceiling(p.StockQuantity / daily));
            var qty = Math.Max(p.ReorderLevel * 2 - p.StockQuantity, (int)Math.Ceiling(daily * 14));

            return new RestockSuggestionDto(
                p.Id, p.Name, p.StockQuantity, qty, runout,
                $"Order {qty} units of {p.Name}; expected to run out in {runout} days.");
        })
        .OrderBy(x => x.EstimatedRunoutDays)
        .ToList();

        await SaveInsightAsync(InsightType.Restock, $"{suggestions.Count} restock suggestions generated.");
        return suggestions;
    }

    public async Task<PopularityAnalysisDto> PopularityAsync()
    {
        var salesData = await repo.Sales
            .SelectMany(x => x.Items)
            .GroupBy(x => new
            {
                x.ProductId,
                x.Product!.Name
            })
            .Select(g => new
            {
                ProductId = g.Key.ProductId,

                ProductName = g.Key.Name,

                QuantitySold =
                    g.Sum(x => x.Quantity),

                Revenue =
                    g.Sum(x =>
                        x.Price * x.Quantity)
            })
            .OrderByDescending(x => x.QuantitySold)
            .Take(10)
            .ToListAsync();



        var best = salesData
            .Select(x =>
                new ProductSalesDto(

                    x.ProductId,

                    x.ProductName,

                    x.QuantitySold,

                    x.Revenue

                ))
            .ToList();



        // ============================
        // AI SMART SUGGESTIONS
        // ============================


        var suggestions =
            new List<string>();


        var top =
            best.Select(x => x.ProductName)
                .ToList();



        if (top.Count >= 2)
        {
            suggestions.Add(
                $"?? Smart combo: {top[0]} + {top[1]}"
            );
        }



        if (top.Count >= 3)
        {
            suggestions.Add(
                $"? Premium bundle: {top[0]} + {top[1]} + {top[2]}"
            );
        }




        var winner =
            best.FirstOrDefault();



        if (winner != null)
        {
            suggestions.Add(
                $"?? {winner.ProductName} is your current best seller with {winner.QuantitySold} sold."
            );


            suggestions.Add(
                $"?? Promote {winner.ProductName}, demand is currently strongest."
            );
        }




        if (suggestions.Count == 0)
        {
            suggestions.Add(
                "Collect more sales data for AI analysis."
            );
        }



        await SaveInsightAsync(
            InsightType.Popularity,
            "AI best seller analysis generated."
        );



        return new PopularityAnalysisDto(
            best,
            suggestions
        );

    }
    public async Task<IReadOnlyList<ProfitAnalysisDto>> ProfitAnalysisAsync()
    {
        var profitData = await repo.Sales
            .SelectMany(x => x.Items)
            .GroupBy(x => new
            {
                x.ProductId,
                x.Product!.Name,
                x.Product!.CostPrice
            })
            .Select(g => new
            {
                ProductId = g.Key.ProductId,

                ProductName = g.Key.Name,

                QuantitySold =
                    g.Sum(x => x.Quantity),

                Revenue =
                    g.Sum(x =>
                        x.Price * x.Quantity),

                Cost =
                    g.Sum(x =>
                        g.Key.CostPrice *
                        x.Quantity)
            })
            .OrderByDescending(x =>
                x.Revenue - x.Cost)

            .Take(10)

            .ToListAsync();



        var result =
            profitData.Select(x =>
            {

                var profit =
                    x.Revenue - x.Cost;



                var margin =
                    x.Revenue == 0
                        ? 0
                        :
                        Math.Round(
                            profit /
                            x.Revenue *
                            100,
                            2
                        );



                string aiMessage;



                if (margin >= 60)
                {
                    aiMessage =
                        "High profit product. Increase promotion.";
                }

                else if (margin >= 30)
                {
                    aiMessage =
                        "Stable profit product.";
                }

                else
                {
                    aiMessage =
                        "Low margin product. Review price strategy.";
                }



                return new ProfitAnalysisDto(

                    x.ProductId,

                    x.ProductName,

                    x.QuantitySold,

                    x.Revenue,

                    x.Cost,

                    profit,

                    margin,

                    aiMessage
                );


            })
            .ToList();



        await SaveInsightAsync(
            InsightType.BusinessSummary,
            "Profit analyzer generated."
        );



        return result;
    }
    public async Task<IReadOnlyList<SmartDealDto>> SmartDealsAsync()
    {
        var products = await repo.Sales
            .SelectMany(x => x.Items)
            .GroupBy(x => new
            {
                x.ProductId,
                x.Product!.Name,
                x.Product.Price,
                x.Product.CostPrice
            })
            .Select(g => new
            {
                Id =
                    g.Key.ProductId,

                Name =
                    g.Key.Name,

                Price =
                    g.Key.Price,

                Cost =
                    g.Key.CostPrice,


                Sold =
                    g.Sum(x =>
                        x.Quantity)
            })

            .OrderByDescending(x =>
                x.Sold)

            .Take(6)

            .ToListAsync();



        var deals =
            new List<SmartDealDto>();



        for (int i = 0; i < products.Count - 1; i += 2)
        {

            var first =
                products[i];


            var second =
                products[i + 1];



            var original =
                first.Price +
                second.Price;



            var dealPrice =
                Math.Round(
                    original * 0.90m,
                    2
                );



            var cost =
                first.Cost +
                second.Cost;



            var profit =
                dealPrice - cost;



            string reason;


            if (profit > cost)
            {
                reason =
                    "High margin combo. Recommended for promotion.";
            }

            else
            {
                reason =
                    "Popular products bundle to increase sales volume.";
            }



            deals.Add(

                new SmartDealDto(

                    first.Id,

                    first.Name,


                    second.Id,

                    second.Name,


                    original,

                    dealPrice,


                    10,


                    profit,


                    reason

                )
            );

        }



        await SaveInsightAsync(
            InsightType.BusinessSummary,
            "Smart deals generated."
        );



        return deals;
    }
    public async Task<IReadOnlyList<CustomerRecommendationDto>>
    CustomerRecommendationsAsync(Guid userId)
    {
        var boughtCategories = await repo.Orders
            .Where(x => x.UserId == userId)
            .SelectMany(x => x.Items)
            .Select(x => x.Product.CategoryId)
            .Distinct()
            .ToListAsync();



        var alreadyBought = await repo.Orders
            .Where(x => x.UserId == userId)
            .SelectMany(x => x.Items)
            .Select(x => x.ProductId)
            .Distinct()
            .ToListAsync();



        var query =
            repo.Products
            .Include(x => x.Category)
            .Where(x =>
                x.IsActive &&
                !alreadyBought.Contains(x.Id));



        if (boughtCategories.Any())
        {
            query =
                query.Where(x =>
                    boughtCategories
                        .Contains(x.CategoryId));
        }



        var products =
            await query
            .OrderByDescending(x =>
                x.SaleItems.Sum(s =>
                    s.Quantity))

            .Take(10)

            .Select(x =>
                new CustomerRecommendationDto(

                    x.Id,

                    x.Name,

                    x.Category.Name,

                    x.Price,


                    boughtCategories.Any()
                    ?
                    "Recommended because of your purchase history."
                    :
                    "Popular product recommendation."

                ))

            .ToListAsync();



        await SaveInsightAsync(
            InsightType.BusinessSummary,
            "Customer recommendations generated."
        );


        return products;
    }
    public async Task<AiAssistantResponse> AssistantAsync(
    AiAssistantRequest request)
    {


        var message =
            request.Message.ToLower();



        var productsQuery =
            repo.Products
            .Include(x => x.Category)
            .Where(x => x.IsActive);



        // ===========================
        // BUDGET DETECTION
        // ===========================


        decimal budget = 0;


        var numbers =
            System.Text.RegularExpressions.Regex
            .Matches(message, @"\d+");


        if (numbers.Count > 0)
        {
            budget =
                decimal.Parse(
                    numbers[0].Value
                );
        }



        // ===========================
        // MOOD DETECTION
        // ===========================


        if (
            message.Contains("gladan") ||
            message.Contains("hrana") ||
            message.Contains("jesti")
        )
        {
            productsQuery =
                productsQuery.Where(x =>
                    x.Category.Name.Contains("Food") ||
                    x.Category.Name.Contains("Burger")
                );
        }


        if (
            message.Contains("slatko") ||
            message.Contains("cokolada") ||
            message.Contains("čokolada") ||
            message.Contains("desert")
        )
        {
            productsQuery =
                productsQuery.Where(x =>

                    x.Category.Name.ToLower().Contains("cokol") ||

                    x.Category.Name.ToLower().Contains("čokol") ||

                    x.Category.Name.ToLower().Contains("desert") ||

                    x.Name.ToLower().Contains("toblerone") ||

                    x.Name.ToLower().Contains("cokol") ||

                    x.Name.ToLower().Contains("čokol")

                );
        }



        if (
            message.Contains("pice") ||
            message.Contains("piće") ||
            message.Contains("zedan")
        )
        {
            productsQuery =
                productsQuery.Where(x =>
                    x.Category.Name.Contains("Drinks") ||
                    x.Category.Name.Contains("pica")
                );
        }



        var products =
            await productsQuery
            .OrderByDescending(x =>
                x.SaleItems.Sum(s => s.Quantity)
            )
            .Take(20)
            .ToListAsync();



        // ===========================
        // BUDGET AI
        // ===========================


        var selected =
            new List<Product>();


        decimal total = 0;


        foreach (var p in products)
        {

            if (
                budget == 0 ||
                total + p.Price <= budget
            )
            {

                selected.Add(p);

                total += p.Price;

            }

        }



        if (selected.Count == 0)
        {
            selected =
                products.Take(3)
                .ToList();


            total =
                selected.Sum(x => x.Price);
        }



        var text =
$"Kreirao sam pametnu korpu sa {selected.Count} proizvoda. Ukupna cijena je {total:0.00} KM.";


        if (budget > 0)
        {
            text +=
                $" Tvoj budžet je bio {budget:0.00} BAM.";
        }



        await SaveInsightAsync(
            InsightType.BusinessSummary,
            "Customer AI assistant used."
        );



        return new AiAssistantResponse(

            text,


            total,


            selected.Select(x =>
                new AiAssistantProductDto(

                    x.Id,

                    x.Name,

                    x.Price,

                    x.Category.Name

                ))

            .ToList()

        );
    }
    public async Task<IReadOnlyList<AnomalyDto>> AnomaliesAsync()
    {
        var today = DateTimeOffset.UtcNow.Date;

        var todayRevenue = await repo.Sales.Where(x => x.Date >= today)
            .SumAsync(x => (decimal?)x.TotalAmount) ?? 0m;

        var avg = await repo.Sales.Where(x => x.Date < today && x.Date >= today.AddDays(-14))
            .GroupBy(x => x.Date.Date)
            .Select(g => g.Sum(x => x.TotalAmount))
            .AverageAsync(x => (decimal?)x) ?? 0m;

        var anomalies = new List<AnomalyDto>();

        if (avg > 0 && todayRevenue < avg * 0.55m)
            anomalies.Add(new AnomalyDto("SalesDrop", "High",
                $"Today revenue is materially below the 14-day average ({todayRevenue:0.00} vs {avg:0.00} BAM)."));

        var low = await repo.Products.CountAsync(x => x.StockQuantity < 0);

        if (low > 0)
            anomalies.Add(new AnomalyDto("StockMismatch", "Critical",
                $"{low} products have negative stock."));

        if (anomalies.Count == 0)
            anomalies.Add(new AnomalyDto("Normal", "Info", "No material anomalies detected."));

        await SaveInsightAsync(InsightType.Anomaly, anomalies[0].Message);
        return anomalies;
    }

    public async Task<AIInsightDto> BusinessSummaryAsync()
    {
        var stats = await dashboard.StatsAsync();

        var top = stats.TopSellingProducts.FirstOrDefault()?.ProductName ?? "products";

        var message =
            $"Revenue is {stats.TotalRevenue:0.00} BAM across {stats.TotalSalesCount} sales. " +
            $"{top} is currently leading demand, with {stats.LowStockAlerts} low-stock alerts requiring attention.";

        await SaveInsightAsync(InsightType.BusinessSummary, message);

        return new AIInsightDto(InsightType.BusinessSummary, message, DateTimeOffset.UtcNow);
    }

    public async Task<IReadOnlyList<AIInsightDto>> InsightsAsync()
        => await repo.AIInsights.OrderByDescending(x => x.Date)
            .Take(20)
            .Select(x => new AIInsightDto(x.Type, x.Message, x.Date))
            .ToListAsync();

    private async Task SaveInsightAsync(InsightType type, string message)
    {
        await repo.AddAsync(new AIInsight { Type = type, Message = message });
        await repo.SaveChangesAsync();
    }
}