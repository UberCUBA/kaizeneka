import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../../../habits/presentation/providers/habit_provider.dart';
import '../../../../models/task_models.dart';
import 'habit_selection_page.dart';

class HabitTemplatesPage extends StatefulWidget {
  final HabitCategory category;

  const HabitTemplatesPage({super.key, required this.category});

  @override
  State<HabitTemplatesPage> createState() => _HabitTemplatesPageState();
}

class _HabitTemplatesPageState extends State<HabitTemplatesPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

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
          widget.category.name,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: widget.category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.category.icon,
                        size: 24,
                        color: widget.category.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.category.description,
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
              ),

              const SizedBox(height: 24),

              Text(
                'Elige un hábito para comenzar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Habits List
              Expanded(
                child: ListView.builder(
                  itemCount: widget.category.habits.length,
                  itemBuilder: (context, index) {
                    final habit = widget.category.habits[index];
                    return _buildHabitCard(context, habit);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitTemplate habit) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _selectHabit(habit),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.category.icon,
                  size: 24,
                  color: widget.category.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectHabit(HabitTemplate habit) {
    // Navigate to the habit creation form with pre-filled name
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitCreationPage(
          category: widget.category,
          selectedHabit: habit,
        ),
      ),
    );
  }
}

class HabitCreationPage extends StatefulWidget {
  final HabitCategory category;
  final HabitTemplate selectedHabit;

  const HabitCreationPage({
    super.key,
    required this.category,
    required this.selectedHabit,
  });

  @override
  State<HabitCreationPage> createState() => _HabitCreationPageState();
}

class _HabitCreationPageState extends State<HabitCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  Difficulty _difficulty = Difficulty.medium;
  RepeatType _repeatType = RepeatType.daily;
  DateTime _startDate = DateTime.now();
  HabitIcon _icon = HabitIcon.check_circle;
  HabitGoalType _goalType = HabitGoalType.deactivate;
  final _targetDurationController = TextEditingController();
  final _targetRepetitionsController = TextEditingController();
  List<WeekDay> _selectedDays = [];

  // Nuevos campos para ajustes avanzados
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  final _reminderDescriptionController = TextEditingController();
  HabitEndType _endType = HabitEndType.deactivated;
  DateTime? _endDate;
  final _endDaysController = TextEditingController();

  bool _isAdvancedExpanded = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the title with the selected habit name
    _titleController.text = widget.selectedHabit.name;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _targetDurationController.dispose();
    _targetRepetitionsController.dispose();
    _reminderDescriptionController.dispose();
    _endDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

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
          'Crear Hábito',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Selected Habit Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.category.icon,
                        color: widget.category.color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedHabit.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              widget.category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.category.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Title Field (pre-filled)
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del hábito',
                    hintText: 'Ej: Beber agua',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Icon Selection
                Text(
                  'Icono',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildIconSelector(themeProvider),

                const SizedBox(height: 20),

                // Goal Type Selection
                Text(
                  'Tipo de Objetivo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildGoalTypeSelector(themeProvider),

                // Target Duration/Repetitions (only show if applicable)
                if (_goalType == HabitGoalType.duration) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetDurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duración objetivo (minutos)',
                      hintText: 'Ej: 30',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                    ),
                    validator: (value) {
                      if (_goalType == HabitGoalType.duration) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La duración es obligatoria';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Ingresa una duración válida';
                        }
                      }
                      return null;
                    },
                  ),
                ] else if (_goalType == HabitGoalType.repeat) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetRepetitionsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Repeticiones objetivo',
                      hintText: 'Ej: 10',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                    ),
                    validator: (value) {
                      if (_goalType == HabitGoalType.repeat) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Las repeticiones son obligatorias';
                        }
                        final reps = int.tryParse(value);
                        if (reps == null || reps <= 0) {
                          return 'Ingresa un número válido';
                        }
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Detalles adicionales...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                  ),
                ),

                const SizedBox(height: 20),

                // Advanced Settings Section
                ExpansionTile(
                  title: Text(
                    'Ajustes Avanzados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  initiallyExpanded: _isAdvancedExpanded,
                  onExpansionChanged: (expanded) => setState(() => _isAdvancedExpanded = expanded),
                  children: [
                    const SizedBox(height: 16),

                    // Reminder Section
                    Text(
                      'Recordatorio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Habilitar recordatorio'),
                      value: _reminderEnabled,
                      onChanged: (value) => setState(() => _reminderEnabled = value),
                      activeColor: const Color(0xFF00FF7F),
                    ),
                    if (_reminderEnabled) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Hora del recordatorio',
                                hintText: 'Seleccionar hora',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                                suffixIcon: const Icon(Icons.access_time),
                              ),
                              controller: TextEditingController(
                                text: _reminderTime != null
                                    ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                    : '',
                              ),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _reminderTime ?? TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() => _reminderTime = time);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reminderDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción del recordatorio',
                          hintText: 'Ej: ¡Es hora de tu hábito!',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // End Type Section
                    Text(
                      'Terminar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: HabitEndType.values.map((endType) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _endType = endType),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _endType == endType
                                    ? const Color(0xFF00FF7F)
                                    : themeProvider.isDarkMode
                                        ? Colors.grey.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: _endType == endType
                                    ? Border.all(color: const Color(0xFF00FF7F), width: 2)
                                    : null,
                              ),
                              child: Text(
                                _getEndTypeLabel(endType),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _endType == endType
                                      ? Colors.black
                                      : themeProvider.isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // End Date/Days (only show if applicable)
                    if (_endType == HabitEndType.date) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha de finalización',
                          hintText: 'Seleccionar fecha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            setState(() => _endDate = date);
                          }
                        },
                      ),
                    ] else if (_endType == HabitEndType.days) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _endDaysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Días para terminar',
                          hintText: 'Ej: 30',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                        ),
                        validator: (value) {
                          if (_endType == HabitEndType.days) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Los días son obligatorios';
                            }
                            final days = int.tryParse(value);
                            if (days == null || days <= 0) {
                              return 'Ingresa un número válido';
                            }
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Difficulty
                    Text(
                      'Dificultad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: Difficulty.values.map((difficulty) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _difficulty = difficulty),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _difficulty == difficulty
                                    ? _getDifficultyColor(difficulty)
                                    : themeProvider.isDarkMode
                                        ? Colors.grey.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: _difficulty == difficulty
                                    ? Border.all(color: _getDifficultyColor(difficulty), width: 2)
                                    : null,
                              ),
                              child: Text(
                                _getDifficultyLabel(difficulty),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _difficulty == difficulty
                                      ? Colors.white
                                      : themeProvider.isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Repeat Type
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: RepeatType.values.map((repeatType) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _repeatType = repeatType),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _repeatType == repeatType
                                    ? const Color(0xFF00FF7F)
                                    : themeProvider.isDarkMode
                                        ? Colors.grey.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.0),
                                border: _repeatType == repeatType
                                    ? Border.all(color: const Color(0xFF00FF7F), width: 2)
                                    : null,
                              ),
                              child: Text(
                                _getRepeatTypeLabel(repeatType),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _repeatType == repeatType
                                      ? Colors.black
                                      : themeProvider.isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Day Selector for Daily habits
                    if (_repeatType == RepeatType.daily) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Días de la semana',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDaySelector(themeProvider),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF7F),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Crear Hábito',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        difficulty: _difficulty,
        startDate: _startDate,
        repeatType: _repeatType,
        icon: _icon,
        goalType: _goalType,
        targetDuration: _goalType == HabitGoalType.duration
            ? int.tryParse(_targetDurationController.text)
            : null,
        targetRepetitions: _goalType == HabitGoalType.repeat
            ? int.tryParse(_targetRepetitionsController.text)
            : null,
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderTime,
        reminderDescription: _reminderDescriptionController.text.trim().isEmpty
            ? null
            : _reminderDescriptionController.text.trim(),
        endType: _endType,
        endDate: _endType == HabitEndType.date ? _endDate : null,
        endDays: _endType == HabitEndType.days
            ? int.tryParse(_endDaysController.text)
            : null,
        selectedDays: _selectedDays,
      );

      await habitProvider.addHabit(habit);

      if (mounted) {
        // Navigate to habits tab in main tasks page
        Navigator.of(context).pushNamedAndRemoveUntil('/tasks', (route) => false, arguments: 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hábito creado exitosamente'),
            backgroundColor: Color(0xFF00FF7F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear hábito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        return 'Días';
      case RepeatType.weekly:
        return 'Semanal';
      case RepeatType.monthly:
        return 'Mensual';
    }
  }

  String _getWeekDayLabel(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return 'L';
      case WeekDay.tuesday:
        return 'M';
      case WeekDay.wednesday:
        return 'X';
      case WeekDay.thursday:
        return 'J';
      case WeekDay.friday:
        return 'V';
      case WeekDay.saturday:
        return 'S';
      case WeekDay.sunday:
        return 'D';
    }
  }

  Widget _buildDaySelector(custom_theme.ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: WeekDay.values.map((day) {
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00FF7F)
                  : themeProvider.isDarkMode
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(color: const Color(0xFF00FF7F), width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                _getWeekDayLabel(day),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.black
                      : themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getEndTypeLabel(HabitEndType endType) {
    switch (endType) {
      case HabitEndType.deactivated:
        return 'Desactivado';
      case HabitEndType.date:
        return 'Fecha';
      case HabitEndType.days:
        return 'Días';
    }
  }

  Widget _buildIconSelector(custom_theme.ThemeProvider themeProvider) {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: HabitIcon.values.length,
        itemBuilder: (context, index) {
          final icon = HabitIcon.values[index];
          final isSelected = _icon == icon;

          return GestureDetector(
            onTap: () => setState(() => _icon = icon),
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00FF7F)
                    : themeProvider.isDarkMode
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: const Color(0xFF00FF7F), width: 2)
                    : null,
              ),
              child: Icon(
                _getIconData(icon),
                color: isSelected
                    ? Colors.black
                    : themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalTypeSelector(custom_theme.ThemeProvider themeProvider) {
    return Row(
      children: HabitGoalType.values.map((goalType) {
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _goalType = goalType),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _goalType == goalType
                    ? const Color(0xFF00FF7F)
                    : themeProvider.isDarkMode
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: _goalType == goalType
                    ? Border.all(color: const Color(0xFF00FF7F), width: 2)
                    : null,
              ),
              child: Text(
                _getGoalTypeLabel(goalType),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _goalType == goalType
                      ? Colors.black
                      : themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconData(HabitIcon icon) {
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
        return Icons.check_circle;
    }
  }

  String _getGoalTypeLabel(HabitGoalType goalType) {
    switch (goalType) {
      case HabitGoalType.deactivate:
        return 'Desactivar';
      case HabitGoalType.duration:
        return 'Duración';
      case HabitGoalType.repeat:
        return 'Repetir';
    }
  }
}