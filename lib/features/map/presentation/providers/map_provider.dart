import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/kaizeneka_user.dart';
import '../../domain/usecases/get_nearby_users.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MapProvider extends ChangeNotifier {
  LatLng? _userLocation;
  bool _showUserLocation = false; // Modo incognito por defecto
  bool _isLoading = false;
  List<KaizenekaUser> _nearbyUsers = [];
  String? _privacyMessage;
  Timer? _locationUpdateTimer;

  LatLng? get userLocation => _userLocation;
  bool get showUserLocation => _showUserLocation;
  bool get isLoading => _isLoading;
  List<KaizenekaUser> get nearbyUsers => _nearbyUsers;
  String? get privacyMessage => _privacyMessage;

  final GetNearbyUsers _getNearbyUsers;
  final AuthProvider _authProvider;

  MapProvider(this._getNearbyUsers, this._authProvider) {
    _authProvider.addListener(_onAuthChanged);
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    if (status.isGranted) {
      await getCurrentLocation();
    } else {
      _privacyMessage = "Sin ubicación no hay tribu. Dale permisos, Kaizeneka.";
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLocation = LatLng(position.latitude, position.longitude);
      await updateUserLocationInDb();
      await loadNearbyUsers();
      startLocationUpdateTimer();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserLocationInDb() async {
    if (_userLocation != null && SupabaseService.getCurrentUser() != null) {
      await SupabaseService.updateUserLocation(
        SupabaseService.getCurrentUser()!.id,
        _userLocation!.latitude,
        _userLocation!.longitude,
      );
    }
  }

  void startLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_showUserLocation) {
        await getCurrentLocation();
      }
    });
  }

  void toggleShowLocation() {
    _showUserLocation = !_showUserLocation;
    if (_showUserLocation) {
      _privacyMessage = "Modo Incognito desactivado 🌍. Los kaizenekas pueden verte.";
    } else {
      _privacyMessage = "Modo Incognito activado 🥷. Estás oculto, Kaizeneka.";
    }
    notifyListeners();
  }

  Future<void> loadNearbyUsers() async {
    if (_userLocation != null) {
      _nearbyUsers = await _getNearbyUsers(_userLocation!);
      notifyListeners();
    }
  }

  void clearPrivacyMessage() {
    _privacyMessage = null;
    notifyListeners();
  }

  void _onAuthChanged() {
    if (_authProvider.isAuthenticated) {
      // Reset location and nearby users when user changes
      _userLocation = null;
      _nearbyUsers = [];
      _privacyMessage = null;
      notifyListeners();
    } else {
      // Clear on logout
      _userLocation = null;
      _nearbyUsers = [];
      _privacyMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}