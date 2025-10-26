import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../../../habits/presentation/providers/habit_provider.dart';
import '../../../../models/task_models.dart';

class AddHabitForm extends StatefulWidget {
  const AddHabitForm({super.key});

  @override
  State<AddHabitForm> createState() => _AddHabitFormState();
}

class _AddHabitFormState extends State<AddHabitForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  Difficulty _difficulty = Difficulty.medium;
  RepeatType _repeatType = RepeatType.daily;
  DateTime _startDate = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  'Nuevo Hábito',
                  style: TextStyle(
                    fontSize: 20,
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

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
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
                                    ? Border.all(color: Color(0xFF00FF7F), width: 2)
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

                    const SizedBox(height: 20),

                    // Preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vista previa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _titleController.text.isEmpty ? 'Nombre del hábito' : _titleController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(_difficulty).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      _getDifficultyLabel(_difficulty),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getDifficultyColor(_difficulty),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF00FF7F),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      _getRepeatTypeLabel(_repeatType),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(7, (index) {
                              final isToday = index == 6; // Último día
                              return Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? const Color(0xFF00FF7F)
                                      : themeProvider.isDarkMode
                                          ? Colors.grey.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: isToday ? Border.all(color: const Color(0xFF00FF7F), width: 2) : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${DateTime.now().subtract(Duration(days: 6 - index)).day}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isToday
                                          ? Colors.black
                                          : themeProvider.isDarkMode
                                              ? Colors.grey
                                              : Colors.black54,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
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
        ],
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
      );

      await habitProvider.addHabit(habit);

      if (mounted) {
        Navigator.of(context).pop();
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
        return 'Diario';
      case RepeatType.weekly:
        return 'Semanal';
      case RepeatType.monthly:
        return 'Mensual';
    }
  }
}