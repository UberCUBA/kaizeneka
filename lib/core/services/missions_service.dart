import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_models.dart';
import 'supabase_service.dart';

class MissionsService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Missions CRUD
  Future<List<Mission>> getUserMissions(String userId) async {
    try {
      final response = await _supabase
          .from('missions')
          .select('*, submissions(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Mission>((json) => Mission.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones: $e');
    }
  }

  Future<Mission> createMission(String userId, Mission mission) async {
    try {
      final missionData = {
        'user_id': userId,
        'title': mission.title,
        'notes': mission.notes,
        'difficulty': mission.difficulty.name,
        'start_date': mission.startDate.toIso8601String(),
        'repeat_type': mission.repeatType?.name,
        'is_completed': mission.isCompleted,
        'points': mission.points,
        'created_at': mission.createdAt.toIso8601String(),
        'completed_at': mission.completedAt?.toIso8601String(),
      };

      final response = await _supabase
          .from('user_missions')
          .insert(missionData)
          .select()
          .single();

      final createdMission = Mission.fromJson(response);

      // Crear submisiones si existen
      if (mission.subMissions.isNotEmpty) {
        await _createSubMissions(createdMission.id, mission.subMissions);
      }

      return createdMission;
    } catch (e) {
      throw Exception('Error al crear misión: $e');
    }
  }

  Future<Mission> updateMission(String missionId, Mission mission) async {
    try {
      final missionData = {
        'title': mission.title,
        'notes': mission.notes,
        'difficulty': mission.difficulty.name,
        'start_date': mission.startDate.toIso8601String(),
        'repeat_type': mission.repeatType?.name,
        'is_completed': mission.isCompleted,
        'points': mission.points,
        'completed_at': mission.completedAt?.toIso8601String(),
      };

      final response = await _supabase
          .from('missions')
          .update(missionData)
          .eq('id', missionId)
          .select('*, submissions(*)')
          .single();

      return Mission.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar misión: $e');
    }
  }

  Future<void> deleteMission(String missionId) async {
    try {
      await _supabase.from('missions').delete().eq('id', missionId);
    } catch (e) {
      throw Exception('Error al eliminar misión: $e');
    }
  }

  // SubMissions CRUD
  Future<void> _createSubMissions(String missionId, List<SubMission> subMissions) async {
    try {
      final subMissionsData = subMissions.map((subMission) => {
        'mission_id': missionId,
        'title': subMission.title,
        'is_completed': subMission.isCompleted,
        'points': subMission.points,
        'due_date': subMission.dueDate?.toIso8601String(),
      }).toList();

      await _supabase.from('mission_submissions').insert(subMissionsData);
    } catch (e) {
      throw Exception('Error al crear submisiones: $e');
    }
  }

  Future<void> updateSubMission(String subMissionId, SubMission subMission) async {
    try {
      final subMissionData = {
        'title': subMission.title,
        'is_completed': subMission.isCompleted,
        'points': subMission.points,
        'due_date': subMission.dueDate?.toIso8601String(),
      };

      await _supabase
          .from('submissions')
          .update(subMissionData)
          .eq('id', subMissionId);
    } catch (e) {
      throw Exception('Error al actualizar submisión: $e');
    }
  }

  Future<void> deleteSubMission(String subMissionId) async {
    try {
      await _supabase.from('submissions').delete().eq('id', subMissionId);
    } catch (e) {
      throw Exception('Error al eliminar submisión: $e');
    }
  }

  // Predefined Missions
  Future<List<Mission>> getPredefinedMissions() async {
    try {
      final response = await _supabase
          .from('predefined_missions')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<Mission>((json) => Mission.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones predeterminadas: $e');
    }
  }

  Future<Mission> assignPredefinedMission(String userId, String predefinedMissionId) async {
    try {
      final predefinedMission = await _supabase
          .from('predefined_missions')
          .select('*, predefined_mission_submissions(*)')
          .eq('id', predefinedMissionId)
          .single();

      final missionData = {
        'user_id': userId,
        'title': predefinedMission['title'],
        'notes': predefinedMission['notes'],
        'difficulty': predefinedMission['difficulty'],
        'start_date': DateTime.now().toIso8601String(),
        'repeat_type': predefinedMission['repeat_type'],
        'is_completed': false,
        'points': predefinedMission['points'] ?? 0,
        'created_at': DateTime.now().toIso8601String(),
        'is_from_predefined': true,
        'predefined_mission_id': predefinedMissionId,
      };

      final response = await _supabase
          .from('missions')
          .insert(missionData)
          .select()
          .single();

      final createdMission = Mission.fromJson(response);

      if (predefinedMission['predefined_mission_submissions'] != null) {
        final subMissionsData = (predefinedMission['predefined_mission_submissions'] as List)
            .map((subMission) => {
          'mission_id': createdMission.id,
          'title': subMission['title'],
          'is_completed': false,
          'points': subMission['points'],
          'due_date': subMission['due_date'],
        }).toList();

        await _supabase.from('submissions').insert(subMissionsData);
      }

      return createdMission;
    } catch (e) {
      throw Exception('Error al asignar misión predeterminada: $e');
    }
  }

  // Sharing
  Future<String> shareMission(String missionId) async {
    try {
      final shareCode = DateTime.now().millisecondsSinceEpoch.toString();

      await _supabase.from('shared_missions').insert({
        'mission_id': missionId,
        'share_code': shareCode,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      return shareCode;
    } catch (e) {
      throw Exception('Error al compartir misión: $e');
    }
  }

  Future<Mission> importSharedMission(String userId, String shareCode) async {
    try {
      final sharedMission = await _supabase
          .from('shared_missions')
          .select('*, user_missions(*, mission_submissions(*))')
          .eq('share_code', shareCode)
          .eq('is_active', true)
          .single();

      final originalMission = sharedMission['user_missions'];

      final missionData = {
        'user_id': userId,
        'title': '${originalMission['title']} (Compartida)',
        'notes': originalMission['notes'],
        'difficulty': originalMission['difficulty'],
        'start_date': DateTime.now().toIso8601String(),
        'repeat_type': originalMission['repeat_type'],
        'is_completed': false,
        'points': originalMission['points'] ?? 0,
        'created_at': DateTime.now().toIso8601String(),
        'is_shared_copy': true,
        'original_mission_id': originalMission['id'],
      };

      final response = await _supabase
          .from('user_missions')
          .insert(missionData)
          .select()
          .single();

      final createdMission = Mission.fromJson(response);

      if (originalMission['mission_submissions'] != null) {
        final subMissionsData = (originalMission['mission_submissions'] as List)
            .map((subMission) => {
          'mission_id': createdMission.id,
          'title': subMission['title'],
          'is_completed': false,
          'points': subMission['points'],
          'due_date': subMission['due_date'],
        }).toList();

        await _supabase.from('mission_submissions').insert(subMissionsData);
      }

      return createdMission;
    } catch (e) {
      throw Exception('Error al importar misión compartida: $e');
    }
  }

  // Daily Missions
  Future<List<Mission>> getDailyMissions(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('daily_missions')
          .select('*, user_daily_missions!inner(*)')
          .eq('user_daily_missions.user_id', userId)
          .gte('user_daily_missions.assigned_date', startOfDay.toIso8601String())
          .lt('user_daily_missions.assigned_date', endOfDay.toIso8601String());

      return response.map<Mission>((json) => Mission.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones diarias: $e');
    }
  }

  Future<void> assignDailyMissions(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Verificar si ya se asignaron misiones hoy
      final existing = await _supabase
          .from('user_daily_missions')
          .select()
          .eq('user_id', userId)
          .eq('assigned_date', startOfDay.toIso8601String());

      if (existing.isNotEmpty) return;

      // Obtener misiones diarias disponibles
      final dailyMissions = await _supabase
          .from('daily_missions')
          .select()
          .eq('is_active', true)
          .limit(3); // Asignar máximo 3 misiones diarias

      for (final mission in dailyMissions) {
        await _supabase.from('user_daily_missions').insert({
          'user_id': userId,
          'daily_mission_id': mission['id'],
          'assigned_date': startOfDay.toIso8601String(),
          'is_completed': false,
        });
      }
    } catch (e) {
      throw Exception('Error al asignar misiones diarias: $e');
    }
  }
}