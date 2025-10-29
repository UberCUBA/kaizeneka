import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PaymentService {
  static const String baseUrl = 'https://nk-api.fly.dev/api'; // URL del backend C#

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> createPayment({
    required String itemId,
    required String itemName,
    required double amount,
    required String userId,
  }) async {
    final headers = await _getHeaders(includeAuth: true);
    final response = await http.post(
      Uri.parse('$baseUrl/Payments/create'),
      headers: headers,
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
      print('Payment API Error - Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAppInfo() async {
    final headers = await _getHeaders(includeAuth: true);
    final response = await http.get(Uri.parse('$baseUrl/Payments/app-info'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get app info: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAppBalance() async {
    final headers = await _getHeaders(includeAuth: true);
    final response = await http.get(Uri.parse('$baseUrl/Payments/app-balance'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get app balance: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCoins() async {
    final headers = await _getHeaders(includeAuth: true);
    final response = await http.get(Uri.parse('$baseUrl/Payments/coins'), headers: headers);

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

    final headers = await _getHeaders(includeAuth: true);
    final uri = Uri.parse('$baseUrl/Payments/p2p-offers').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get P2P offers: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAveragePrice(String coin) async {
    final headers = await _getHeaders(includeAuth: true);
    final response = await http.get(Uri.parse('$baseUrl/Payments/average-price/$coin'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get average price: ${response.body}');
    }
  }
}