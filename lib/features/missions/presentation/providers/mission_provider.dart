import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../models/task_models.dart';
import '../../domain/entities/mission.dart' as domain;
import '../../data/repositories/mission_repository.dart';
import '../../domain/usecases/get_daily_mission.dart';

class MissionProvider with ChangeNotifier {
  List<Mission> _missions = [];
  bool _isLoading = false;
  late MissionRepository _repository;
  domain.User? _user;

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

  Future<void> addPoints(BuildContext context, int points) async {
    if (_user != null) {
      _user!.puntos += points;
      await _repository.saveUser(_user!);
      notifyListeners();
    }
  }

  MissionProvider() {
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

      _missions = missionsJson
          .map((missionJson) => Mission.fromJson(json.decode(missionJson)))
          .toList();
    } catch (e) {
      debugPrint('Error loading missions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final updatedMission = mission.copyWith(
        isCompleted: !mission.isCompleted,
        completedAt: !mission.isCompleted ? DateTime.now() : null,
      );
      _missions[index] = updatedMission;
      await _saveMissions();
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
}