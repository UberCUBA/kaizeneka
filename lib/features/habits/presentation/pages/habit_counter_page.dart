import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/habit_provider.dart';
import '../../../../models/task_models.dart';

class HabitCounterPage extends StatefulWidget {
  final Habit habit;

  const HabitCounterPage({super.key, required this.habit});

  @override
  State<HabitCounterPage> createState() => _HabitCounterPageState();
}

class _HabitCounterPageState extends State<HabitCounterPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentRepetitions = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    if (_isCompleted) return;

    setState(() {
      _currentRepetitions++;
    });

    // Animación de feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Verificar si completó el objetivo
    if (widget.habit.targetRepetitions != null &&
        _currentRepetitions >= widget.habit.targetRepetitions!) {
      _completeHabit();
    }
  }

  void _decrementCounter() {
    if (_currentRepetitions > 0 && !_isCompleted) {
      setState(() {
        _currentRepetitions--;
      });
    }
  }

  void _resetCounter() {
    setState(() {
      _currentRepetitions = 0;
      _isCompleted = false;
    });
  }

  void _completeHabit() async {
    setState(() {
      _isCompleted = true;
    });

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.completeHabitToday(widget.habit.id);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          '¡Excelente trabajo! 🎉',
          style: TextStyle(color: Color(0xFF00FF7F)),
        ),
        content: Text(
          'Has completado tu objetivo de ${widget.habit.targetRepetitions} repeticiones.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pushNamedAndRemoveUntil('/tasks', (route) => false, arguments: 0); // Volver al tab de hábitos
            },
            child: const Text(
              'Continuar',
              style: TextStyle(color: Color(0xFF00FF7F)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
        title: Text(
          widget.habit.title,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
        actions: [
          IconButton(
            onPressed: _resetCounter,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar contador',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono del hábito
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : const Color(0xFF00FF7F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getHabitIcon(widget.habit.icon),
                    size: 60,
                    color: _isCompleted ? Colors.green : const Color(0xFF00FF7F),
                  ),
                ),

                const SizedBox(height: 20),

                // Contador principal
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _isCompleted
                                  ? Colors.green.withOpacity(0.3)
                                  : const Color(0xFF00FF7F).withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$_currentRepetitions',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: _isCompleted
                                    ? Colors.green
                                    : themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (widget.habit.targetRepetitions != null)
                              Text(
                                '/ ${widget.habit.targetRepetitions}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Objetivo
                if (widget.habit.targetRepetitions != null) ...[
                  Text(
                    'Objetivo: ${widget.habit.targetRepetitions} repeticiones',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      value: widget.habit.targetRepetitions! > 0
                          ? _currentRepetitions / widget.habit.targetRepetitions!
                          : 0,
                      backgroundColor: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isCompleted ? Colors.green : const Color(0xFF00FF7F),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Botones de control
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón decrementar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _decrementCounter,
                        icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                        tooltip: 'Disminuir',
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Botón principal (incrementar)
                    GestureDetector(
                      onTap: _incrementCounter,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isCompleted ? Colors.green : const Color(0xFF00FF7F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isCompleted ? Colors.green : const Color(0xFF00FF7F)).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isCompleted ? Icons.check : Icons.add,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Espacio vacío para simetría
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 20),

                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : const Color(0xFF00FF7F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isCompleted
                        ? '¡Objetivo completado! 🎉'
                        : 'Toca para contar',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isCompleted
                          ? Colors.green
                          : const Color(0xFF00FF7F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Información adicional
                if (!_isCompleted && widget.habit.targetRepetitions != null) ...[
                  Text(
                    '${widget.habit.targetRepetitions! - _currentRepetitions} repeticiones restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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

  // Future<void> completeHabitToday(String habitId, [MissionProvider? missionProvider]) async {
  //   final index = _habits.indexWhere((habit) => habit.id == habitId);
  //   if (index != -1) {
  //     final habit = _habits[index];
  //     if (!habit.isCompletedToday) {
  //       final today = DateTime.now();
  //       final updatedCompletedDates = [...habit.completedDates, today];
  //       final newStreak = _calculateStreak(updatedCompletedDates, habit.repeatType);
  //       final newBestStreak = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

  //       final updatedHabit = habit.copyWith(
  //         completedDates: updatedCompletedDates,
  //         streak: newStreak,
  //         bestStreak: newBestStreak,
  //         isCompletedToday: true,
  //       );
  //       //_habits[index] = updatedHabit;

  //       // Si se proporciona un MissionProvider, se puede usar para actualizar la misión
  //       missionProvider?.updateHabit(updatedHabit);
  //     }
  //   }
  
