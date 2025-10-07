import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://aipsndkhriquaqddmeyj.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpcHNuZGtocmlxdWFxZGRtZXlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0OTYxODUsImV4cCI6MjA3NTA3MjE4NX0.824Lt83Cp7dWqQM5PHUpc8z57SL6AjhKZS1hkKb_Cyg';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Autenticación con Google
  static Future<AuthResponse> signInWithGoogle() async {
    const webClientId = '227216564417-7om8mcbh0q4oert6vav4b50a2noumna8.apps.googleusercontent.com'; // Client ID de aplicación web para Supabase
    const iosClientId = '227216564417-cgb1l2hqjnjg0qdhn6lncji31m1d8g7u.apps.googleusercontent.com'; // Android

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await client.auth.signOut();
  }

  // Obtener usuario actual
  static User? getCurrentUser() {
    return client.auth.currentUser;
  }

  // Verificar si está autenticado
  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  // Stream de cambios de autenticación
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Obtener perfil de usuario
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Crear o actualizar perfil de usuario
  static Future<UserModel> createOrUpdateUserProfile({
    required String id,
    required String name,
    required String email,
    String belt = 'Blanco',
    int points = 0,
    int diasCompletados = 0,
    List<int> misionesCompletadas = const [],
    List<String> logrosDesbloqueados = const [],
    double? lat,
    double? lng,
    String? avatarUrl,
  }) async {
    final userData = {
      'id': id,
      'name': name,
      'email': email,
      'belt': belt,
      'points': points,
      'dias_completados': diasCompletados,
      'misiones_completadas': misionesCompletadas,
      'logros_desbloqueados': logrosDesbloqueados,
      'lat': lat,
      'lng': lng,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await client
        .from('users')
        .upsert(userData, onConflict: 'id')
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  // Actualizar puntos del usuario
  static Future<void> updateUserPoints(String userId, int points) async {
    await client
        .from('users')
        .update({
          'points': points,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // Actualizar ubicación del usuario
  static Future<void> updateUserLocation(String userId, double lat, double lng) async {
    await client
        .from('users')
        .update({
          'lat': lat,
          'lng': lng,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // Subir imagen a Storage
  static Future<String?> uploadImage(File imageFile, String bucket, String path) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final filePath = '$path/$fileName';

      await client.storage.from(bucket).upload(filePath, imageFile);

      final publicUrl = client.storage.from(bucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}