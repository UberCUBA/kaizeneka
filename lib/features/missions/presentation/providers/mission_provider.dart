import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/mission.dart';
import '../../domain/usecases/get_daily_mission.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MissionProvider with ChangeNotifier {
  final GetUser getUser;
  final SaveUser saveUser;
  final GetDailyMission getDailyMission;
  final CompleteMission completeMission;
  final GetAllMissions getAllMissions;
  final AuthProvider authProvider;

  User _user = User();
  bool _isLoading = true;

  MissionProvider({
    required this.getUser,
    required this.saveUser,
    required this.getDailyMission,
    required this.completeMission,
    required this.getAllMissions,
    required this.authProvider,
  }) {
    _loadUser();
    authProvider.addListener(_onAuthChanged);
  }

  User get user => _user;
  bool get isLoading => _isLoading;

  Future<void> _loadUser() async {
    _user = await getUser();
    _isLoading = false;
    notifyListeners();
  }

  void _onAuthChanged() {
    if (authProvider.isAuthenticated) {
      _loadUser();
    } else {
      _user = User();
      _isLoading = false;
      notifyListeners();
    }
  }

  Mission getCurrentDailyMission() {
    return getDailyMission(_user.diasCompletados + 1);
  }

  Future<void> completeCurrentMission() async {
    await completeMission(_user);
    notifyListeners();
  }

  List<Mission> getMissionsList() {
    return getAllMissions();
  }

  Future<void> saveCurrentUser() async {
    await saveUser(_user);
  }

  void addPoints(BuildContext context, int points) {
    _user.puntos += points;
    notifyListeners();
    saveCurrentUser();

    // Sincronizar con Supabase si está autenticado
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      authProvider.updateUserPoints(_user.puntos);
    }
  }
}