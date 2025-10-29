import 'task_models.dart';

enum World { saludExtrema, dinamicasSociales, psicologiaExito }

enum Arc {
  despertar,
  entrenamiento,
  disciplina,
  sinergia,
  disolucion,
  sobradez,
  trascendencia
}

class NarrativeMission {
  final String id;
  final String title;
  final String description;
  final String principle;
  final Arc arc;
  final int phase; // 1-7
  final int order; // 1-30 por fase
  final Difficulty difficulty;
  final int xpReward;
  final int coinsReward;
  final List<String> tags;
  final bool isUnlocked;
  final bool isCompleted;
  final DateTime? completedAt;

  NarrativeMission({
    required this.id,
    required this.title,
    required this.description,
    required this.principle,
    required this.arc,
    required this.phase,
    required this.order,
    required this.difficulty,
    required this.xpReward,
    required this.coinsReward,
    this.tags = const [],
    this.isUnlocked = false,
    this.isCompleted = false,
    this.completedAt,
  });

  NarrativeMission copyWith({
    String? id,
    String? title,
    String? description,
    String? principle,
    Arc? arc,
    int? phase,
    int? order,
    Difficulty? difficulty,
    int? xpReward,
    int? coinsReward,
    List<String>? tags,
    bool? isUnlocked,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return NarrativeMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      principle: principle ?? this.principle,
      arc: arc ?? this.arc,
      phase: phase ?? this.phase,
      order: order ?? this.order,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      coinsReward: coinsReward ?? this.coinsReward,
      tags: tags ?? this.tags,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'principle': principle,
      'arc': arc.name,
      'phase': phase,
      'order': order,
      'difficulty': difficulty.name,
      'xpReward': xpReward,
      'coinsReward': coinsReward,
      'tags': tags,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory NarrativeMission.fromJson(Map<String, dynamic> json) {
    return NarrativeMission(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      principle: json['principle'],
      arc: Arc.values.firstWhere((a) => a.name == json['arc']),
      phase: json['phase'],
      order: json['order'],
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      xpReward: json['xpReward'],
      coinsReward: json['coinsReward'],
      tags: List<String>.from(json['tags'] ?? []),
      isUnlocked: json['isUnlocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> rewards;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.conditions,
    required this.rewards,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? rewards,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      conditions: conditions ?? this.conditions,
      rewards: rewards ?? this.rewards,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'conditions': conditions,
      'rewards': rewards,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      conditions: Map<String, dynamic>.from(json['conditions']),
      rewards: Map<String, dynamic>.from(json['rewards']),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }
}

class ProgressService {
  static int calculateXpRequired(int level) {
    return level * 50 + (level * level) * 10;
  }

  static int calculateXpReward(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 10;
      case Difficulty.hard:
        return 20;
      default:
        return 10;
    }
  }

  static int calculateCoinsReward(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 4;
      default:
        return 2;
    }
  }

  static bool shouldLevelUp(int currentXp, int currentLevel) {
    return currentXp >= calculateXpRequired(currentLevel);
  }

  static int getLevelFromXp(int xp) {
    int level = 1;
    while (xp >= calculateXpRequired(level)) {
      level++;
    }
    return level - 1;
  }
}