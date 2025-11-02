import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../models/task_models.dart';
import '../../../missions/presentation/providers/mission_provider.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList('tasks') ?? [];

      _tasks = tasksJson
          .map((taskJson) => Task.fromJson(json.decode(taskJson)))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _tasks.map((task) => json.encode(task.toJson())).toList();
      await prefs.setStringList('tasks', tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(String taskId, Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId, [MissionProvider? missionProvider]) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final wasCompleted = task.isCompleted;
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      _tasks[index] = updatedTask;
      await _saveTasks();

      // Si se completó la tarea y tenemos missionProvider, agregar puntos
      if (!wasCompleted && missionProvider != null) {
        final pointsToAdd = _calculateTaskPoints(task);
        await missionProvider.addPoints(pointsToAdd);
      }

      notifyListeners();
    }
  }

  int _calculateTaskPoints(Task task) {
    // Puntos basados en dificultad
    switch (task.difficulty) {
      case Difficulty.easy:
        return 2;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        return 6;
    }
  }

  Future<void> addSubTask(String taskId, SubTask subTask) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedSubTasks = [...task.subTasks, subTask];
      final updatedTask = task.copyWith(subTasks: updatedSubTasks);
      _tasks[index] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> updateSubTask(String taskId, String subTaskId, SubTask updatedSubTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subTaskIndex = task.subTasks.indexWhere((sub) => sub.id == subTaskId);
      if (subTaskIndex != -1) {
        final updatedSubTasks = [...task.subTasks];
        updatedSubTasks[subTaskIndex] = updatedSubTask;
        final updatedTask = task.copyWith(subTasks: updatedSubTasks);
        _tasks[taskIndex] = updatedTask;
        await _saveTasks();
        notifyListeners();
      }
    }
  }

  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubTasks = task.subTasks.where((sub) => sub.id != subTaskId).toList();
      final updatedTask = task.copyWith(subTasks: updatedSubTasks);
      _tasks[taskIndex] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> toggleSubTaskCompletion(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subTaskIndex = task.subTasks.indexWhere((sub) => sub.id == subTaskId);
      if (subTaskIndex != -1) {
        final subTask = task.subTasks[subTaskIndex];
        final updatedSubTask = subTask.copyWith(isCompleted: !subTask.isCompleted);
        final updatedSubTasks = [...task.subTasks];
        updatedSubTasks[subTaskIndex] = updatedSubTask;
        final updatedTask = task.copyWith(subTasks: updatedSubTasks);
        _tasks[taskIndex] = updatedTask;
        await _saveTasks();
        notifyListeners();
      }
    }
  }

  Future<void> resetAll() async {
    _tasks.clear();
    await _saveTasks();
    notifyListeners();
  }
}