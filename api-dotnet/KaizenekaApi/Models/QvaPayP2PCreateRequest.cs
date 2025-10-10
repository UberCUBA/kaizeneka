using System.Text.Json.Serialization;

namespace KaizenekaApi.Models;

public class QvaPayP2PCreateRequest
{
    [JsonPropertyName("type")]
    public string Type { get; set; } = "sell";

    [JsonPropertyName("coin")]
    public int Coin { get; set; } = 33;

    [JsonPropertyName("amount")]
    public decimal Amount { get; set; }

    [JsonPropertyName("receive")]
    public decimal Receive { get; set; }

    [JsonPropertyName("details")]
    public List<QvaPayDetail> Details { get; set; } = new();

    [JsonPropertyName("only_kyc")]
    public int OnlyKyc { get; set; } = 0;

    [JsonPropertyName("private")]
    public int Private { get; set; } = 0;

    [JsonPropertyName("promote_offer")]
    public int PromoteOffer { get; set; } = 0;

    [JsonPropertyName("only_vip")]
    public int OnlyVip { get; set; } = 0;

    [JsonPropertyName("message")]
    public string Message { get; set; } = string.Empty;

    [JsonPropertyName("webhook")]
    public string Webhook { get; set; } = "https://tu-backend.com/api/payments/webhook";
}

public class QvaPayDetail
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("value")]
    public string Value { get; set; } = string.Empty;
}