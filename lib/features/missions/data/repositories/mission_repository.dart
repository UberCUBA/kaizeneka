import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/mission_model.dart';
import '../../domain/entities/mission.dart';
import '../../../../core/services/supabase_service.dart';

abstract class MissionRepository {
  Future<User> getUser();
  Future<void> saveUser(User user);
  Future<List<Mission>> getAllMissions();
  Future<Mission> getDailyMission(int day);
}

class MissionRepositoryImpl implements MissionRepository {
  final SharedPreferences prefs;

  MissionRepositoryImpl(this.prefs);

  @override
  Future<User> getUser() async {
    final userJson = prefs.getString('usuario');
    if (userJson != null) {
      final userModel = UserModel.fromJson(json.decode(userJson));
      return userModel.toEntity();
    }
    return User();
  }

  @override
  Future<void> saveUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await prefs.setString('usuario', json.encode(userModel.toJson()));
  }

  @override
  Future<List<Mission>> getAllMissions() async {
    try {
      final response = await SupabaseService.client
          .from('narrative_missions')
          .select()
          .eq('is_active', true)
          .order('order_in_phase');

      return response.map<Mission>((json) => Mission(
        id: int.tryParse(json['id'].toString()) ?? 0,
        descripcion: json['title'] ?? '',
        categoria: json['principle'] ?? '',
        beneficio: json['description'] ?? '',
      )).toList();
    } catch (e) {
      debugPrint('Error fetching missions from Supabase: $e');
      // Fallback to empty list
      return [];
    }
  }

  @override
  Future<Mission> getDailyMission(int day) async {
    final missions = await getAllMissions();
    if (missions.isEmpty) {
      return Mission(id: 0, descripcion: 'No missions available', categoria: '', beneficio: '');
    }
    return missions[(day - 1) % missions.length];
  }
}