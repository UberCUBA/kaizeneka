import 'package:flutter/material.dart';

enum Difficulty { easy, medium, hard }

enum RepeatType { daily, weekly, monthly }

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum HabitGoalType { deactivate, duration, repeat }

enum HabitEndType { deactivated, date, days }

enum HabitIcon {
  fitness_center,
  directions_run,
  pool,
  self_improvement,
  directions_bike,
  music_note,
  palette,
  restaurant,
  local_florist,
  camera_alt,
  edit,
  book,
  work,
  people,
  health_and_safety,
  check_circle,
}

class SubTask {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime? dueDate;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? notes;
  final Difficulty difficulty;
  final DateTime startDate;
  final RepeatType? repeatType;
  bool isCompleted;
  final List<SubTask> subTasks;
  final DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.notes,
    required this.difficulty,
    required this.startDate,
    this.repeatType,
    this.isCompleted = false,
    this.subTasks = const [],
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    Difficulty? difficulty,
    DateTime? startDate,
    RepeatType? repeatType,
    bool? isCompleted,
    List<SubTask>? subTasks,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      difficulty: difficulty ?? this.difficulty,
      startDate: startDate ?? this.startDate,
      repeatType: repeatType ?? this.repeatType,
      isCompleted: isCompleted ?? this.isCompleted,
      subTasks: subTasks ?? this.subTasks,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'difficulty': difficulty.name,
      'startDate': startDate.toIso8601String(),
      'repeatType': repeatType?.name,
      'isCompleted': isCompleted,
      'subTasks': subTasks.map((sub) => sub.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.parse(json['startDate']),
      repeatType: json['repeatType'] != null
          ? RepeatType.values.firstWhere(
              (r) => r.name == json['repeatType'],
              orElse: () => RepeatType.daily,
            )
          : null,
      isCompleted: json['isCompleted'] ?? false,
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((sub) => SubTask.fromJson(sub))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

class SubMission {
  final String id;
  final String title;
  bool isCompleted;
  final int? points;
  final DateTime? dueDate;

  SubMission({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.points,
    this.dueDate,
  });

  SubMission copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? points,
    DateTime? dueDate,
  }) {
    return SubMission(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      points: points ?? this.points,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'points': points,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory SubMission.fromJson(Map<String, dynamic> json) {
    return SubMission(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      points: json['points'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}

class Mission {
  final String id;
  final String title;
  final String? notes;
  final Difficulty difficulty;
  final DateTime startDate;
  final RepeatType? repeatType;
  bool isCompleted;
  final List<SubMission> subMissions;
  final int points;
  final DateTime createdAt;
  DateTime? completedAt;
  final bool isSystemMission; // true = NK (sistema), false = Personal (usuario)

  Mission({
    required this.id,
    required this.title,
    this.notes,
    required this.difficulty,
    required this.startDate,
    this.repeatType,
    this.isCompleted = false,
    this.subMissions = const [],
    required this.points,
    DateTime? createdAt,
    this.completedAt,
    this.isSystemMission = false, // Por defecto son misiones personales
  }) : createdAt = createdAt ?? DateTime.now();

  Mission copyWith({
    String? id,
    String? title,
    String? notes,
    Difficulty? difficulty,
    DateTime? startDate,
    RepeatType? repeatType,
    bool? isCompleted,
    List<SubMission>? subMissions,
    int? points,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isSystemMission,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      difficulty: difficulty ?? this.difficulty,
      startDate: startDate ?? this.startDate,
      repeatType: repeatType ?? this.repeatType,
      isCompleted: isCompleted ?? this.isCompleted,
      subMissions: subMissions ?? this.subMissions,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isSystemMission: isSystemMission ?? this.isSystemMission,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'difficulty': difficulty.name,
      'startDate': startDate.toIso8601String(),
      'repeatType': repeatType?.name,
      'isCompleted': isCompleted,
      'subMissions': subMissions.map((sub) => sub.toJson()).toList(),
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isSystemMission': isSystemMission,
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.parse(json['startDate']),
      repeatType: json['repeatType'] != null
          ? RepeatType.values.firstWhere(
              (r) => r.name == json['repeatType'],
              orElse: () => RepeatType.daily,
            )
          : null,
      isCompleted: json['isCompleted'] ?? false,
      subMissions: (json['subMissions'] as List<dynamic>?)
              ?.map((sub) => SubMission.fromJson(sub))
              .toList() ??
          [],
      points: json['points'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isSystemMission: json['isSystemMission'] ?? false,
    );
  }
}

class Habit {
  final String id;
  final String title;
  final String? notes;
  final Difficulty difficulty;
  final DateTime startDate;
  final RepeatType repeatType;
  final List<DateTime> completedDates;
  final int streak;
  final int bestStreak;
  final DateTime createdAt;
  final HabitIcon icon;
  final HabitGoalType goalType;
  final int? targetDuration; // in minutes, for duration goals
  final int? targetRepetitions; // for repeat goals
  final bool reminderEnabled;
  final TimeOfDay? reminderTime;
  final String? reminderDescription;
  final HabitEndType endType;
  final DateTime? endDate;
  final int? endDays;
  final List<WeekDay> selectedDays; // for daily habits, which days of the week

  Habit({
    required this.id,
    required this.title,
    this.notes,
    required this.difficulty,
    required this.startDate,
    required this.repeatType,
    this.completedDates = const [],
    this.streak = 0,
    this.bestStreak = 0,
    DateTime? createdAt,
    this.icon = HabitIcon.check_circle,
    this.goalType = HabitGoalType.deactivate,
    this.targetDuration,
    this.targetRepetitions,
    this.reminderEnabled = false,
    this.reminderTime,
    this.reminderDescription,
    this.endType = HabitEndType.deactivated,
    this.endDate,
    this.endDays,
    this.selectedDays = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  Habit copyWith({
    String? id,
    String? title,
    String? notes,
    Difficulty? difficulty,
    DateTime? startDate,
    RepeatType? repeatType,
    List<DateTime>? completedDates,
    int? streak,
    int? bestStreak,
    DateTime? createdAt,
    HabitIcon? icon,
    HabitGoalType? goalType,
    int? targetDuration,
    int? targetRepetitions,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
    String? reminderDescription,
    HabitEndType? endType,
    DateTime? endDate,
    int? endDays,
    List<WeekDay>? selectedDays,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      difficulty: difficulty ?? this.difficulty,
      startDate: startDate ?? this.startDate,
      repeatType: repeatType ?? this.repeatType,
      completedDates: completedDates ?? this.completedDates,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      goalType: goalType ?? this.goalType,
      targetDuration: targetDuration ?? this.targetDuration,
      targetRepetitions: targetRepetitions ?? this.targetRepetitions,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDescription: reminderDescription ?? this.reminderDescription,
      endType: endType ?? this.endType,
      endDate: endDate ?? this.endDate,
      endDays: endDays ?? this.endDays,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'difficulty': difficulty.name,
      'startDate': startDate.toIso8601String(),
      'repeatType': repeatType.name,
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
      'streak': streak,
      'bestStreak': bestStreak,
      'createdAt': createdAt.toIso8601String(),
      'icon': icon.name,
      'goalType': goalType.name,
      'targetDuration': targetDuration,
      'targetRepetitions': targetRepetitions,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime != null ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute} : null,
      'reminderDescription': reminderDescription,
      'endType': endType.name,
      'endDate': endDate?.toIso8601String(),
      'endDays': endDays,
      'selectedDays': selectedDays.map((day) => day.name).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      startDate: DateTime.parse(json['startDate']),
      repeatType: RepeatType.values.firstWhere(
        (r) => r.name == json['repeatType'],
        orElse: () => RepeatType.daily,
      ),
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
      streak: json['streak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      icon: HabitIcon.values.firstWhere(
        (i) => i.name == json['icon'],
        orElse: () => HabitIcon.check_circle,
      ),
      goalType: HabitGoalType.values.firstWhere(
        (g) => g.name == json['goalType'],
        orElse: () => HabitGoalType.deactivate,
      ),
      targetDuration: json['targetDuration'],
      targetRepetitions: json['targetRepetitions'],
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(hour: json['reminderTime']['hour'], minute: json['reminderTime']['minute'])
          : null,
      reminderDescription: json['reminderDescription'],
      endType: HabitEndType.values.firstWhere(
        (e) => e.name == json['endType'],
        orElse: () => HabitEndType.deactivated,
      ),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      endDays: json['endDays'],
      selectedDays: (json['selectedDays'] as List<dynamic>?)
              ?.map((day) => WeekDay.values.firstWhere(
                    (d) => d.name == day,
                    orElse: () => WeekDay.monday,
                  ))
              .toList() ??
          [],
    );
  }
}