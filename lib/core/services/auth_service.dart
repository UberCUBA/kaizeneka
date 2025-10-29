import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _apiService.post('/Auth/login', body: {
        'username': username,
        'password': password,
      }, includeAuth: false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;

        // Calcular expiración (60 minutos por defecto)
        final expiry = DateTime.now().add(const Duration(minutes: 60));

        // Guardar token
        await _saveTokens(token, expiry);

        return {
          'success': true,
          'token': token,
          'user': {'username': username} // Puedes expandir con más datos del usuario
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error de autenticación'
        };
      }
    } catch (e) {
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        return {
          'success': false,
          'message': '¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!'
        };
      } else {
        return {
          'success': false,
          'message': 'Error de conexión: ${e.toString()}'
        };
      }
    }
  }

  Future<void> logout() async {
    await _apiService.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    return await _apiService.isTokenValid();
  }

  Future<bool> refreshTokenIfNeeded() async {
    if (await isAuthenticated()) {
      return true; // Token aún válido
    }

    // Aquí podrías implementar lógica de refresh token si la API lo soporta
    // Por ahora, solo verificamos si el token actual es válido
    return false;
  }

  Future<String?> getAccessToken() async {
    return await _apiService.getAccessToken();
  }

  Future<void> _saveTokens(String accessToken, DateTime expiry) async {
    await _apiService.saveTokens(accessToken, expiry);
  }
}