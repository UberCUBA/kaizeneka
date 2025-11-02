import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../models/task_models.dart';
import '../../../missions/presentation/providers/mission_provider.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  List<Habit> get activeHabits =>
      _habits.where((habit) => habit.startDate.isBefore(DateTime.now())).toList();

  List<Habit> get todaysHabits => activeHabits.where((habit) {
        final today = DateTime.now();
        final startDate = habit.startDate;

        switch (habit.repeatType) {
          case RepeatType.daily:
            return true; // Daily habits are always available
          case RepeatType.weekly:
            // Check if today is the same day of week as start date
            return today.weekday == startDate.weekday;
          case RepeatType.monthly:
            // Check if today is the same day of month as start date
            return today.day == startDate.day;
        }
      }).toList();

  HabitProvider() {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getStringList('habits') ?? [];

      _habits = habitsJson
          .map((habitJson) => Habit.fromJson(json.decode(habitJson)))
          .toList();
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = _habits.map((habit) => json.encode(habit.toJson())).toList();
      await prefs.setStringList('habits', habitsJson);
    } catch (e) {
      debugPrint('Error saving habits: $e');
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> updateHabit(String habitId, Habit updatedHabit) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _saveHabits();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> completeHabitToday(String habitId, [MissionProvider? missionProvider]) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      if (!habit.isCompletedToday) {
        final today = DateTime.now();
        final updatedCompletedDates = [...habit.completedDates, today];
        final newStreak = _calculateStreak(updatedCompletedDates, habit.repeatType);
        final newBestStreak = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

        final updatedHabit = habit.copyWith(
          completedDates: updatedCompletedDates,
          streak: newStreak,
          bestStreak: newBestStreak,
        );

        _habits[index] = updatedHabit;
        await _saveHabits();

        // Si tenemos missionProvider, agregar puntos por completar hábito
        if (missionProvider != null) {
          final pointsToAdd = _calculateHabitPoints(habit);
          await missionProvider.addPoints(pointsToAdd);
        }

        notifyListeners();
      }
    }
  }

  int _calculateHabitPoints(Habit habit) {
    // Puntos basados en dificultad
    switch (habit.difficulty) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
    }
  }

  Future<void> uncompleteHabitToday(String habitId) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      if (habit.isCompletedToday) {
        final today = DateTime.now();
        final updatedCompletedDates = habit.completedDates
            .where((date) => !(date.year == today.year &&
                              date.month == today.month &&
                              date.day == today.day))
            .toList();

        final newStreak = _calculateStreak(updatedCompletedDates, habit.repeatType);

        final updatedHabit = habit.copyWith(
          completedDates: updatedCompletedDates,
          streak: newStreak,
        );

        _habits[index] = updatedHabit;
        await _saveHabits();
        notifyListeners();
      }
    }
  }

  int _calculateStreak(List<DateTime> completedDates, RepeatType repeatType) {
    if (completedDates.isEmpty) return 0;

    completedDates.sort((a, b) => b.compareTo(a)); // Sort descending

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final date in completedDates) {
      if (_isDateInStreak(date, currentDate, repeatType)) {
        streak++;
        currentDate = _getPreviousDate(currentDate, repeatType);
      } else {
        break;
      }
    }

    return streak;
  }

  bool _isDateInStreak(DateTime date, DateTime targetDate, RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return date.year == targetDate.year &&
               date.month == targetDate.month &&
               date.day == targetDate.day;
      case RepeatType.weekly:
        return date.year == targetDate.year &&
               date.month == targetDate.month &&
               date.day == targetDate.day &&
               date.weekday == targetDate.weekday;
      case RepeatType.monthly:
        return date.year == targetDate.year &&
               date.month == targetDate.month &&
               date.day == targetDate.day;
    }
  }

  DateTime _getPreviousDate(DateTime date, RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return date.subtract(const Duration(days: 1));
      case RepeatType.weekly:
        return date.subtract(const Duration(days: 7));
      case RepeatType.monthly:
        return DateTime(date.year, date.month - 1, date.day);
    }
  }

  int get totalHabitsCompleted => _habits.fold(0, (sum, habit) => sum + habit.completedDates.length);

  int get currentStreaks => _habits.where((habit) => habit.streak > 0).length;

  int get bestStreaks => _habits.fold(0, (max, habit) => habit.bestStreak > max ? habit.bestStreak : max);

  Future<void> resetAll() async {
    _habits.clear();
    await _saveHabits();
    notifyListeners();
  }
}