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
  static Future<bool> signInWithGoogle() async {
    try {
      final response = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.example.kaizeneka://login-callback',
      );
      return response;
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      return false;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
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

  // Actualizar usuario con campos dinámicos
  static Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await client
        .from('users')
        .update(updates)
        .eq('id', userId);
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
      'location_lat': lat,
      'location_lng': lng,
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

  // Actualizar días completados del usuario
  static Future<void> updateUserDiasCompletados(String userId, int diasCompletados) async {
    await client
        .from('users')
        .update({
          'dias_completados': diasCompletados,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // Actualizar ubicación del usuario
  static Future<void> updateUserLocation(String userId, double lat, double lng) async {
    await client
        .from('users')
        .update({
          'location_lat': lat,
          'location_lng': lng,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // Actualizar estado del tutorial completado
  static Future<void> updateUserTutorialCompleted(String userId, bool completed) async {
    await client
        .from('users')
        .update({
          'tutorial_completed': completed,
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