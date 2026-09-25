class UserProfile {
  final String name;
  final String title;
  final int level;
  final int currentExp;
  final int coins;
  final int streakDays;
  final DateTime lastActiveDate;
  final int strength;
  final int intellect;
  final int discipline;
  final int vitality;
  final int completedQuestsCount;

  /// ID avatar bawaan, misalnya `guardian`. Kosong jika memakai foto sendiri.
  final String avatarId;

  /// Path file foto yang dipilih pengguna di perangkat.
  final String? customAvatarPath;

  const UserProfile({
    this.name = 'Petualang',
    this.title = 'F-Rank Novice',
    this.level = 1,
    this.currentExp = 0,
    this.coins = 0,
    this.streakDays = 1,
    required this.lastActiveDate,
    this.strength = 1,
    this.intellect = 1,
    this.discipline = 1,
    this.vitality = 1,
    this.completedQuestsCount = 0,
    this.avatarId = 'guardian',
    this.customAvatarPath,
  });

  int get maxExp => calculateMaxExp(level);

  static int calculateMaxExp(int lvl) {
    return 100 + (lvl - 1) * 75;
  }

  static String getTitleForLevel(int lvl) {
    if (lvl >= 50) return 'Mythic Grandmaster';
    if (lvl >= 40) return 'Legendary Hero';
    if (lvl >= 30) return 'S-Rank Champion';
    if (lvl >= 20) return 'A-Rank Vanguard';
    if (lvl >= 15) return 'B-Rank Veteran';
    if (lvl >= 10) return 'C-Rank Adventurer';
    if (lvl >= 5) return 'D-Rank Scout';
    return 'F-Rank Novice';
  }

  UserProfile copyWith({
    String? name,
    String? title,
    int? level,
    int? currentExp,
    int? coins,
    int? streakDays,
    DateTime? lastActiveDate,
    int? strength,
    int? intellect,
    int? discipline,
    int? vitality,
    int? completedQuestsCount,
    String? avatarId,
    String? customAvatarPath,
    bool clearCustomAvatar = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      title: title ?? this.title,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      strength: strength ?? this.strength,
      intellect: intellect ?? this.intellect,
      discipline: discipline ?? this.discipline,
      vitality: vitality ?? this.vitality,
      completedQuestsCount: completedQuestsCount ?? this.completedQuestsCount,
      avatarId: avatarId ?? this.avatarId,
      customAvatarPath: clearCustomAvatar
          ? null
          : (customAvatarPath ?? this.customAvatarPath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'level': level,
      'currentExp': currentExp,
      'coins': coins,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'strength': strength,
      'intellect': intellect,
      'discipline': discipline,
      'vitality': vitality,
      'completedQuestsCount': completedQuestsCount,
      'avatarId': avatarId,
      'customAvatarPath': customAvatarPath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: (map['name'] as String?) ?? 'Petualang',
      title: (map['title'] as String?) ?? 'F-Rank Novice',
      level: (map['level'] as int?) ?? 1,
      currentExp: (map['currentExp'] as int?) ?? 0,
      coins: (map['coins'] as int?) ?? 0,
      streakDays: (map['streakDays'] as int?) ?? 1,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.parse(map['lastActiveDate'] as String)
          : DateTime.now(),
      strength: (map['strength'] as int?) ?? 1,
      intellect: (map['intellect'] as int?) ?? 1,
      discipline: (map['discipline'] as int?) ?? 1,
      vitality: (map['vitality'] as int?) ?? 1,
      completedQuestsCount: (map['completedQuestsCount'] as int?) ?? 0,
      avatarId: (map['avatarId'] as String?) ?? 'guardian',
      customAvatarPath: map['customAvatarPath'] as String?,
    );
  }
}
