using System.ComponentModel.DataAnnotations;

namespace SmartAiPos.Api.Models;

public sealed class CustomerProfile
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    [MaxLength(40)] public string? Phone { get; set; }
    [MaxLength(240)] public string? Address { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public User? User { get; set; }
}
