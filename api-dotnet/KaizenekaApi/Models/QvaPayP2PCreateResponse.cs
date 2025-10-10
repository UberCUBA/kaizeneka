using System.Text.Json.Serialization;

namespace KaizenekaApi.Models;

public class QvaPayP2PCreateResponse
{
    [JsonPropertyName("msg")]
    public string? Msg { get; set; }

    [JsonPropertyName("p2p")]
    public QvaPayP2PCreated? P2p { get; set; }
}

public class QvaPayP2PCreated
{
    [JsonPropertyName("uuid")]
    public string? Uuid { get; set; }

    [JsonPropertyName("type")]
    public string? Type { get; set; }

    [JsonPropertyName("coin")]
    public string? Coin { get; set; }

    [JsonPropertyName("amount")]
    public string? Amount { get; set; }

    [JsonPropertyName("receive")]
    public string? Receive { get; set; }

    [JsonPropertyName("status")]
    public string? Status { get; set; }

    [JsonPropertyName("created_at")]
    public string? CreatedAt { get; set; }

    [JsonPropertyName("updated_at")]
    public string? UpdatedAt { get; set; }
}