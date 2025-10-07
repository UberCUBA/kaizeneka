import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/supabase_service.dart';
import '../../../../models/user_model.dart';
import '../../../../models.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = SupabaseService.getCurrentUser();
    SupabaseService.authStateChanges.listen(_onAuthStateChanged);
    if (_user != null) {
      _loadUserProfile();
    }
  }

  void _onAuthStateChanged(AuthState authState) {
    _user = authState.session?.user;
    notifyListeners();

    if (_user != null) {
      _loadUserProfile();
    } else {
      _userProfile = null;
    }
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      _userProfile = await SupabaseService.getUserProfile(_user!.id);
      if (_userProfile == null) {
        // Crear perfil si no existe
        await _createUserProfile();
      } else {
        // Sincronizar datos de Supabase a local
        await _syncUserProfileToLocal();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _createUserProfile() async {
    if (_user == null) return;

    try {
      final name = _user!.userMetadata?['full_name'] ?? _user!.userMetadata?['name'] ?? 'Usuario';
      final email = _user!.email ?? '';

      // Load local user data
      final prefs = await SharedPreferences.getInstance();
      final localUserJson = prefs.getString('usuario');
      Usuario? localUser;
      if (localUserJson != null) {
        localUser = Usuario.fromJson(json.decode(localUserJson) as Map<String, dynamic>);
      }

      _userProfile = await SupabaseService.createOrUpdateUserProfile(
        id: _user!.id,
        name: name,
        email: email,
        belt: localUser?.cinturonActual ?? 'Blanco',
        points: localUser?.puntos ?? 0,
        diasCompletados: localUser?.diasCompletados ?? 0,
        misionesCompletadas: localUser?.misionesCompletadas ?? [],
        logrosDesbloqueados: localUser?.logrosDesbloqueados ?? [],
      );
      // Sincronizar a local después de crear
      await _syncUserProfileToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  Future<void> _syncUserProfileToLocal() async {
    if (_userProfile == null) return;

    try {
      final localUser = Usuario(
        diasCompletados: _userProfile!.diasCompletados,
        cinturonActual: _userProfile!.belt,
        puntos: _userProfile!.points,
        misionesCompletadas: _userProfile!.misionesCompletadas,
        logrosDesbloqueados: _userProfile!.logrosDesbloqueados,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', json.encode(localUser.toJson()));
    } catch (e) {
      debugPrint('Error syncing user profile to local: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.signInWithGoogle();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.signOut();
      // Limpiar datos locales al cerrar sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('usuario');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserPoints(int points) async {
    if (_user == null || _userProfile == null) return;

    try {
      await SupabaseService.updateUserPoints(_user!.id, points);
      _userProfile = _userProfile!.copyWith(points: points);
      await _syncUserProfileToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user points: $e');
    }
  }

  Future<void> updateUserLocation(double lat, double lng) async {
    if (_user == null || _userProfile == null) return;

    try {
      await SupabaseService.updateUserLocation(_user!.id, lat, lng);
      _userProfile = _userProfile!.copyWith(location: LatLng(lat, lng));
      await _syncUserProfileToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  Future<void> reloadUserProfile() async {
    await _loadUserProfile();
  }
}