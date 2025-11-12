import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/habit_provider.dart';
import '../../../../models/task_models.dart';
import 'habit_timer_page.dart';
import 'habit_counter_page.dart';
import 'habit_details_page.dart';

class HabitsPage extends StatefulWidget {
  final String? searchQuery;
  final Difficulty? selectedDifficulty;
  final bool? showCompleted;
  final bool? showCompletedToday;

  const HabitsPage({
    super.key,
    this.searchQuery,
    this.selectedDifficulty,
    this.showCompleted,
    this.showCompletedToday,
  });

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    debugPrint('🔍 DEBUG: HabitsPage.build() - Total hábitos: ${habitProvider.habits.length}');
    debugPrint('🔍 DEBUG: HabitsPage.build() - Hábitos activos: ${habitProvider.activeHabits.length}');

    // Aplicar filtros a los hábitos
    final filteredHabits = _filterHabits(habitProvider.habits);
    debugPrint('🔍 DEBUG: HabitsPage.build() - Hábitos filtrados: ${filteredHabits.length}');

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header compacto
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
              child: Row(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF7F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_getTodaysHabits(filteredHabits).length} para hoy',
                      style: const TextStyle(
                        color: Color(0xFF00FF7F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Weekly Calendar
            _buildWeeklyCalendar(themeProvider, habitProvider),

            // Habits List
            Expanded(
              child: habitProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredHabits.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                          itemCount: filteredHabits.length,
                          itemBuilder: (context, index) {
                            final habit = filteredHabits[index];
                            return _buildHabitCard(habit, themeProvider, habitProvider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Habit> _filterHabits(List<Habit> habits) {
    debugPrint('🔍 DEBUG: _filterHabits() - Entrada: ${habits.length} hábitos');

    final filtered = habits.where((habit) {
      debugPrint('🔍 DEBUG: Filtrando hábito: ${habit.title} (ID: ${habit.id})');

      // Filtro de búsqueda
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        final query = widget.searchQuery!.toLowerCase();
        if (!habit.title.toLowerCase().contains(query) &&
            (habit.notes == null || !habit.notes!.toLowerCase().contains(query))) {
          debugPrint('🔍 DEBUG: Hábito filtrado por búsqueda: ${habit.title}');
          return false;
        }
      }

      // Filtro de dificultad
      if (widget.selectedDifficulty != null && habit.difficulty != widget.selectedDifficulty) {
        debugPrint('🔍 DEBUG: Hábito filtrado por dificultad: ${habit.title}');
        return false;
      }

      // Filtro de estado completado
      if (widget.showCompleted != null) {
        if (widget.showCompleted! && !habit.isCompletedToday) {
          debugPrint('🔍 DEBUG: Hábito filtrado por estado completado: ${habit.title}');
          return false;
        }
        if (!widget.showCompleted! && habit.isCompletedToday) {
          debugPrint('🔍 DEBUG: Hábito filtrado por estado no completado: ${habit.title}');
          return false;
        }
      }

      // Filtro de completado hoy
      if (widget.showCompletedToday != null) {
        if (widget.showCompletedToday! && !habit.isCompletedToday) {
          debugPrint('🔍 DEBUG: Hábito filtrado por completado hoy: ${habit.title}');
          return false;
        }
        if (!widget.showCompletedToday! && habit.isCompletedToday) {
          debugPrint('🔍 DEBUG: Hábito filtrado por no completado hoy: ${habit.title}');
          return false;
        }
      }

      // Filtro por días de la semana para hábitos diarios
      if (habit.repeatType == RepeatType.daily && habit.selectedDays.isNotEmpty) {
        final today = DateTime.now();
        final todayWeekDay = _dateTimeToWeekDay(today);
        if (!habit.selectedDays.contains(todayWeekDay)) {
          debugPrint('🔍 DEBUG: Hábito filtrado por día de la semana: ${habit.title}');
          return false;
        }
      }

      debugPrint('🔍 DEBUG: Hábito aprobado: ${habit.title}');
      return true;
    }).toList();

    debugPrint('🔍 DEBUG: _filterHabits() - Salida: ${filtered.length} hábitos');
    return filtered;
  }

  List<Habit> _getTodaysHabits(List<Habit> habits) {
    return habits.where((habit) => !habit.isCompletedToday).toList();
  }

  int _getActiveStreaks(List<Habit> habits) {
    return habits.where((habit) => habit.streak > 0).length;
  }

  int _getBestStreaks(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((habit) => habit.bestStreak).reduce((a, b) => a > b ? a : b);
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
            'No tienes hábitos pendientes ',
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
      child: InkWell(
        onDoubleTap: () => _showHabitDetails(habit),
        onLongPress: () => _editHabit(habit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          //padding: const EdgeInsets.all(16),
           padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono del hábito
                  GestureDetector(
                    onTap: () => _editHabit(habit),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF7F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getHabitIcon(habit.icon),
                        size: 24,
                        color: const Color(0xFF00FF7F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        // Mostrar tipo de objetivo
                        if (habit.goalType != HabitGoalType.deactivate) ...[
                          const SizedBox(height: 2),
                          Text(
                            _getGoalTypeText(habit),
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Botón de acción basado en el tipo de objetivo
                  if (habit.goalType == HabitGoalType.duration || habit.goalType == HabitGoalType.repeat) ...[
                    ElevatedButton.icon(
                      onPressed: habit.isCompletedToday ? null : () {
                        if (habit.goalType == HabitGoalType.duration) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitTimerPage(habit: habit),
                            ),
                          );
                        } else if (habit.goalType == HabitGoalType.repeat) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitCounterPage(habit: habit),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        habit.isCompletedToday
                            ? Icons.check_circle
                            : habit.goalType == HabitGoalType.duration
                                ? Icons.play_arrow
                                : Icons.add,
                        size: 20,
                      ),
                      label: const Text(''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habit.isCompletedToday
                            ? Colors.green
                            : const Color(0xFF00FF7F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.2),
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: const Size(0, 21),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: habit.isCompletedToday ? null : () async {
                        await habitProvider.completeHabitToday(habit.id);
                      },
                      icon: Icon(
                        habit.isCompletedToday
                            ? Icons.check_circle
                            : Icons.done,
                        size: 20,
                      ),
                      label: const Text(''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habit.isCompletedToday
                            ? Colors.green
                            : const Color(0xFF00FF7F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.2),
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: const Size(0, 21),
                      ),
                    ),
                  ],
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
                  const Spacer(),
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
                  ],
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildWeeklyCalendar(ThemeProvider themeProvider, HabitProvider habitProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      height: 56, // Altura aumentada para el contenedor
      child: PageView.builder(
        controller: PageController(viewportFraction: 1.0, initialPage: 1000), // Página inicial en el medio para permitir navegación ilimitada
        itemBuilder: (context, weekIndex) {
          final now = DateTime.now();
          // Calcular el inicio de la semana (domingo) para esta página
          final adjustedWeekIndex = weekIndex - 1000; // Centrar en 0
          final adjustedWeekday = now.weekday % 7; // Convertir Monday=1 a Sunday=0
          final startOfWeek = now.subtract(Duration(days: adjustedWeekday)).add(Duration(days: adjustedWeekIndex * 7));
          final days = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((date) {
              // Get habits that should appear on this date (created before or on this date)
              final habitsForDate = habitProvider.habits.where((habit) =>
                !date.isBefore(habit.startDate) && _shouldHabitAppearOnDate(habit, date)
              ).toList();

              // Check completion status
              final completedCount = habitsForDate.where((habit) =>
                habit.completedDates.any((completedDate) =>
                  completedDate.year == date.year &&
                  completedDate.month == date.month &&
                  completedDate.day == date.day)
              ).length;

              final allCompleted = habitsForDate.isNotEmpty && completedCount == habitsForDate.length;
              final someCompleted = habitsForDate.isNotEmpty && completedCount > 0 && completedCount < habitsForDate.length;

              final isToday = date.year == now.year &&
                             date.month == now.month &&
                             date.day == now.day;

              return GestureDetector(
                onTap: () {
                  // Mostrar detalles del día
                  _showDayDetails(date, habitProvider.habits);
                },
                child: Container(
                  width: 36, // Ancho fijo más estrecho
                  height: 44, // Alto fijo
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: allCompleted
                        ? const Color(0xFF00FF7F) // Verde para todos completados
                        : someCompleted
                            ? const Color.fromARGB(255, 60, 86, 54) // Naranja para parcialmente completados
                            : isToday
                                ? const Color(0xFF00FF7F).withValues(alpha: 0.3)
                                : themeProvider.isDarkMode
                                    ? Colors.grey.withValues(alpha:  0.1)
                                    : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(color: const Color(0xFF00FF7F), width: 1) : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Número del día (centrado)
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (allCompleted || someCompleted) ? FontWeight.bold : FontWeight.normal,
                          color: allCompleted
                              ? Colors.white
                              : someCompleted
                                  ? Colors.white
                                  : themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                        ),
                      ),
                      // Letra del día (esquina superior derecha)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                          decoration: BoxDecoration(
                            color: (allCompleted || someCompleted)
                                ? Colors.white.withOpacity(0.2)
                                : themeProvider.isDarkMode
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            _getDayLetter(date.weekday),
                            style: TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.w600,
                              color: (allCompleted || someCompleted)
                                  ? Colors.white
                                  : themeProvider.isDarkMode
                                      ? Colors.grey
                                      : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
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

  String _getDayLetter(int weekday) {
    // weekday: 1 = Monday, 7 = Sunday, but we want Sunday first
    // Convert to Sunday-based: Sunday=0, Monday=1, ..., Saturday=6
    const days = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    final sundayBasedIndex = (weekday % 7);
    return days[sundayBasedIndex];
  }

  WeekDay _dateTimeToWeekDay(DateTime date) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    switch (date.weekday) {
      case 1:
        return WeekDay.monday;
      case 2:
        return WeekDay.tuesday;
      case 3:
        return WeekDay.wednesday;
      case 4:
        return WeekDay.thursday;
      case 5:
        return WeekDay.friday;
      case 6:
        return WeekDay.saturday;
      case 7:
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }

  bool _shouldHabitAppearOnDate(Habit habit, DateTime date) {
    // Verificar si la fecha es anterior a la fecha de creación del hábito
    if (date.isBefore(habit.startDate)) {
      return false;
    }

    // Para hábitos diarios con días específicos seleccionados
    if (habit.repeatType == RepeatType.daily && habit.selectedDays.isNotEmpty) {
      final dateWeekDay = _dateTimeToWeekDay(date);
      return habit.selectedDays.contains(dateWeekDay);
    }

    // Para otros tipos de repetición, aparecer todos los días desde la fecha de creación
    return true;
  }

  void _showDayDetails(DateTime date, List<Habit> allHabits) {
    // Get all habits that existed on this date (created before or on this date)
    final habitsThatExisted = allHabits.where((habit) =>
      !date.isBefore(habit.startDate)
    ).toList();

    // If no habits existed on this date, show message
    if (habitsThatExisted.isEmpty) {
      _showNoHabitsMessage(date);
      return;
    }

    final completedHabits = habitsThatExisted.where((habit) {
      // Verificar si el hábito fue completado en esa fecha
      return habit.completedDates.any((completedDate) =>
          completedDate.year == date.year &&
          completedDate.month == date.month &&
          completedDate.day == date.day);
    }).toList();

    final pendingHabits = habitsThatExisted.where((habit) {
      // Verificar si el hábito no fue completado en esa fecha
      return !habit.completedDates.any((completedDate) =>
          completedDate.year == date.year &&
          completedDate.month == date.month &&
          completedDate.day == date.day);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (completedHabits.isNotEmpty) ...[
                        Text(
                          'Completados (${completedHabits.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...completedHabits.map((habit) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getHabitIcon(habit.icon),
                                size: 20,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  habit.title,
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 20),
                      ],

                      if (pendingHabits.isNotEmpty) ...[
                        Text(
                          'Pendientes (${pendingHabits.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...pendingHabits.map((habit) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getHabitIcon(habit.icon),
                                size: 20,
                                color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  habit.title,
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.radio_button_unchecked,
                                color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
                                size: 20,
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        return 'Medio';
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

  void _editHabit(Habit habit) {
    Navigator.of(context).pushNamed('/edit-habit', arguments: habit);
  }

  void _showHabitDetails(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailsPage(habit: habit),
      ),
    );
  }

  void _showNoHabitsMessage(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tenías hábitos creados para esta fecha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los hábitos se muestran desde su fecha de creación',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}