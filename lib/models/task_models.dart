enum Difficulty { easy, medium, hard }

enum RepeatType { daily, weekly, monthly }

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
    );
  }
}