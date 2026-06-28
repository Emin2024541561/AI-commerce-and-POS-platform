using Microsoft.EntityFrameworkCore;
using SmartAiPos.Api.DTOs;
using SmartAiPos.Api.Models;
using SmartAiPos.Api.Repositories;

namespace SmartAiPos.Api.Services;

public sealed class PublicProductService(IAppRepository repo)
{
    public async Task<PagedResult<PublicProductDto>> GetAsync(PublicProductQuery query)
    {
        var products = BaseProductQuery();

        if (!string.IsNullOrWhiteSpace(query.Search))
            products = products.Where(x => x.Name.Contains(query.Search));

        if (query.CategoryId is not null)
            products = products.Where(x => x.CategoryId == query.CategoryId);

        if (query.MinPrice is not null)
            products = products.Where(x => x.Price >= query.MinPrice);

        if (query.MaxPrice is not null)
            products = products.Where(x => x.Price <= query.MaxPrice);

        products = (query.Sort ?? string.Empty).ToLowerInvariant() switch
        {
            "cheapest" => products.OrderBy(x => x.Price),
            "popular" or "mostpopular" => products.OrderByDescending(x => x.SaleItems.Sum(i => i.Quantity) + x.OrderItems.Sum(i => i.Quantity)),
            "newest" => products.OrderByDescending(x => x.Id),
            _ => products.OrderBy(x => x.Name)
        };

        var page = Math.Max(1, query.Page);
        var pageSize = Math.Clamp(query.PageSize, 1, 60);
        var count = await products.CountAsync();
        var items = await products.Skip((page - 1) * pageSize).Take(pageSize).Select(x => ToPublicDto(x)).ToListAsync();

        return new PagedResult<PublicProductDto>(items, page, pageSize, count);
    }

    public async Task<ProductDetailsDto> GetByIdAsync(int id)
    {
        var product = await BaseProductQuery().FirstOrDefaultAsync(x => x.Id == id)
            ?? throw new KeyNotFoundException("Product not found.");

        var related = await BaseProductQuery()
            .Where(x => x.Id != product.Id && x.CategoryId == product.CategoryId)
            .OrderByDescending(x => x.SaleItems.Sum(i => i.Quantity) + x.OrderItems.Sum(i => i.Quantity))
            .Take(4)
            .Select(x => ToPublicDto(x))
            .ToListAsync();

        var dto = ToPublicDto(product);
        return new ProductDetailsDto(dto.Id, dto.Name, dto.Price, dto.StockQuantity, dto.CategoryId, dto.CategoryName, dto.ImageUrl, dto.IsAvailable, related);
    }

    public Task<IReadOnlyList<PublicProductDto>> FeaturedAsync() =>
        BaseProductQuery().Where(x => x.StockQuantity > 0).OrderByDescending(x => x.Id).Take(8).Select(x => ToPublicDto(x)).ToListAsync().ContinueWith(t => (IReadOnlyList<PublicProductDto>)t.Result);

    public Task<IReadOnlyList<PublicProductDto>> PopularAsync() =>
        BaseProductQuery().OrderByDescending(x => x.SaleItems.Sum(i => i.Quantity) + x.OrderItems.Sum(i => i.Quantity)).Take(8).Select(x => ToPublicDto(x)).ToListAsync().ContinueWith(t => (IReadOnlyList<PublicProductDto>)t.Result);

    public Task<IReadOnlyList<PublicProductDto>> DealsAsync() =>
        BaseProductQuery().Where(x => x.StockQuantity > 0).OrderBy(x => x.Price).Take(8).Select(x => ToPublicDto(x)).ToListAsync().ContinueWith(t => (IReadOnlyList<PublicProductDto>)t.Result);

    public async Task<IReadOnlyList<PublicProductDto>> SearchAsync(string term) =>
        await BaseProductQuery().Where(x => x.Name.Contains(term)).OrderBy(x => x.Name).Take(12).Select(x => ToPublicDto(x)).ToListAsync();

    private IQueryable<Product> BaseProductQuery() =>
        repo.Products.Include(x => x.Category).Include(x => x.SaleItems).Include(x => x.OrderItems).AsNoTracking().Where(x => x.IsActive);

    private static PublicProductDto ToPublicDto(Product product) =>
        new(
            product.Id,
            product.Name,
            product.Price,
            product.StockQuantity,
            product.CategoryId,
            product.Category?.Name ?? "Category",
            $"/images/products/{Uri.EscapeDataString(product.Name.ToLowerInvariant().Replace(' ', '-'))}.png",
            product.StockQuantity > 0,
            product.SaleItems.Sum(x => x.Quantity) + product.OrderItems.Sum(x => x.Quantity)
        );
}

public sealed class CartService(IAppRepository repo)
{
    public async Task<CartDto> GetAsync(Guid userId)
    {
        var items = await repo.CartItems
            .Include(x => x.Product).ThenInclude(x => x!.Category)
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderBy(x => x.Product!.Name)
            .ToListAsync();

        var lines = items.Select(x => new CartLineDto(
            x.ProductId,
            x.Product?.Name ?? "Product",
            x.Product?.Price ?? 0,
            x.Quantity,
            (x.Product?.Price ?? 0) * x.Quantity,
            x.Product?.StockQuantity ?? 0,
            $"/images/products/{Uri.EscapeDataString((x.Product?.Name ?? "product").ToLowerInvariant().Replace(' ', '-'))}.png"
        )).ToList();

        return new CartDto(lines, lines.Sum(x => x.LineTotal));
    }

    public async Task<CartDto> AddAsync(Guid userId, CartMutationRequest request)
    {
        var product = await repo.Products.FirstOrDefaultAsync(x => x.Id == request.ProductId && x.IsActive)
            ?? throw new KeyNotFoundException("Product not found.");

        if (product.StockQuantity <= 0)
            throw new InvalidOperationException($"{product.Name} is out of stock.");

        var quantity = Math.Max(1, request.Quantity);
        var item = await repo.CartItems.FirstOrDefaultAsync(x => x.UserId == userId && x.ProductId == request.ProductId);

        if (item is null)
        {
            item = new CartItem { UserId = userId, ProductId = request.ProductId, Quantity = Math.Min(quantity, product.StockQuantity) };
            await repo.AddAsync(item);
        }
        else
        {
            item.Quantity = Math.Min(item.Quantity + quantity, product.StockQuantity);
            item.UpdatedAt = DateTimeOffset.UtcNow;
        }

        await repo.SaveChangesAsync();
        return await GetAsync(userId);
    }

    public async Task<CartDto> UpdateAsync(Guid userId, CartMutationRequest request)
    {
        var item = await repo.CartItems.FirstOrDefaultAsync(x => x.UserId == userId && x.ProductId == request.ProductId)
            ?? throw new KeyNotFoundException("Cart item not found.");

        if (request.Quantity <= 0)
        {
            repo.Remove(item);
        }
        else
        {
            var stock = await repo.Products.Where(x => x.Id == request.ProductId).Select(x => x.StockQuantity).FirstAsync();
            item.Quantity = Math.Min(request.Quantity, stock);
            item.UpdatedAt = DateTimeOffset.UtcNow;
        }

        await repo.SaveChangesAsync();
        return await GetAsync(userId);
    }

    public async Task<CartDto> RemoveAsync(Guid userId, CartMutationRequest request)
    {
        var item = await repo.CartItems.FirstOrDefaultAsync(x => x.UserId == userId && x.ProductId == request.ProductId);
        if (item is not null)
        {
            repo.Remove(item);
            await repo.SaveChangesAsync();
        }

        return await GetAsync(userId);
    }
}

public sealed class OrderService(IAppRepository repo, CartService cart)
{
    public async Task<OrderDto> CreateAsync(
     Guid userId,
     CreateOrderRequest request)
    {
        var cartItems = await repo.CartItems
            .Include(x => x.Product)
            .Where(x => x.UserId == userId)
            .ToListAsync();


        if (cartItems.Count == 0)
            throw new InvalidOperationException(
                "Cart is empty."
            );


        var order = new Order
        {
            UserId = userId,

            CustomerName = request.Name,

            Phone = request.Phone,

            Address = request.Address,

            PaymentMethod = request.PaymentMethod,

            Status = OrderStatus.Pending
        };



        foreach (var cartItem in cartItems)
        {

            var product =
                cartItem.Product
                ??
                throw new KeyNotFoundException(
                    "Product not found."
                );



            if (!product.IsActive ||
                product.StockQuantity < cartItem.Quantity)

                throw new InvalidOperationException(
                    $"{product.Name} has insufficient stock."
                );



            order.Items.Add(
                new OrderItem
                {

                    ProductId =
                    product.Id,


                    Quantity =
                    cartItem.Quantity,


                    Price =
                    product.Price

                });



            // samo brišemo korpu
            // stock se NE dira ovdje

            repo.Remove(cartItem);

        }



        order.TotalAmount =
            order.Items.Sum(
                x => x.Price * x.Quantity
            );



        await repo.AddAsync(order);


        await repo.SaveChangesAsync();



        return await GetAsync(
            userId,
            order.Id
        );
    }

    public async Task<IReadOnlyList<OrderDto>> MyOrdersAsync(Guid userId) =>
        await repo.Orders
            .Include(x => x.Items).ThenInclude(x => x.Product)
            .AsNoTracking()
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => ToDto(x))
            .ToListAsync();

    public async Task<OrderDto> GetAsync(Guid userId, Guid orderId)
    {
        var order = await repo.Orders
            .Include(x => x.Items).ThenInclude(x => x.Product)
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == orderId && x.UserId == userId)
            ?? throw new KeyNotFoundException("Order not found.");

        return ToDto(order);
    }

    public async Task<OrderStatusDto> StatusAsync(Guid userId, Guid orderId)
    {
        var order = await repo.Orders.AsNoTracking().FirstOrDefaultAsync(x => x.Id == orderId && x.UserId == userId)
            ?? throw new KeyNotFoundException("Order not found.");

        return new OrderStatusDto(order.Id, order.Status, order.CreatedAt, order.CompletedAt);
    }
    public async Task<IReadOnlyList<OrderDto>> PendingAsync()
    {
        return await repo.Orders

            .Include(x => x.Items)
            .ThenInclude(x => x.Product)

            .AsNoTracking()

            .Where(x =>
                x.Status == OrderStatus.Pending)

            .OrderByDescending(
                x => x.CreatedAt)

            .Select(x => ToDto(x))

            .ToListAsync();
    }






    public async Task ApproveAsync(Guid id)
    {
        var order =
            await repo.Orders

            .Include(x => x.Items)

            .FirstAsync(
                x => x.Id == id);



        foreach (var item in order.Items)
        {

            var product =
                await repo.Products

                .FirstAsync(
                    x => x.Id == item.ProductId);



            product.StockQuantity -=
                item.Quantity;



            await repo.AddAsync(
                new InventoryLog
                {

                    ProductId =
                    product.Id,


                    ChangeAmount =
                    -item.Quantity,


                    Reason =
                    $"Approved online order {order.Id}"

                });

        }



        order.Status =
            OrderStatus.Completed;


        order.CompletedAt =
            DateTimeOffset.UtcNow;



        await repo.SaveChangesAsync();

    }






    public async Task RejectAsync(Guid id)
    {

        var order =
            await repo.Orders

            .FirstAsync(
                x => x.Id == id);



        order.Status =
            OrderStatus.Cancelled;



        await repo.SaveChangesAsync();

    }

    private static OrderDto ToDto(Order order) =>
        new(
            order.Id,
            order.Status,
            order.TotalAmount,
            order.PaymentMethod,
            order.CreatedAt,
            order.CustomerName,
            order.Phone,
            order.Address,
            order.Items.Select(x => new OrderItemDto(
                x.ProductId,
                x.Product?.Name ?? "Product",
                x.Quantity,
                x.Price,
                x.Price * x.Quantity
            )).ToList()
        );
}
