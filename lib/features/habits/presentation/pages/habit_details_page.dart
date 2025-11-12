import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/habit_provider.dart';
import '../../../../models/task_models.dart';

class HabitDetailsPage extends StatefulWidget {
  final Habit habit;

  const HabitDetailsPage({super.key, required this.habit});

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          widget.habit.title,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF7F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getHabitIcon(widget.habit.icon),
                            size: 24,
                            color: const Color(0xFF00FF7F),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.habit.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getGoalTypeText(widget.habit),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.habit.notes != null && widget.habit.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.habit.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDifficultyChip(widget.habit.difficulty),
                        const SizedBox(width: 8),
                        _buildRepeatTypeChip(widget.habit.repeatType),
                        const Spacer(),
                        if (widget.habit.streak > 0) ...[
                          Icon(
                            Icons.local_fire_department,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.habit.streak} días',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Monthly Calendar
              Text(
                'Calendario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildMonthlyCalendar(themeProvider),

              const SizedBox(height: 24),

              // Statistics Section
              Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatisticsSection(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.multi,
          firstDayOfWeek: 0, // Sunday as first day
          weekdayLabels: ['D', 'L', 'M', 'X', 'J', 'V', 'S'],
          weekdayLabelTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
          ),
          controlsTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          dayTextStyle: TextStyle(
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          selectedDayHighlightColor: const Color(0xFF00FF7F),
          selectedDayTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          todayTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00FF7F),
          ),
          disabledDayTextStyle: TextStyle(
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
          ),
          calendarViewScrollPhysics: const NeverScrollableScrollPhysics(),
          disableModePicker: true, // Disable mode picker to prevent overflow
        ),
        value: widget.habit.completedDates,
        onValueChanged: (dates) {
          // This is read-only for display purposes, no changes allowed
        },
        displayedMonthDate: _currentMonth,
        onDisplayedMonthChanged: (date) {
          if (date != null) {
            setState(() => _currentMonth = date);
          }
        },
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeProvider themeProvider) {
    if (widget.habit.goalType == HabitGoalType.duration) {
      return _buildDurationStatistics(themeProvider);
    } else if (widget.habit.goalType == HabitGoalType.repeat) {
      return _buildRepetitionStatistics(themeProvider);
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Estadísticas disponibles para hábitos con objetivos de duración o repeticiones',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildDurationStatistics(ThemeProvider themeProvider) {
    // Calculate average duration per day of week
    final dayStats = _calculateDurationStatsByDay();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duración Media por Día de la Semana',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...dayStats.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: entry.value / 120, // Assuming max 120 minutes
                    backgroundColor: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value.toStringAsFixed(1)} min',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRepetitionStatistics(ThemeProvider themeProvider) {
    // Calculate average repetitions per day of week
    final dayStats = _calculateRepetitionStatsByDay();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repeticiones Medias por Día de la Semana',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...dayStats.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: entry.value / 50, // Assuming max 50 repetitions
                    backgroundColor: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Map<String, double> _calculateDurationStatsByDay() {
    // This would need to be implemented with actual session data
    // For now, return mock data
    return {
      'Lunes': 25.5,
      'Martes': 30.2,
      'Miércoles': 28.7,
      'Jueves': 32.1,
      'Viernes': 35.8,
      'Sábado': 40.3,
      'Domingo': 22.9,
    };
  }

  Map<String, double> _calculateRepetitionStatsByDay() {
    // This would need to be implemented with actual session data
    // For now, return mock data
    return {
      'Lunes': 15.2,
      'Martes': 18.7,
      'Miércoles': 16.8,
      'Jueves': 20.1,
      'Viernes': 22.3,
      'Sábado': 25.6,
      'Domingo': 12.4,
    };
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

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
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

  IconData _getHabitIcon(HabitIcon icon) {
    switch (icon) {
      case HabitIcon.fitness_center:
        return Icons.fitness_center;
      case HabitIcon.directions_run:
        return Icons.directions_run;
      case HabitIcon.pool:
        return Icons.pool;
      case HabitIcon.self_improvement:
        return Icons.self_improvement;
      case HabitIcon.directions_bike:
        return Icons.directions_bike;
      case HabitIcon.music_note:
        return Icons.music_note;
      case HabitIcon.palette:
        return Icons.palette;
      case HabitIcon.restaurant:
        return Icons.restaurant;
      case HabitIcon.local_florist:
        return Icons.local_florist;
      case HabitIcon.camera_alt:
        return Icons.camera_alt;
      case HabitIcon.edit:
        return Icons.edit;
      case HabitIcon.book:
        return Icons.book;
      case HabitIcon.work:
        return Icons.work;
      case HabitIcon.people:
        return Icons.people;
      case HabitIcon.health_and_safety:
        return Icons.health_and_safety;
      case HabitIcon.check_circle:
      default:
        return Icons.check_circle;
    }
  }

  String _getGoalTypeText(Habit habit) {
    switch (habit.goalType) {
      case HabitGoalType.duration:
        return habit.targetDuration != null
            ? 'Duración: ${habit.targetDuration} min'
            : 'Duración';
      case HabitGoalType.repeat:
        return habit.targetRepetitions != null
            ? 'Repeticiones: ${habit.targetRepetitions}'
            : 'Repeticiones';
      case HabitGoalType.deactivate:
      default:
        return '';
    }
  }
}