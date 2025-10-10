namespace KaizenekaApi.Models;

public class QvaPayCoin
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public decimal MinAmount { get; set; }
    public decimal MaxAmount { get; set; }
    public decimal Fee { get; set; }
    public bool IsActive { get; set; }
}