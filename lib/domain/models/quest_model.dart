import 'package:flutter/material.dart';

enum QuestRank {
  e('E', 'Novice', Color(0xFF9E9E9E), 25, 5),
  d('D', 'Apprentice', Color(0xFF4CAF50), 50, 10),
  c('C', 'Adept', Color(0xFF2196F3), 100, 25),
  b('B', 'Expert', Color(0xFF9C27B0), 200, 50),
  a('A', 'Master', Color(0xFFFF9800), 350, 100),
  s('S', 'Legendary', Color(0xFFE91E63), 500, 200);

  final String code;
  final String label;
  final Color color;
  final int defaultExp;
  final int defaultCoins;

  const QuestRank(
    this.code,
    this.label,
    this.color,
    this.defaultExp,
    this.defaultCoins,
  );

  static QuestRank fromCode(String code) {
    return QuestRank.values.firstWhere(
      (r) => r.code == code,
      orElse: () => QuestRank.d,
    );
  }
}

enum QuestCategory {
  strength('Kekuatan', Icons.fitness_center, Color(0xFFEF5350)),
  intellect('Kecerdasan', Icons.psychology, Color(0xFF42A5F5)),
  discipline('Disiplin', Icons.task_alt, Color(0xFFAB47BC)),
  vitality('Kebugaran', Icons.favorite, Color(0xFF66BB6A));

  final String label;
  final IconData icon;
  final Color color;

  const QuestCategory(this.label, this.icon, this.color);

  static QuestCategory fromName(String name) {
    return QuestCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => QuestCategory.discipline,
    );
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final QuestRank rank;
  final QuestCategory category;
  final int expReward;
  final int coinReward;
  final bool isCompleted;
  final bool expClaimed;
  final DateTime? completedAt;

  Quest({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.startTime,
    this.endTime,
    this.rank = QuestRank.d,
    this.category = QuestCategory.discipline,
    int? expReward,
    int? coinReward,
    this.isCompleted = false,
    bool? expClaimed,
    this.completedAt,
  }) : expReward = expReward ?? rank.defaultExp,
       coinReward = coinReward ?? rank.defaultCoins,
       expClaimed = expClaimed ?? isCompleted;

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    QuestRank? rank,
    QuestCategory? category,
    int? expReward,
    int? coinReward,
    bool? isCompleted,
    bool? expClaimed,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rank: rank ?? this.rank,
      category: category ?? this.category,
      expReward: expReward ?? this.expReward,
      coinReward: coinReward ?? this.coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
      expClaimed: expClaimed ?? this.expClaimed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'rank': rank.code,
      'category': category.name,
      'expReward': expReward,
      'coinReward': coinReward,
      'isCompleted': isCompleted,
      'expClaimed': expClaimed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    final completed = (map['isCompleted'] as bool?) ?? false;
    return Quest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      date: DateTime.parse(map['date'] as String),
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      rank: QuestRank.fromCode((map['rank'] as String?) ?? 'D'),
      category: QuestCategory.fromName(
        (map['category'] as String?) ?? 'discipline',
      ),
      expReward: map['expReward'] as int?,
      coinReward: map['coinReward'] as int?,
      isCompleted: completed,
      expClaimed: (map['expClaimed'] as bool?) ?? completed,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }
}
