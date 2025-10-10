namespace KaizenekaApi.Models;

public class QvaPayP2POffer
{
    public string Uuid { get; set; } = string.Empty;
    public string Coin { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // "buy" or "sell"
    public decimal Amount { get; set; }
    public decimal Price { get; set; }
    public decimal MinAmount { get; set; }
    public decimal MaxAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}