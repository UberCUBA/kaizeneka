import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/habit_provider.dart';
import '../../../../models/task_models.dart';

class HabitTimerPage extends StatefulWidget {
  final Habit habit;

  const HabitTimerPage({super.key, required this.habit});

  @override
  State<HabitTimerPage> createState() => _HabitTimerPageState();
}

class _HabitTimerPageState extends State<HabitTimerPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.habit.targetDuration != null ? widget.habit.targetDuration! * 60 : 0;
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(_animationController);

    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    Future.doWhile(() async {
      if (!_isRunning) return false;

      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRunning && !_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _isRunning = false;
            _completeHabitAutomatically();
            _playCompletionSound();
            _showCompletionDialog();
          }
        });
      }
      return _isRunning;
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = widget.habit.targetDuration != null ? widget.habit.targetDuration! * 60 : 0;
    });
  }

  void _completeTimer() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    // Verificar si cumplió con el tiempo objetivo
    if (widget.habit.targetDuration != null &&
        _remainingSeconds <= 0) {
      await habitProvider.completeHabitToday(widget.habit.id);
      _showSuccessDialog();
    } else {
      _showIncompleteDialog();
    }
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
          'Has completado tu objetivo de ${widget.habit.targetDuration} minutos.',
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

  void _showIncompleteDialog() {
    int elapsedSeconds = widget.habit.targetDuration != null ? widget.habit.targetDuration! * 60 - _remainingSeconds : 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Objetivo Incompleto',
          style: TextStyle(color: Colors.orange),
        ),
        content: Text(
          'Has dedicado ${_formatDuration(elapsedSeconds)}, Necesitas ${widget.habit.targetDuration} minutos para completar el objetivo.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continuar practicando',
              style: TextStyle(color: Color(0xFF00FF7F)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopTimer();
            },
            child: const Text(
              'Terminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _completeHabitAutomatically() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.completeHabitToday(widget.habit.id);
  }

  void _playCompletionSound() async {
    try {
      // Reproducir sonido de notificación del sistema
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Si no hay archivo, intentar con un sonido alternativo o simplemente continuar
      try {
        await _audioPlayer.play(AssetSource('sounds/completion.mp3'));
      } catch (e2) {
        // Si tampoco existe, continuar sin sonido
        print('No se pudo reproducir sonido de notificación: $e2');
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          '¡Buen Trabajo Listo!',
          style: TextStyle(color: Color(0xFF00FF7F)),
        ),
        content: const Text(
          'Hábito completado exitosamente.',
          style: TextStyle(color: Colors.white),
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

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // print('DEBUG: HabitTimerPage.build() - habit: ${widget.habit.title}, goalType: ${widget.habit.goalType}, targetDuration: ${widget.habit.targetDuration}, remainingSeconds: $_remainingSeconds');

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono del hábito
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF7F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getHabitIcon(widget.habit.icon),
                  size: 60,
                  color: const Color(0xFF00FF7F),
                ),
              ),

              const SizedBox(height: 20),

              // Temporizador con anillo de progreso
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo de progreso
                    Container(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: widget.habit.targetDuration != null && widget.habit.targetDuration! > 0
                            ? 1 - ((_remainingSeconds / 60) / widget.habit.targetDuration!)
                            : 0,
                        strokeWidth: 8, // Reducido a la mitad (16/2 = 8)
                        strokeCap: StrokeCap.round, // Punta redonda como una pelotica
                        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFF3A3A3A), // Gris más oscuro
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                      ),
                    ),
                    // Círculo del temporizador
                    Container(
                      width: 184, // Aumentado para alcanzar el tamaño del anillo (200 - 2*8 = 184)
                      height: 184,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _remainingSeconds == 0 ? 'LISTO!' : _formatDuration(_remainingSeconds),
                          style: TextStyle(
                            fontSize: _remainingSeconds == 0 ? 58 : 52, // Aumentado de 48 a 52, y 56 para LISTO!
                            fontWeight: _remainingSeconds == 0 ? FontWeight.bold : FontWeight.bold, // Siempre bold, pero más énfasis en LISTO!
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Objetivo
              if (widget.habit.targetDuration != null) ...[
                Text(
                  'Objetivo: ${widget.habit.targetDuration} minutos',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Botones de control
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning) ...[
                    // Botón Iniciar
                    ElevatedButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text('Iniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 44, 52, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ] else if (_isPaused) ...[
                    // Botones Reanudar y Detener
                    ElevatedButton.icon(
                      onPressed: _resumeTimer,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text('Reanudar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 44, 52, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton.icon(
                      onPressed: _stopTimer,
                      icon: const Icon(Icons.stop, color: Colors.red),
                      label: const Text('Detener'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Botones Pausar y Completar
                    ElevatedButton.icon(
                      onPressed: _pauseTimer,
                      icon: const Icon(Icons.pause, color: Colors.white),
                      label: const Text('Pausar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 44, 52, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _completeTimer,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Completar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 44, 52, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Información adicional
              Text(
                _isRunning
                    ? (_isPaused ? 'Temporizador pausado' : 'Temporizador activo')
                    : 'Presiona "Iniciar" para comenzar',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
}