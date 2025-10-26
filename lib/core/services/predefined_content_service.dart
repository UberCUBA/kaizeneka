import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_models.dart';
import 'supabase_service.dart';

class PredefinedContentService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Predefined Tasks Management
  Future<List<Task>> getPredefinedTasks() async {
    try {
      final response = await _supabase
          .from('predefined_tasks')
          .select('*, predefined_task_subtasks(*)')
          .eq('is_active', true)
          .order('category', ascending: true)
          .order('difficulty', ascending: true);

      return response.map<Task>((json) => _taskFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas predeterminadas: $e');
    }
  }

  Future<List<Task>> getPredefinedTasksByCategory(String category) async {
    try {
      final response = await _supabase
          .from('predefined_tasks')
          .select('*, predefined_task_subtasks(*)')
          .eq('is_active', true)
          .eq('category', category)
          .order('difficulty', ascending: true);

      return response.map<Task>((json) => _taskFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas por categoría: $e');
    }
  }

  Future<void> createPredefinedTask(Task task, String category, List<String> tags) async {
    try {
      final taskData = {
        'title': task.title,
        'notes': task.notes,
        'difficulty': task.difficulty.name,
        'category': category,
        'tags': tags,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'usage_count': 0,
      };

      final response = await _supabase
          .from('predefined_tasks')
          .insert(taskData)
          .select()
          .single();

      final createdTaskId = response['id'];

      // Crear subtareas predeterminadas
      if (task.subTasks.isNotEmpty) {
        final subTasksData = task.subTasks.map((subTask) => {
          'predefined_task_id': createdTaskId,
          'title': subTask.title,
          'order_index': task.subTasks.indexOf(subTask),
        }).toList();

        await _supabase.from('predefined_task_subtasks').insert(subTasksData);
      }
    } catch (e) {
      throw Exception('Error al crear tarea predeterminada: $e');
    }
  }

  Future<void> updatePredefinedTaskUsage(String predefinedTaskId) async {
    try {
      await _supabase.rpc('increment_task_usage', params: {'task_id': predefinedTaskId});
    } catch (e) {
      log('Error al actualizar uso de tarea: $e');
    }
  }

  // Predefined Missions Management
  Future<List<Mission>> getPredefinedMissions() async {
    try {
      final response = await _supabase
          .from('predefined_missions')
          .select('*, predefined_mission_submissions(*)')
          .eq('is_active', true)
          .order('category', ascending: true)
          .order('difficulty', ascending: true);

      return response.map<Mission>((json) => _missionFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones predeterminadas: $e');
    }
  }

  Future<List<Mission>> getPredefinedMissionsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('predefined_missions')
          .select('*, predefined_mission_submissions(*)')
          .eq('is_active', true)
          .eq('category', category)
          .order('difficulty', ascending: true);

      return response.map<Mission>((json) => _missionFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones por categoría: $e');
    }
  }

  Future<void> createPredefinedMission(Mission mission, String category, List<String> tags) async {
    try {
      final missionData = {
        'title': mission.title,
        'notes': mission.notes,
        'difficulty': mission.difficulty.name,
        'points': mission.points,
        'category': category,
        'tags': tags,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'usage_count': 0,
      };

      final response = await _supabase
          .from('predefined_missions')
          .insert(missionData)
          .select()
          .single();

      final createdMissionId = response['id'];

      // Crear submisiones predeterminadas
      if (mission.subMissions.isNotEmpty) {
        final subMissionsData = mission.subMissions.map((subMission) => {
          'predefined_mission_id': createdMissionId,
          'title': subMission.title,
          'points': subMission.points,
          'order_index': mission.subMissions.indexOf(subMission),
        }).toList();

        await _supabase.from('predefined_mission_submissions').insert(subMissionsData);
      }
    } catch (e) {
      throw Exception('Error al crear misión predeterminada: $e');
    }
  }

  Future<void> updatePredefinedMissionUsage(String predefinedMissionId) async {
    try {
      await _supabase.rpc('increment_mission_usage', params: {'mission_id': predefinedMissionId});
    } catch (e) {
      log('Error al actualizar uso de misión: $e');
    }
  }

  // Predefined Habits Management
  Future<List<Habit>> getPredefinedHabits() async {
    try {
      final response = await _supabase
          .from('predefined_habits')
          .select()
          .eq('is_active', true)
          .order('category', ascending: true)
          .order('difficulty', ascending: true);

      return response.map<Habit>((json) => _habitFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener hábitos predeterminados: $e');
    }
  }

  Future<List<Habit>> getPredefinedHabitsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('predefined_habits')
          .select()
          .eq('is_active', true)
          .eq('category', category)
          .order('difficulty', ascending: true);

      return response.map<Habit>((json) => _habitFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener hábitos por categoría: $e');
    }
  }

  Future<void> createPredefinedHabit(Habit habit, String category, List<String> tags) async {
    try {
      final habitData = {
        'title': habit.title,
        'notes': habit.notes,
        'difficulty': habit.difficulty.name,
        'repeat_type': habit.repeatType.name,
        'category': category,
        'tags': tags,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'usage_count': 0,
      };

      await _supabase.from('predefined_habits').insert(habitData);
    } catch (e) {
      throw Exception('Error al crear hábito predeterminado: $e');
    }
  }

  Future<void> updatePredefinedHabitUsage(String predefinedHabitId) async {
    try {
      await _supabase.rpc('increment_habit_usage', params: {'habit_id': predefinedHabitId});
    } catch (e) {
      log('Error al actualizar uso de hábito: $e');
    }
  }

  // Categories and Tags
  Future<List<String>> getCategories(String type) async {
    try {
      final tableName = 'predefined_${type}s';
      final response = await _supabase
          .from(tableName)
          .select('category')
          .eq('is_active', true);

      final categories = response
          .map<String>((item) => item['category'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<List<String>> getTags(String type) async {
    try {
      final tableName = 'predefined_${type}s';
      final response = await _supabase
          .from(tableName)
          .select('tags')
          .eq('is_active', true);

      final allTags = <String>[];
      for (final item in response) {
        final tags = item['tags'] as List<dynamic>?;
        if (tags != null) {
          allTags.addAll(tags.map((tag) => tag as String));
        }
      }

      return allTags.toSet().toList();
    } catch (e) {
      throw Exception('Error al obtener etiquetas: $e');
    }
  }

  // Daily Content Assignment
  Future<void> assignDailyContent(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Check if daily content was already assigned today
      final existing = await _supabase
          .from('user_daily_content')
          .select()
          .eq('user_id', userId)
          .eq('assigned_date', startOfDay.toIso8601String())
          .maybeSingle();

      if (existing != null) return;

      // Get random predefined content
      final tasks = await getPredefinedTasks();
      final missions = await getPredefinedMissions();
      final habits = await getPredefinedHabits();

      // Select random items (max 2 tasks, 1 mission, 1 habit)
      final randomTasks = tasks.take(2).toList();
      final randomMissions = missions.take(1).toList();
      final randomHabits = habits.take(1).toList();

      // Assign to user
      final dailyContent = [
        ...randomTasks.map((task) => {
          'user_id': userId,
          'content_type': 'task',
          'content_id': task.id,
          'assigned_date': startOfDay.toIso8601String(),
        }),
        ...randomMissions.map((mission) => {
          'user_id': userId,
          'content_type': 'mission',
          'content_id': mission.id,
          'assigned_date': startOfDay.toIso8601String(),
        }),
        ...randomHabits.map((habit) => {
          'user_id': userId,
          'content_type': 'habit',
          'content_id': habit.id,
          'assigned_date': startOfDay.toIso8601String(),
        }),
      ];

      await _supabase.from('user_daily_content').insert(dailyContent);
    } catch (e) {
      throw Exception('Error al asignar contenido diario: $e');
    }
  }

  // Helper methods
  Task _taskFromJson(Map<String, dynamic> json) {
    final subTasks = (json['predefined_task_subtasks'] as List<dynamic>?)
            ?.map((sub) => SubTask(
                  id: sub['id'],
                  title: sub['title'],
                ))
            .toList() ??
        [];

    return Task(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.now(), // Will be set when assigned
      subTasks: subTasks,
    );
  }

  Mission _missionFromJson(Map<String, dynamic> json) {
    final subMissions = (json['predefined_mission_submissions'] as List<dynamic>?)
            ?.map((sub) => SubMission(
                  id: sub['id'],
                  title: sub['title'],
                  points: sub['points'],
                ))
            .toList() ??
        [];

    return Mission(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.now(), // Will be set when assigned
      points: json['points'] ?? 0,
      subMissions: subMissions,
    );
  }

  Habit _habitFromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.now(), // Will be set when assigned
      repeatType: RepeatType.values.firstWhere(
        (r) => r.name == json['repeat_type'],
        orElse: () => RepeatType.daily,
      ),
    );
  }
}