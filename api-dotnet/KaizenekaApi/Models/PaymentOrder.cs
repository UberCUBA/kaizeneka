namespace KaizenekaApi.Models;

public class PaymentOrder
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string ItemId { get; set; } = string.Empty;
    public string ItemName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string UserId { get; set; } = string.Empty;
    public string Status { get; set; } = "pending"; // pending, paid, cancelled
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? PaidAt { get; set; }
    public string? QvaPayTransactionId { get; set; }
}