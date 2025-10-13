import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = '$apiBaseUrl/$apiVersion';

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  Future<void> saveTokens(String accessToken, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
    await prefs.setString(tokenExpiryKey, expiry.toIso8601String());
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(tokenExpiryKey);
    await prefs.remove(refreshTokenKey);
  }

  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(tokenExpiryKey);
    if (expiryString == null) return false;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isBefore(expiry.subtract(const Duration(minutes: 5))); // 5 min buffer
  }

  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    final response = await http.get(url, headers: headers);
    return response;
  }

  Future<http.Response> post(String endpoint, {dynamic body, bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    final response = await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }

  Future<http.Response> put(String endpoint, {dynamic body, bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    final response = await http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }

  Future<http.Response> delete(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    final response = await http.delete(url, headers: headers);
    return response;
  }
}