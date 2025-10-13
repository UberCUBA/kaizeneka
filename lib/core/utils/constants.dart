import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF00FF7F);
const Color backgroundColor = Colors.black;
const Color surfaceColor = Color(0xFF1C1C1C);
const Color textColor = Colors.white;

// API Configuration
const String apiBaseUrl = 'http://localhost:8080'; // Cambia a tu URL de producción
const String apiVersion = 'api';

// JWT Token Keys
const String accessTokenKey = 'access_token';
const String refreshTokenKey = 'refresh_token';
const String tokenExpiryKey = 'token_expiry';