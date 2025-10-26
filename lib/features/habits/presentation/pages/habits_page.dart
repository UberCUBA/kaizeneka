import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/habit_provider.dart';
import '../../../../models/task_models.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Hábitos++',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF7F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${habitProvider.todaysHabits.length} para hoy',
                          style: const TextStyle(
                            color: Color(0xFF00FF7F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habitProvider.currentStreaks} rachas activas',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.emoji_events,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mejor racha: ${habitProvider.bestStreaks}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Habits List
            Expanded(
              child: habitProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : habitProvider.habits.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: habitProvider.habits.length,
                          itemBuilder: (context, index) {
                            final habit = habitProvider.habits[index];
                            return _buildHabitCard(habit, themeProvider, habitProvider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes hábitos configurados',
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Crea hábitos para mejorar tu rutina!',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, ThemeProvider themeProvider, HabitProvider habitProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (habit.streak > 0) ...[
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Checkbox(
                      value: habit.isCompletedToday,
                      onChanged: (value) {
                        if (value == true) {
                          habitProvider.completeHabitToday(habit.id);
                        } else {
                          habitProvider.uncompleteHabitToday(habit.id);
                        }
                      },
                      activeColor: const Color(0xFF00FF7F),
                    ),
                  ],
                ),
              ],
            ),

            if (habit.notes != null && habit.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                habit.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Habit metadata
            Row(
              children: [
                _buildDifficultyChip(habit.difficulty),
                const SizedBox(width: 8),
                _buildRepeatTypeChip(habit.repeatType),
                const SizedBox(width: 8),
                Text(
                  'Iniciado: ${_formatDate(habit.startDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Completion calendar (last 7 days)
            _buildCompletionCalendar(habit, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty difficulty) {
    final color = _getDifficultyColor(difficulty);
    final label = _getDifficultyLabel(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRepeatTypeChip(RepeatType repeatType) {
    final label = _getRepeatTypeLabel(repeatType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00FF7F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF00FF7F),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCompletionCalendar(Habit habit, ThemeProvider themeProvider) {
    final today = DateTime.now();
    final days = List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((date) {
        final isCompleted = habit.completedDates.any((completedDate) =>
            completedDate.year == date.year &&
            completedDate.month == date.month &&
            completedDate.day == date.day);

        final isToday = date.year == today.year &&
                       date.month == today.month &&
                       date.day == today.day;

        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF00FF7F)
                : themeProvider.isDarkMode
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: isToday ? Border.all(color: const Color(0xFF00FF7F), width: 2) : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isCompleted
                    ? Colors.white
                    : themeProvider.isDarkMode
                        ? Colors.grey
                        : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Intermedia';
      case Difficulty.hard:
        return 'Difícil';
    }
  }

  String _getRepeatTypeLabel(RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return 'Diario';
      case RepeatType.weekly:
        return 'Semanal';
      case RepeatType.monthly:
        return 'Mensual';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}