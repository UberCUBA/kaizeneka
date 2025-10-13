using KaizenekaApi.Models;

namespace KaizenekaApi.Services;

public interface IQvaPayService
{
    Task<QvaPayAppInfo> GetAppInfoAsync();
    Task<QvaPayBalanceResponse> GetAppBalanceAsync();
    Task<QvaPayCoinsResponse> GetCoinsAsync();
    Task<QvaPayP2PResponse> GetP2POffersAsync(string? coin = null, string? type = null);
    Task<decimal> GetAveragePriceAsync(string coin);
    Task<string> CreatePaymentUrlAsync(decimal amount, string description, string orderId);
}