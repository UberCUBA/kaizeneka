using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using KaizenekaApi.Models;
using KaizenekaApi.Services;

namespace KaizenekaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly IQvaPayService _qvaPayService;
    private static readonly List<PaymentOrder> _orders = new(); // En memoria por simplicidad

    public PaymentsController(IQvaPayService qvaPayService)
    {
        _qvaPayService = qvaPayService;
    }

    [HttpPost("create")]
    public async Task<IActionResult> CreatePayment([FromBody] CreatePaymentRequest request)
    {
        try
        {
            System.Diagnostics.Debugger.Break(); // Punto de interrupción al inicio del método
            // Crear orden de pago
            var order = new PaymentOrder
            {
                ItemId = request.ItemId,
                ItemName = request.ItemName,
                Amount = request.Amount,
                Currency = request.Currency,
                UserId = request.UserId,
                Status = "pending"
            };

            _orders.Add(order);

            System.Diagnostics.Debugger.Break(); // Punto de interrupción antes de crear la URL de pago
            // Crear URL de pago con QvaPay
            var paymentUrl = await _qvaPayService.CreatePaymentUrlAsync(
                order.Amount,
                $"Compra de {order.ItemName}",
                order.Id
            );

            Console.WriteLine($"[PAYMENT] Order created: {order.Id}, Amount: {order.Amount}, URL: {paymentUrl}");

            if (string.IsNullOrEmpty(paymentUrl))
            {
                return BadRequest(new { error = "No se pudo generar la URL de pago" });
            }

            return Ok(new
            {
                orderId = order.Id,
                paymentUrl = paymentUrl,
                amount = order.Amount,
                currency = order.Currency
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("app-info")]
    public async Task<IActionResult> GetAppInfo()
    {
        try
        {
            var appInfo = await _qvaPayService.GetAppInfoAsync();
            return Ok(appInfo);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("app-balance")]
    public async Task<IActionResult> GetAppBalance()
    {
        try
        {
            var balance = await _qvaPayService.GetAppBalanceAsync();
            return Ok(balance);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("coins")]
    public async Task<IActionResult> GetCoins()
    {
        try
        {
            var coins = await _qvaPayService.GetCoinsAsync();
            return Ok(coins);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("p2p-offers")]
    public async Task<IActionResult> GetP2POffers([FromQuery] string? coin, [FromQuery] string? type)
    {
        try
        {
            var offers = await _qvaPayService.GetP2POffersAsync(coin, type);
            return Ok(offers);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("average-price/{coin}")]
    public async Task<IActionResult> GetAveragePrice(string coin)
    {
        try
        {
            var average = await _qvaPayService.GetAveragePriceAsync(coin);
            return Ok(new { coin, average });
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("order/{orderId}")]
    public IActionResult GetOrder(string orderId)
    {
        var order = _orders.FirstOrDefault(o => o.Id == orderId);
        if (order == null)
        {
            return NotFound(new { error = "Order not found" });
        }
        return Ok(order);
    }

    [HttpGet("user-info")]
    public IActionResult GetUserInfo()
    {
        try
        {
            // Información del usuario autenticado en QvaPay
            return Ok(new
            {
                uuid = "17b3821f-a422-44ac-acba-e9257b717038",
                username = "ubervelazquezramirez",
                name = "Uber",
                email = "ubervelazquezramirez@gmail.com",
                balance = "1",
                p2p_enabled = true,
                kyc = true,
                phone_verified = true
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("webhook")]
    public IActionResult PaymentWebhook([FromBody] dynamic payload)
    {
        // Aquí manejarías los webhooks de QvaPay para confirmar pagos
        // Por ahora, solo loggeamos
        Console.WriteLine($"Webhook received: {payload}");
        return Ok();
    }
}