using System.Collections.Generic;
using System.Globalization;
using System.Text.Json;
using KaizenekaApi.Models;

namespace KaizenekaApi.Services;

public class QvaPayService : IQvaPayService
{
    private readonly HttpClient _httpClient;
    private readonly string _baseUrl;
    private readonly string _bearerToken;
    private readonly string _appUuid;
    private readonly string _appSecret;
    private readonly string _username;
    private readonly string _successUrl;
    private readonly string _cancelUrl;

    public QvaPayService(IConfiguration configuration)
    {
        _httpClient = new HttpClient();
        var qvaPayConfig = configuration.GetSection("QvaPay");
        _baseUrl = qvaPayConfig["BaseUrl"] ?? "https://api.qvapay.com/app";
        _bearerToken = qvaPayConfig["BearerToken"] ?? throw new ArgumentNullException("QvaPay BearerToken not configured");
        _appUuid = qvaPayConfig["AppUuid"] ?? throw new ArgumentNullException("QvaPay AppUuid not configured");
        _appSecret = qvaPayConfig["AppSecret"] ?? throw new ArgumentNullException("QvaPay AppSecret not configured");
        _username = qvaPayConfig["Username"] ?? throw new ArgumentNullException("QvaPay Username not configured");
        _successUrl = qvaPayConfig["SuccessUrl"] ?? "kaizeneka://payment/success";
        _cancelUrl = qvaPayConfig["CancelUrl"] ?? "kaizeneka://payment/cancel";

        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_bearerToken}");
    }

    public async Task<QvaPayAppInfo> GetAppInfoAsync()
    {
        var response = await _httpClient.GetAsync($"{_baseUrl}/v2/info");
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<QvaPayAppInfo>(content) ?? new QvaPayAppInfo();
    }

    public async Task<QvaPayBalanceResponse> GetAppBalanceAsync()
    {
        var response = await _httpClient.GetAsync($"{_baseUrl}/v2/balance");
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<QvaPayBalanceResponse>(content) ?? new QvaPayBalanceResponse();
    }

    public async Task<QvaPayCoinsResponse> GetCoinsAsync()
    {
        var response = await _httpClient.GetAsync($"{_baseUrl}/coins");
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<QvaPayCoinsResponse>(content) ?? new QvaPayCoinsResponse();
    }

    public async Task<QvaPayP2PResponse> GetP2POffersAsync(string? coin = null, string? type = null)
    {
        var queryParams = new List<string>();
        if (!string.IsNullOrEmpty(coin)) queryParams.Add($"coin={coin}");
        if (!string.IsNullOrEmpty(type)) queryParams.Add($"type={type}");

        var queryString = queryParams.Any() ? $"?{string.Join("&", queryParams)}" : "";
        var response = await _httpClient.GetAsync($"{_baseUrl}/p2p/index{queryString}");
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<QvaPayP2PResponse>(content) ?? new QvaPayP2PResponse();
    }

    public async Task<decimal> GetAveragePriceAsync(string coin)
    {
        var response = await _httpClient.GetAsync($"{_baseUrl}/p2p/completed_pairs_average?coin={coin}");
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        var jsonDoc = JsonDocument.Parse(content);
        if (jsonDoc.RootElement.TryGetProperty("average", out var averageElement))
        {
            return averageElement.GetDecimal();
        }
        return 0;
    }

    public async Task<string> CreatePaymentUrlAsync(decimal amount, string description, string orderId)
    {
        Console.WriteLine($"[QVAPAY] Creating invoice for amount: {amount}, description: {description}, orderId: {orderId}");
        try
        {
            var request = new
            {
                amount = amount,
                description = description,
                remote_id = orderId
            };

            var jsonRequest = JsonSerializer.Serialize(request, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            Console.WriteLine($"[QVAPAY] Invoice request JSON: {jsonRequest}");
            // Crear nueva instancia de HttpClient para este request específico
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Add("app-id", _appUuid);
            client.DefaultRequestHeaders.Add("app-secret", _appSecret);

            var content = new StringContent(jsonRequest, System.Text.Encoding.UTF8, "application/json");
            var response = await client.PostAsync("https://api.qvapay.com/v2/create_invoice", content);

            Console.WriteLine($"[QVAPAY] Invoice response status: {response.StatusCode}");

            if (response.IsSuccessStatusCode)
            {
                var responseContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"[QVAPAY] Invoice response content: {responseContent}");

                var invoiceResponse = JsonSerializer.Deserialize<QvaPayInvoiceResponse>(responseContent);

               Console.WriteLine($"[QVAPAY] Deserialized invoice response - Url: '{invoiceResponse?.Url}', AppId: '{invoiceResponse?.AppId}'");
                if (invoiceResponse?.Url != null && !string.IsNullOrEmpty(invoiceResponse.Url))
                {
                    var finalUrl = invoiceResponse.Url;
                    Console.WriteLine($"[QVAPAY] Invoice URL: {finalUrl}");
                    return finalUrl;
                }
                else
                {
                    Console.WriteLine($"[QVAPAY] Invoice response missing or empty URL: {responseContent}");
                    Console.WriteLine($"[QVAPAY] Invoice response object: Url='{invoiceResponse?.Url}', IsNullOrEmpty={string.IsNullOrEmpty(invoiceResponse?.Url)}");
                    throw new Exception($"Invoice response missing or empty URL. Response: {responseContent}");
                }
            }
            else
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"[QVAPAY] Error creating invoice: {response.StatusCode} - {errorContent}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[QVAPAY] Exception creating invoice: {ex.Message}");
            Console.WriteLine($"[QVAPAY] Stack trace: {ex.StackTrace}");
        }

        // Fallback: retornar una URL de error o mensaje
        Console.WriteLine($"[QVAPAY] Failed to create invoice, returning error URL");
        throw new Exception("No se pudo crear la factura de pago");
    }
}