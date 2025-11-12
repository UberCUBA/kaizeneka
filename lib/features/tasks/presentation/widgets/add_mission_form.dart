import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../../models/task_models.dart';

class AddMissionForm extends StatefulWidget {
  const AddMissionForm({super.key});

  @override
  State<AddMissionForm> createState() => _AddMissionFormState();
}

class _AddMissionFormState extends State<AddMissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _pointsController = TextEditingController();

  Difficulty _difficulty = Difficulty.medium;
  RepeatType? _repeatType;
  DateTime _startDate = DateTime.now();
  final List<SubMission> _subMissions = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _pointsController.dispose();
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
                  'Nueva Misión',
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
                        labelText: 'Título de la misión',
                        hintText: 'Ej: Correr 5km',
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

                    // Points
                    TextFormField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Puntos por completar',
                        hintText: 'Ej: 50',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
                        prefixIcon: const Icon(Icons.stars, color: Color(0xFF00FF7F)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los puntos son obligatorios';
                        }
                        final points = int.tryParse(value);
                        if (points == null || points <= 0) {
                          return 'Ingresa un número válido mayor a 0';
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
                                        ? Colors.grey.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.1),
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

                    // SubMissions
                    Row(
                      children: [
                        Text(
                          'Submisiones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _addSubMission,
                          icon: const Icon(Icons.add, color: Color(0xFF00FF7F)),
                        ),
                      ],
                    ),

                    if (_subMissions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._subMissions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subMission = entry.value;
                        return _buildSubMissionItem(index, subMission);
                      }),
                    ],

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveMission,
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
                                'Crear Misión',
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

  void _addSubMission() {
    setState(() {
      _subMissions.add(SubMission(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        points: 0,
      ));
    });
  }

  Widget _buildSubMissionItem(int index, SubMission subMission) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: subMission.title,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la submisión',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _subMissions[index] = subMission.copyWith(title: value);
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _subMissions.removeAt(index);
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.stars, size: 16, color: Color(0xFF00FF7F)),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: subMission.points?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Puntos',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    final points = int.tryParse(value) ?? 0;
                    setState(() {
                      _subMissions[index] = subMission.copyWith(points: points);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveMission() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate submisions
    final validSubMissions = _subMissions.where((sub) => sub.title.trim().isNotEmpty).toList();

    setState(() => _isLoading = true);

    try {
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);

      final mission = Mission(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        difficulty: _difficulty,
        startDate: _startDate,
        repeatType: _repeatType,
        points: int.parse(_pointsController.text.trim()),
        subMissions: validSubMissions,
      );

      await missionProvider.addMission(mission);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Misión creada exitosamente'),
            backgroundColor: Color(0xFF00FF7F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear misión: $e'),
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