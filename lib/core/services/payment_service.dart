import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = 'http://10.14.5.15:5102/api'; // URL del backend C#

  Future<Map<String, dynamic>> createPayment({
    required String itemId,
    required String itemName,
    required double amount,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemId': itemId,
        'itemName': itemName,
        'amount': amount,
        'currency': 'USD',
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCoins() async {
    final response = await http.get(Uri.parse('$baseUrl/payments/coins'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get coins: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getP2POffers({String? coin, String? type}) async {
    final queryParams = <String, String>{};
    if (coin != null) queryParams['coin'] = coin;
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/payments/p2p-offers').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get P2P offers: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAveragePrice(String coin) async {
    final response = await http.get(Uri.parse('$baseUrl/payments/average-price/$coin'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get average price: ${response.body}');
    }
  }
}