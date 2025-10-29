import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../providers/task_provider.dart';
import '../../../../models/task_models.dart';

class TasksPage extends StatefulWidget {
  final String? searchQuery;
  final Difficulty? selectedDifficulty;
  final bool? showCompleted;

  const TasksPage({
    super.key,
    this.searchQuery,
    this.selectedDifficulty,
    this.showCompleted,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    // Aplicar filtros a las tareas
    final filteredTasks = _filterTasks(taskProvider.tasks);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Text(
                  //   'Tareas',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  //   ),
                  // ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF7F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_getPendingTasks(filteredTasks).length} pendientes',
                      style: const TextStyle(
                        color: Color(0xFF00FF7F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTasks.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return _buildTaskCard(task, themeProvider, taskProvider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      // Filtro de búsqueda
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        final query = widget.searchQuery!.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            (task.notes == null || !task.notes!.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Filtro de dificultad
      if (widget.selectedDifficulty != null && task.difficulty != widget.selectedDifficulty) {
        return false;
      }

      // Filtro de estado completado
      if (widget.showCompleted != null) {
        if (widget.showCompleted! && !task.isCompleted) {
          return false;
        }
        if (!widget.showCompleted! && task.isCompleted) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Task> _getPendingTasks(List<Task> tasks) {
    return tasks.where((task) => !task.isCompleted).toList();
  }

  Widget _buildEmptyState(custom_theme.ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes tareas pendientes',
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Crea tu primera tarea!',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, custom_theme.ThemeProvider themeProvider, TaskProvider taskProvider) {
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
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    if (value != null) {
                      taskProvider.toggleTaskCompletion(task.id);
                    }
                  },
                  activeColor: const Color(0xFF00FF7F),
                ),
              ],
            ),

            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Task metadata
            Row(
              children: [
                _buildDifficultyChip(task.difficulty),
                const SizedBox(width: 8),
                Text(
                  _formatDate(task.startDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
                if (task.repeatType != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.repeat,
                    size: 14,
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.repeatType!.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),

            // Subtasks
            if (task.subTasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...task.subTasks.map((subTask) => _buildSubTaskItem(subTask, task.id, taskProvider, themeProvider)),
            ],
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

  Widget _buildSubTaskItem(SubTask subTask, String taskId, TaskProvider taskProvider, custom_theme.ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: subTask.isCompleted,
              onChanged: (value) {
                if (value != null) {
                  taskProvider.toggleSubTaskCompletion(taskId, subTask.id);
                }
              },
              activeColor: const Color(0xFF00FF7F),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subTask.title,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}