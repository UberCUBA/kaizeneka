using System.Text.Json.Serialization;

namespace KaizenekaApi.Models;

public class QvaPayInvoiceResponse
{
    [JsonPropertyName("app_id")]
    public string AppId { get; set; } = string.Empty;

    [JsonPropertyName("amount")]
    public string Amount { get; set; } = string.Empty;

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("remote_id")]
    public string RemoteId { get; set; } = string.Empty;

    [JsonPropertyName("transaction_uuid")]
    public string TransactionUuid { get; set; } = string.Empty;

    [JsonPropertyName("url")]
    public string Url { get; set; } = string.Empty;
}