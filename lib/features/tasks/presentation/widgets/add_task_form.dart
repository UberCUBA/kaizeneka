import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../providers/task_provider.dart';
import '../../../../models/task_models.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  Difficulty _difficulty = Difficulty.medium;
  RepeatType? _repeatType;
  DateTime _startDate = DateTime.now();
  final List<SubTask> _subTasks = [];

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
                  'Nueva Tarea',
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
                        labelText: 'Título de la tarea',
                        hintText: 'Ej: Hacer ejercicio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es obligatorio';
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
                      'Repetición (opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Diario'),
                          selected: _repeatType == RepeatType.daily,
                          onSelected: (selected) {
                            setState(() => _repeatType = selected ? RepeatType.daily : null);
                          },
                        ),
                        FilterChip(
                          label: const Text('Semanal'),
                          selected: _repeatType == RepeatType.weekly,
                          onSelected: (selected) {
                            setState(() => _repeatType = selected ? RepeatType.weekly : null);
                          },
                        ),
                        FilterChip(
                          label: const Text('Mensual'),
                          selected: _repeatType == RepeatType.monthly,
                          onSelected: (selected) {
                            setState(() => _repeatType = selected ? RepeatType.monthly : null);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Subtasks
                    Row(
                      children: [
                        Text(
                          'Subtareas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _addSubTask,
                          icon: const Icon(Icons.add, color: Color(0xFF00FF7F)),
                        ),
                      ],
                    ),

                    if (_subTasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._subTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subTask = entry.value;
                        return _buildSubTaskItem(index, subTask);
                      }),
                    ],

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTask,
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
                                'Crear Tarea',
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

  void _addSubTask() {
    setState(() {
      _subTasks.add(SubTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
      ));
    });
  }

  Widget _buildSubTaskItem(int index, SubTask subTask) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: subTask.title,
              decoration: const InputDecoration(
                hintText: 'Nombre de la subtarea',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {
                  _subTasks[index] = subTask.copyWith(title: value);
                });
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _subTasks.removeAt(index);
              });
            },
            icon: Icon(
              Icons.delete,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate subtasks
    final validSubTasks = _subTasks.where((sub) => sub.title.trim().isNotEmpty).toList();

    setState(() => _isLoading = true);

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        difficulty: _difficulty,
        startDate: _startDate,
        repeatType: _repeatType,
        subTasks: validSubTasks,
      );

      await taskProvider.addTask(task);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea creada exitosamente'),
            backgroundColor: Color(0xFF00FF7F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear tarea: $e'),
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
}