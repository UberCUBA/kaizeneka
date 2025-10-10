namespace KaizenekaApi.Models;

public class CreatePaymentRequest
{
    public string ItemId { get; set; } = string.Empty;
    public string ItemName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string UserId { get; set; } = string.Empty;
}