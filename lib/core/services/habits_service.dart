import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_models.dart';
import 'supabase_service.dart';
import 'progress_service.dart';

class HabitsService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Habits CRUD
  Future<List<Habit>> getUserHabits(String userId) async {
    try {
      final response = await _supabase
          .from('user_habits')
          .select('*, habit_completions(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Habit>((json) => _habitFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener hábitos: $e');
    }
  }

  Future<Habit> createHabit(String userId, Habit habit) async {
    try {
      final habitData = {
        'user_id': userId,
        'title': habit.title,
        'notes': habit.notes,
        'difficulty': habit.difficulty.name,
        'start_date': habit.startDate.toIso8601String(),
        'repeat_type': habit.repeatType.name,
        'streak': habit.streak,
        'best_streak': habit.bestStreak,
        'created_at': habit.createdAt.toIso8601String(),
      };

      final response = await _supabase
          .from('user_habits')
          .insert(habitData)
          .select()
          .single();

      final createdHabit = _habitFromJson(response);

      // Crear completados iniciales si existen
      if (habit.completedDates.isNotEmpty) {
        await _createHabitCompletions(createdHabit.id, habit.completedDates);
      }

      return createdHabit;
    } catch (e) {
      throw Exception('Error al crear hábito: $e');
    }
  }

  Future<Habit> updateHabit(String habitId, Habit habit) async {
    try {
      final habitData = {
        'title': habit.title,
        'notes': habit.notes,
        'difficulty': habit.difficulty.name,
        'start_date': habit.startDate.toIso8601String(),
        'repeat_type': habit.repeatType.name,
        'streak': habit.streak,
        'best_streak': habit.bestStreak,
      };

      final response = await _supabase
          .from('user_habits')
          .update(habitData)
          .eq('id', habitId)
          .select('*, habit_completions(*)')
          .single();

      return _habitFromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar hábito: $e');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _supabase.from('user_habits').delete().eq('id', habitId);
    } catch (e) {
      throw Exception('Error al eliminar hábito: $e');
    }
  }

  Future<void> completeHabitToday(String habitId, DateTime date) async {
    try {
      // Verificar si ya está completado
      final existing = await _supabase
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .eq('completion_date', date.toIso8601String())
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('habit_completions').insert({
          'habit_id': habitId,
          'completion_date': date.toIso8601String(),
        });

        // Otorgar recompensas por completar hábito
        await _grantHabitRewards(habitId);
      }
    } catch (e) {
      throw Exception('Error al completar hábito: $e');
    }
  }

  Future<void> uncompleteHabitToday(String habitId, DateTime date) async {
    try {
      await _supabase
          .from('habit_completions')
          .delete()
          .eq('habit_id', habitId)
          .eq('completion_date', date.toIso8601String());
    } catch (e) {
      throw Exception('Error al descompletar hábito: $e');
    }
  }

  Future<void> _createHabitCompletions(String habitId, List<DateTime> dates) async {
    try {
      final completionsData = dates.map((date) => {
        'habit_id': habitId,
        'completion_date': date.toIso8601String(),
      }).toList();

      await _supabase.from('habit_completions').insert(completionsData);
    } catch (e) {
      throw Exception('Error al crear completados de hábito: $e');
    }
  }

  // Predefined Habits
  Future<List<Habit>> getPredefinedHabits() async {
    try {
      final response = await _supabase
          .from('predefined_habits')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<Habit>((json) => _habitFromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener hábitos predeterminados: $e');
    }
  }

  Future<Habit> assignPredefinedHabit(String userId, String predefinedHabitId) async {
    try {
      final predefinedHabit = await _supabase
          .from('predefined_habits')
          .select()
          .eq('id', predefinedHabitId)
          .single();

      final habitData = {
        'user_id': userId,
        'title': predefinedHabit['title'],
        'notes': predefinedHabit['notes'],
        'difficulty': predefinedHabit['difficulty'],
        'start_date': DateTime.now().toIso8601String(),
        'repeat_type': predefinedHabit['repeat_type'],
        'streak': 0,
        'best_streak': 0,
        'created_at': DateTime.now().toIso8601String(),
        'is_from_predefined': true,
        'predefined_habit_id': predefinedHabitId,
      };

      final response = await _supabase
          .from('user_habits')
          .insert(habitData)
          .select()
          .single();

      return _habitFromJson(response);
    } catch (e) {
      throw Exception('Error al asignar hábito predeterminado: $e');
    }
  }

  // Sharing
  Future<String> shareHabit(String habitId) async {
    try {
      final shareCode = DateTime.now().millisecondsSinceEpoch.toString();

      await _supabase.from('shared_habits').insert({
        'habit_id': habitId,
        'share_code': shareCode,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      return shareCode;
    } catch (e) {
      throw Exception('Error al compartir hábito: $e');
    }
  }

  Future<Habit> importSharedHabit(String userId, String shareCode) async {
    try {
      final sharedHabit = await _supabase
          .from('shared_habits')
          .select('*, user_habits(*, habit_completions(*))')
          .eq('share_code', shareCode)
          .eq('is_active', true)
          .single();

      final originalHabit = sharedHabit['user_habits'];

      final habitData = {
        'user_id': userId,
        'title': '${originalHabit['title']} (Compartido)',
        'notes': originalHabit['notes'],
        'difficulty': originalHabit['difficulty'],
        'start_date': DateTime.now().toIso8601String(),
        'repeat_type': originalHabit['repeat_type'],
        'streak': 0,
        'best_streak': 0,
        'created_at': DateTime.now().toIso8601String(),
        'is_shared_copy': true,
        'original_habit_id': originalHabit['id'],
      };

      final response = await _supabase
          .from('user_habits')
          .insert(habitData)
          .select()
          .single();

      return _habitFromJson(response);
    } catch (e) {
      throw Exception('Error al importar hábito compartido: $e');
    }
  }

  // Helper method to convert JSON to Habit
  Habit _habitFromJson(Map<String, dynamic> json) {
    final completions = (json['habit_completions'] as List<dynamic>?)
            ?.map((c) => DateTime.parse(c['completion_date']))
            .toList() ??
        [];

    return Habit(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.parse(json['start_date']),
      repeatType: RepeatType.values.firstWhere(
        (r) => r.name == json['repeat_type'],
        orElse: () => RepeatType.daily,
      ),
      completedDates: completions,
      streak: json['streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // Statistics
  Future<Map<String, dynamic>> getHabitStatistics(String userId) async {
    try {
      final habits = await getUserHabits(userId);

      int totalHabits = habits.length;
      int activeHabits = habits.where((h) => h.startDate.isBefore(DateTime.now())).length;
      int completedToday = habits.where((h) => h.isCompletedToday).length;
      int currentStreaks = habits.where((h) => h.streak > 0).length;
      int bestStreak = habits.fold(0, (max, h) => h.bestStreak > max ? h.bestStreak : max);

      return {
        'totalHabits': totalHabits,
        'activeHabits': activeHabits,
        'completedToday': completedToday,
        'currentStreaks': currentStreaks,
        'bestStreak': bestStreak,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas de hábitos: $e');
    }
  }

  // Método para otorgar recompensas por completar hábitos
  Future<void> _grantHabitRewards(String habitId) async {
    try {
      // Obtener el user_id del hábito
      final habitData = await _supabase
          .from('user_habits')
          .select('user_id, difficulty')
          .eq('id', habitId)
          .single();

      final userId = habitData['user_id'] as String;
      final difficulty = Difficulty.values.firstWhere(
        (d) => d.name == habitData['difficulty'],
        orElse: () => Difficulty.medium,
      );

      // Calcular XP basado en dificultad (hábitos diarios dan más recompensa)
      final xpReward = ProgressService.calculateXpReward(difficulty) + 2; // +2 extra por consistencia
      final coinsReward = ProgressService.calculateCoinsReward(difficulty) + 1; // +1 extra

      // Otorgar XP y monedas
      final progressService = ProgressService();
      await progressService.addPoints(userId, xpReward);
      await progressService.addCoins(userId, coinsReward);

      // Actualizar racha
      await progressService.updateStreak(userId, true);

    } catch (e) {
      // Log error but don't throw - rewards are nice to have but not critical
      print('Error granting habit rewards: $e');
    }
  }
}