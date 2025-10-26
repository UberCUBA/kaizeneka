import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_models.dart';
import 'supabase_service.dart';

class TasksService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Tasks CRUD
  Future<List<Task>> getUserTasks(String userId) async {
    try {
      final response = await _supabase
          .from('user_tasks')
          .select('*, task_subtasks(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas: $e');
    }
  }

  Future<Task> createTask(String userId, Task task) async {
    try {
      final taskData = {
        'user_id': userId,
        'title': task.title,
        'notes': task.notes,
        'difficulty': task.difficulty.name,
        'start_date': task.startDate.toIso8601String(),
        'repeat_type': task.repeatType?.name,
        'is_completed': task.isCompleted,
        'created_at': task.createdAt.toIso8601String(),
        'completed_at': task.completedAt?.toIso8601String(),
      };

      final response = await _supabase
          .from('user_tasks')
          .insert(taskData)
          .select()
          .single();

      final createdTask = Task.fromJson(response);

      // Crear subtareas si existen
      if (task.subTasks.isNotEmpty) {
        await _createSubTasks(createdTask.id, task.subTasks);
      }

      return createdTask;
    } catch (e) {
      throw Exception('Error al crear tarea: $e');
    }
  }

  Future<Task> updateTask(String taskId, Task task) async {
    try {
      final taskData = {
        'title': task.title,
        'notes': task.notes,
        'difficulty': task.difficulty.name,
        'start_date': task.startDate.toIso8601String(),
        'repeat_type': task.repeatType?.name,
        'is_completed': task.isCompleted,
        'completed_at': task.completedAt?.toIso8601String(),
      };

      final response = await _supabase
          .from('user_tasks')
          .update(taskData)
          .eq('id', taskId)
          .select('*, task_subtasks(*)')
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar tarea: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      // Las subtareas se eliminan automáticamente por foreign key cascade
      await _supabase.from('user_tasks').delete().eq('id', taskId);
    } catch (e) {
      throw Exception('Error al eliminar tarea: $e');
    }
  }

  // SubTasks CRUD
  Future<void> _createSubTasks(String taskId, List<SubTask> subTasks) async {
    try {
      final subTasksData = subTasks.map((subTask) => {
        'task_id': taskId,
        'title': subTask.title,
        'is_completed': subTask.isCompleted,
        'due_date': subTask.dueDate?.toIso8601String(),
      }).toList();

      await _supabase.from('task_subtasks').insert(subTasksData);
    } catch (e) {
      throw Exception('Error al crear subtareas: $e');
    }
  }

  Future<void> updateSubTask(String subTaskId, SubTask subTask) async {
    try {
      final subTaskData = {
        'title': subTask.title,
        'is_completed': subTask.isCompleted,
        'due_date': subTask.dueDate?.toIso8601String(),
      };

      await _supabase
          .from('task_subtasks')
          .update(subTaskData)
          .eq('id', subTaskId);
    } catch (e) {
      throw Exception('Error al actualizar subtarea: $e');
    }
  }

  Future<void> deleteSubTask(String subTaskId) async {
    try {
      await _supabase.from('task_subtasks').delete().eq('id', subTaskId);
    } catch (e) {
      throw Exception('Error al eliminar subtarea: $e');
    }
  }

  // Predefined Tasks
  Future<List<Task>> getPredefinedTasks() async {
    try {
      final response = await _supabase
          .from('predefined_tasks')
          .select('*, predefined_task_subtasks(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas predeterminadas: $e');
    }
  }

  Future<Task> assignPredefinedTask(String userId, String predefinedTaskId) async {
    try {
      // Obtener la tarea predeterminada
      final predefinedTask = await _supabase
          .from('predefined_tasks')
          .select('*, predefined_task_subtasks(*)')
          .eq('id', predefinedTaskId)
          .single();

      // Crear tarea personalizada basada en la predeterminada
      final taskData = {
        'user_id': userId,
        'title': predefinedTask['title'],
        'notes': predefinedTask['notes'],
        'difficulty': predefinedTask['difficulty'],
        'start_date': DateTime.now().toIso8601String(),
        'repeat_type': predefinedTask['repeat_type'],
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_from_predefined': true,
        'predefined_task_id': predefinedTaskId,
      };

      final response = await _supabase
          .from('user_tasks')
          .insert(taskData)
          .select()
          .single();

      final createdTask = Task.fromJson(response);

      // Crear subtareas basadas en las predeterminadas
      if (predefinedTask['predefined_task_subtasks'] != null) {
        final subTasksData = (predefinedTask['predefined_task_subtasks'] as List)
            .map((subTask) => {
          'task_id': createdTask.id,
          'title': subTask['title'],
          'is_completed': false,
          'due_date': subTask['due_date'],
        }).toList();

        await _supabase.from('task_subtasks').insert(subTasksData);
      }

      return createdTask;
    } catch (e) {
      throw Exception('Error al asignar tarea predeterminada: $e');
    }
  }

  // Sharing
  Future<String> shareTask(String taskId) async {
    try {
      // Crear un código de compartir único
      final shareCode = DateTime.now().millisecondsSinceEpoch.toString();

      await _supabase.from('shared_tasks').insert({
        'task_id': taskId,
        'share_code': shareCode,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      return shareCode;
    } catch (e) {
      throw Exception('Error al compartir tarea: $e');
    }
  }

  Future<Task> importSharedTask(String userId, String shareCode) async {
    try {
      // Obtener la tarea compartida
      final sharedTask = await _supabase
          .from('shared_tasks')
          .select('*, user_tasks(*, task_subtasks(*))')
          .eq('share_code', shareCode)
          .eq('is_active', true)
          .single();

      final originalTask = sharedTask['user_tasks'];

      // Crear copia de la tarea para el usuario
      final taskData = {
        'user_id': userId,
        'title': '${originalTask['title']} (Compartida)',
        'notes': originalTask['notes'],
        'difficulty': originalTask['difficulty'],
        'start_date': DateTime.now().toIso8601String(),
        'repeat_type': originalTask['repeat_type'],
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_shared_copy': true,
        'original_task_id': originalTask['id'],
      };

      final response = await _supabase
          .from('user_tasks')
          .insert(taskData)
          .select()
          .single();

      final createdTask = Task.fromJson(response);

      // Copiar subtareas
      if (originalTask['task_subtasks'] != null) {
        final subTasksData = (originalTask['task_subtasks'] as List)
            .map((subTask) => {
          'task_id': createdTask.id,
          'title': subTask['title'],
          'is_completed': false,
          'due_date': subTask['due_date'],
        }).toList();

        await _supabase.from('task_subtasks').insert(subTasksData);
      }

      return createdTask;
    } catch (e) {
      throw Exception('Error al importar tarea compartida: $e');
    }
  }
}