using System.Text.Json.Serialization;

namespace KaizenekaApi.Models;

public class QvaPayP2PResponse
{
    [JsonPropertyName("data")]
    public List<QvaPayP2POffer> Data { get; set; } = new();
}