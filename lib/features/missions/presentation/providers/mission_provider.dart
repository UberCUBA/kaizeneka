import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../../models/task_models.dart';
import '../../domain/entities/mission.dart' as domain;
import '../../data/repositories/mission_repository.dart';
import '../../domain/usecases/get_daily_mission.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MissionProvider with ChangeNotifier {
  List<Mission> _missions = [];
  bool _isLoading = false;
  late MissionRepository _repository;
  domain.User? _user;
  BuildContext? _context;

  // Sistema de cooldown para desbloqueo diferido
  DateTime? nextUnlockTime;
  Difficulty? lastCompletedDifficulty;
  bool pendingUnlock = false;

  List<Mission> get missions => _missions;
  bool get isLoading => _isLoading;
  domain.User? get user => _user;

  List<Mission> get pendingMissions =>
      _missions.where((mission) => !mission.isCompleted).toList();

  List<Mission> get completedMissions =>
      _missions.where((mission) => mission.isCompleted).toList();

  int get totalPoints => _missions
      .where((mission) => mission.isCompleted)
      .fold(0, (sum, mission) => sum + mission.points);

  // Misiones del sistema desbloqueadas basadas en puntos del usuario
  List<Mission> get unlockedSystemMissions {
    if (_user == null) return [];
    final userPoints = _user!.puntos;

    return _missions.where((mission) {
      if (!mission.isSystemMission) return false;

      // Lógica de desbloqueo: primeras 3 misiones siempre desbloqueadas (0 puntos)
      final systemMissions = _missions.where((m) => m.isSystemMission).toList();
      final missionIndex = systemMissions.indexOf(mission);

      if (missionIndex < 3) {
        return true; // Primeras 3 misiones siempre desbloqueadas
      } else if (missionIndex == 3) {
        return userPoints >= 5; // Cuarta misión requiere 5 puntos
      } else {
        return userPoints >= 5 + ((missionIndex - 3) * 10); // Cada siguiente requiere 10 puntos más
      }
    }).toList();
  }

  // Misiones del sistema bloqueadas
  List<Mission> get lockedSystemMissions {
    if (_user == null) return [];
    final userPoints = _user!.puntos;

    return _missions.where((mission) {
      if (!mission.isSystemMission) return false;

      final systemMissions = _missions.where((m) => m.isSystemMission).toList();
      final missionIndex = systemMissions.indexOf(mission);

      if (missionIndex < 3) {
        return false; // Primeras 3 nunca están bloqueadas
      } else if (missionIndex == 3) {
        return userPoints < 5;
      } else {
        return userPoints < 5 + ((missionIndex - 3) * 10);
      }
    }).toList();
  }

  domain.Mission getCurrentDailyMission() {
    final now = DateTime.now();
    final day = now.day;
    final mission = _repository.getDailyMission(day);
    return mission;
  }

  Future<void> completeCurrentMission() async {
    if (_user != null) {
      final completeMission = CompleteMission(_repository);
      await completeMission.call(_user!);
      await _loadUser(); // Reload user after completion
    }
  }

  Future<void> addPoints(int points) async {
    if (_user != null) {
      _user!.puntos += points;
      await _repository.saveUser(_user!);
      notifyListeners();
    }
  }

  MissionProvider([this._context]) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _repository = MissionRepositoryImpl(prefs);
    await _loadUser();
    _loadMissions();
  }

  Future<void> _loadUser() async {
    _user = await _repository.getUser();
    notifyListeners();
  }

  Future<void> _loadMissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final missionsJson = prefs.getStringList('missions') ?? [];

      // Cargar misiones personales del usuario
      final userMissions = missionsJson
          .map((missionJson) => Mission.fromJson(json.decode(missionJson)))
          .toList();

      // Cargar misiones predeterminadas del sistema
      final systemMissions = _repository.getAllMissions().map((mission) {
        // Convertir Mission del repository a Mission del modelo
        return Mission(
          id: mission.id.toString(),
          title: mission.descripcion,
          notes: mission.beneficio,
          difficulty: _mapDifficulty(mission.categoria),
          startDate: DateTime.now(),
          points: 10, // Puntos base para misiones del sistema
          isSystemMission: true,
          isCompleted: false,
        );
      }).toList();

      // Combinar misiones personales y del sistema
      _missions = [...userMissions, ...systemMissions];
    } catch (e) {
      debugPrint('Error loading missions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Difficulty _mapDifficulty(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'salud-fitness':
        return Difficulty.medium;
      case 'trabajo-finanzas':
        return Difficulty.hard;
      case 'amor-relaciones':
        return Difficulty.easy;
      default:
        return Difficulty.medium;
    }
  }

  Future<void> _saveMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final missionsJson = _missions.map((mission) => json.encode(mission.toJson())).toList();
      await prefs.setStringList('missions', missionsJson);
    } catch (e) {
      debugPrint('Error saving missions: $e');
    }
  }

  Future<void> addMission(Mission mission) async {
    _missions.add(mission);
    await _saveMissions();
    notifyListeners();
  }

  Future<void> updateMission(String missionId, Mission updatedMission) async {
    final index = _missions.indexWhere((mission) => mission.id == missionId);
    if (index != -1) {
      _missions[index] = updatedMission;
      await _saveMissions();
      notifyListeners();
    }
  }

  Future<void> deleteMission(String missionId) async {
    _missions.removeWhere((mission) => mission.id == missionId);
    await _saveMissions();
    notifyListeners();
  }

  Future<void> toggleMissionCompletion(String missionId) async {
    final index = _missions.indexWhere((mission) => mission.id == missionId);
    if (index != -1) {
      final mission = _missions[index];
      final wasCompleted = mission.isCompleted;
      final updatedMission = mission.copyWith(
        isCompleted: !mission.isCompleted,
        completedAt: !mission.isCompleted ? DateTime.now() : null,
      );
      _missions[index] = updatedMission;
      await _saveMissions();

      // Si se completó una misión del sistema, agregar puntos al usuario
      if (!wasCompleted && mission.isSystemMission && _user != null) {
        _user!.puntos += mission.points;
        await _repository.saveUser(_user!);

        // Iniciar cooldown para desbloqueo de nueva misión
        _startUnlockCooldown(mission.difficulty);
      }

      notifyListeners();
    }
  }

  // Método para iniciar el cooldown de desbloqueo
  void _startUnlockCooldown(Difficulty difficulty) {
    lastCompletedDifficulty = difficulty;

    Duration delay;
    switch (difficulty) {
      case Difficulty.easy:
        delay = const Duration(minutes: 4);
        break;
      case Difficulty.medium:
        delay = const Duration(minutes: 8);
        break;
      case Difficulty.hard:
        delay = const Duration(minutes: 12);
        break;
      default:
        delay = const Duration(minutes: 24);
    }

    nextUnlockTime = DateTime.now().add(delay);
    pendingUnlock = true;
  }

  // Método para verificar si hay un desbloqueo pendiente disponible
  void checkUnlockAvailable() {
    if (pendingUnlock && nextUnlockTime != null && DateTime.now().isAfter(nextUnlockTime!)) {
      // Desbloquear la siguiente misión del sistema basada en puntos acumulados
      if (_user != null) {
        final userPoints = _user!.puntos;

        // Encontrar la siguiente misión que se puede desbloquear
        final systemMissions = _missions.where((m) => m.isSystemMission).toList();
        final unlockedCount = unlockedSystemMissions.length;

        Mission? nextMissionToUnlock;

        // Lógica de desbloqueo basada en puntos
        if (unlockedCount < 3) {
          // Primeras 3 siempre disponibles
          nextMissionToUnlock = systemMissions[unlockedCount];
        } else if (unlockedCount == 3 && userPoints >= 5) {
          nextMissionToUnlock = systemMissions[3];
        } else if (unlockedCount > 3) {
          final additionalMissions = unlockedCount - 3;
          final requiredPoints = 5 + (additionalMissions * 10);
          if (userPoints >= requiredPoints) {
            nextMissionToUnlock = systemMissions[unlockedCount];
          }
        }

        // Si hay una misión para desbloquear, agregarla a las desbloqueadas
        if (nextMissionToUnlock != null) {
          // Marcar como no completada para que aparezca en la lista
          final index = _missions.indexWhere((m) => m.id == nextMissionToUnlock!.id);
          if (index != -1) {
            _missions[index] = _missions[index].copyWith(isCompleted: false);
            _saveMissions();
          }
        }
      }

      // Resetear el estado del cooldown
      pendingUnlock = false;
      nextUnlockTime = null;
      lastCompletedDifficulty = null;

      notifyListeners();
    }
  }

  Future<void> addSubMission(String missionId, SubMission subMission) async {
    final index = _missions.indexWhere((mission) => mission.id == missionId);
    if (index != -1) {
      final mission = _missions[index];
      final updatedSubMissions = [...mission.subMissions, subMission];
      final updatedMission = mission.copyWith(subMissions: updatedSubMissions);
      _missions[index] = updatedMission;
      await _saveMissions();
      notifyListeners();
    }
  }

  Future<void> updateSubMission(String missionId, String subMissionId, SubMission updatedSubMission) async {
    final missionIndex = _missions.indexWhere((mission) => mission.id == missionId);
    if (missionIndex != -1) {
      final mission = _missions[missionIndex];
      final subMissionIndex = mission.subMissions.indexWhere((sub) => sub.id == subMissionId);
      if (subMissionIndex != -1) {
        final updatedSubMissions = [...mission.subMissions];
        updatedSubMissions[subMissionIndex] = updatedSubMission;
        final updatedMission = mission.copyWith(subMissions: updatedSubMissions);
        _missions[missionIndex] = updatedMission;
        await _saveMissions();
        notifyListeners();
      }
    }
  }

  Future<void> deleteSubMission(String missionId, String subMissionId) async {
    final missionIndex = _missions.indexWhere((mission) => mission.id == missionId);
    if (missionIndex != -1) {
      final mission = _missions[missionIndex];
      final updatedSubMissions = mission.subMissions.where((sub) => sub.id != subMissionId).toList();
      final updatedMission = mission.copyWith(subMissions: updatedSubMissions);
      _missions[missionIndex] = updatedMission;
      await _saveMissions();
      notifyListeners();
    }
  }

  Future<void> toggleSubMissionCompletion(String missionId, String subMissionId) async {
    final missionIndex = _missions.indexWhere((mission) => mission.id == missionId);
    if (missionIndex != -1) {
      final mission = _missions[missionIndex];
      final subMissionIndex = mission.subMissions.indexWhere((sub) => sub.id == subMissionId);
      if (subMissionIndex != -1) {
        final subMission = mission.subMissions[subMissionIndex];
        final updatedSubMission = subMission.copyWith(isCompleted: !subMission.isCompleted);
        final updatedSubMissions = [...mission.subMissions];
        updatedSubMissions[subMissionIndex] = updatedSubMission;
        final updatedMission = mission.copyWith(subMissions: updatedSubMissions);
        _missions[missionIndex] = updatedMission;
        await _saveMissions();
        notifyListeners();
      }
    }
  }

  Future<void> resetProgress() async {
    try {
      // Resetear usuario
      if (_user != null) {
        _user = domain.User(
          puntos: 0,
          diasCompletados: 0,
          misionesCompletadas: [],
          logrosDesbloqueados: [],
        );
        await _repository.saveUser(_user!);
      }

      // Limpiar misiones locales PERO RECARGAR las del sistema
      _missions.clear();
      await _saveMissions();

      // Recargar las misiones del sistema (predeterminadas)
      await _loadMissions();

      // Resetear el estado del tutorial para que aparezca nuevamente
      if (_context != null) {
        final authProvider = Provider.of<AuthProvider>(_context!, listen: false);
        await authProvider.resetTutorialCompleted();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting mission progress: $e');
    }
  }
}