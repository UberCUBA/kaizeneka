using System.Text.Json.Serialization;

namespace KaizenekaApi.Models;

public class QvaPayCoinsResponse
{
    [JsonPropertyName("data")]
    public List<QvaPayCoin> Data { get; set; } = new();
}