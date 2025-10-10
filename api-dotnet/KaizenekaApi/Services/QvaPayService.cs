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
        _username = qvaPayConfig["Username"] ?? throw new ArgumentNullException("QvaPay Username not configured");
        _successUrl = qvaPayConfig["SuccessUrl"] ?? "kaizeneka://payment/success";
        _cancelUrl = qvaPayConfig["CancelUrl"] ?? "kaizeneka://payment/cancel";

        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_bearerToken}");
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
        Console.WriteLine($"[QVAPAY] Creating payment URL for amount: {amount}, description: {description}, orderId: {orderId}");

        try
        {
            var request = new QvaPayP2PCreateRequest
            {
                Amount = amount,
                Receive = amount,
                Details = new List<QvaPayDetail>
                {
                    new QvaPayDetail { Name = "Producto", Value = description },
                    new QvaPayDetail { Name = "Orden ID", Value = orderId },
                    new QvaPayDetail { Name = "Tienda", Value = "Kaizeneka Shop" }
                },
                Message = $"Pago por: {description} - Orden #{orderId}"
            };

            var jsonRequest = JsonSerializer.Serialize(request, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            Console.WriteLine($"[QVAPAY] Request JSON: {jsonRequest}");

            var content = new StringContent(jsonRequest, System.Text.Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync($"{_baseUrl}/p2p/create", content);

            Console.WriteLine($"[QVAPAY] Response status: {response.StatusCode}");

            if (response.IsSuccessStatusCode)
            {
                var responseContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"[QVAPAY] Response content: {responseContent}");

                var p2pResponse = JsonSerializer.Deserialize<QvaPayP2PCreateResponse>(responseContent);

                if (p2pResponse?.P2p?.Uuid != null)
                {
                    var finalUrl = $"https://qvapay.com/p2p/{p2pResponse.P2p.Uuid}";
                    Console.WriteLine($"[QVAPAY] Final URL: {finalUrl}");
                    // Retornar URL directa a la oferta P2P creada
                    return finalUrl;
                }
                else
                {
                    Console.WriteLine($"[QVAPAY] P2P response missing UUID: {responseContent}");
                }
            }
            else
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"[QVAPAY] Error creating P2P offer: {response.StatusCode} - {errorContent}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[QVAPAY] Exception creating P2P offer: {ex.Message}");
            Console.WriteLine($"[QVAPAY] Stack trace: {ex.StackTrace}");
        }

        // Fallback: redirigir al marketplace general filtrado por monto
        var formattedAmount = amount.ToString(CultureInfo.InvariantCulture);
        var fallbackUrl = $"https://qvapay.com/p2p?type=buy&min={formattedAmount}&max={formattedAmount}";
        Console.WriteLine($"[QVAPAY] Using fallback URL: {fallbackUrl}");
        return fallbackUrl;
    }
}