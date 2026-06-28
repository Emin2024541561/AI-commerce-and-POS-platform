namespace SmartAiPos.Api.Models;

public sealed class CartItem
{
    public int Id { get; set; }

    public Guid UserId { get; set; }
    public User? User { get; set; }

    public int ProductId { get; set; }
    public Product? Product { get; set; }

    public int Quantity { get; set; }

    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
}
