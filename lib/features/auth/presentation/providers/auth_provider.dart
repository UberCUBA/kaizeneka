import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../models/user_model.dart';
import '../../../../models.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _apiToken;

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _apiToken != null;
  String? get apiToken => _apiToken;

  AuthProvider() {
    _initialize();
  }

  void _initialize() async {
    _user = SupabaseService.getCurrentUser();
    _apiToken = await _authService.getAccessToken();
    SupabaseService.authStateChanges.listen(_onAuthStateChanged);
    if (_user != null) {
      _loadUserProfile();
    }
  }

  void _onAuthStateChanged(AuthState authState) async {
    _user = authState.session?.user;
    if (_user != null) {
      // Después de autenticarse con Supabase, hacer login en la API
      await _loginToApi();
      _loadUserProfile();
    } else {
      _userProfile = null;
      _apiToken = null;
      await _authService.logout();
    }
    notifyListeners();
  }

  Future<void> _loginToApi() async {
    if (_user == null) return;

    try {
      // Usar email como username para la API (puedes cambiar esto según necesites)
      final username = _user!.email ?? _user!.id;
      final password = 'default_password'; // En producción, genera una contraseña segura

      final result = await _authService.login(username, password);
      if (result?['success'] == true) {
        _apiToken = result?['token'];
      } else {
        debugPrint('Error logging into API: ${result?['message']}');
      }
    } catch (e) {
      debugPrint('Error in API login: $e');
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
      await _authService.logout();
      _apiToken = null;
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

  Future<void> updateUserDiasCompletados(int diasCompletados) async {
    if (_user == null || _userProfile == null) return;

    try {
      await SupabaseService.updateUserDiasCompletados(_user!.id, diasCompletados);
      _userProfile = _userProfile!.copyWith(diasCompletados: diasCompletados);
      await _syncUserProfileToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user dias completados: $e');
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