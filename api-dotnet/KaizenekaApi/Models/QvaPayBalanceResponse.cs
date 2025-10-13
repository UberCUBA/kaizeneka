namespace KaizenekaApi.Models;

public class QvaPayBalanceResponse
{
    public decimal Balance { get; set; }
    public string Currency { get; set; } = "USD";
    public DateTime LastUpdated { get; set; }
}