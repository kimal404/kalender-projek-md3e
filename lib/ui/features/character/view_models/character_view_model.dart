import 'package:flutter/material.dart';
import 'package:quest_kalender/data/services/notification_service.dart';
import 'package:quest_kalender/data/services/storage_service.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';

class CharacterViewModel extends ChangeNotifier {
  final StorageService _storageService;
  UserProfile _profile = UserProfile(lastActiveDate: DateTime.now());
  bool _isLoading = true;
  bool _isReady = false;

  // Callback untuk memicu dialog Level Up di UI
  void Function(int newLevel, String title)? onLevelUp;

  CharacterViewModel({StorageService? storageService})
    : _storageService = storageService ?? StorageService();

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    if (_isReady) return;
    _isLoading = true;
    notifyListeners();

    _profile = await _storageService.loadProfile();
    NotificationService.instance.setSound(_profile.notificationSoundId);
    _checkDailyStreak();
    _isReady = true;
    _isLoading = false;
    notifyListeners();
  }

  void _checkDailyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      _profile.lastActiveDate.year,
      _profile.lastActiveDate.month,
      _profile.lastActiveDate.day,
    );

    final differenceInDays = today.difference(lastActive).inDays;
    final currentDailyExp = _profile.dailyExpForDate(now);

    if (differenceInDays == 1) {
      // Login hari berikutnya berturut-turut
      _profile = _profile.copyWith(
        streakDays: _profile.streakDays + 1,
        dailyExpEarned: currentDailyExp,
        dailyExpDate: now,
        lastActiveDate: now,
      );
      _storageService.saveProfile(_profile);
    } else if (differenceInDays > 1) {
      // Streak putus
      _profile = _profile.copyWith(
        streakDays: 1,
        dailyExpEarned: currentDailyExp,
        dailyExpDate: now,
        lastActiveDate: now,
      );
      _storageService.saveProfile(_profile);
    } else {
      // Masih di hari yang sama
      _profile = _profile.copyWith(
        dailyExpEarned: currentDailyExp,
        dailyExpDate: now,
        lastActiveDate: now,
      );
      _storageService.saveProfile(_profile);
    }
  }

  /// Menambahkan EXP dengan batas harian [UserProfile.maxDailyExp].
  /// Mengembalikan jumlah EXP aktual yang berhasil ditambahkan.
  Future<int> addExpAndCoins({
    required int exp,
    int coins = 0,
    QuestCategory? category,
    DateTime? questDate,
  }) async {
    final now = DateTime.now();
    final targetDate = questDate ?? now;
    final earnedToday = _profile.dailyExpForDate(targetDate);
    final remainingCap =
        (UserProfile.maxDailyExp - earnedToday).clamp(0, UserProfile.maxDailyExp);
    final actualExpGranted = exp.clamp(0, remainingCap);

    int newExp = _profile.currentExp + actualExpGranted;
    int newCoins = _profile.coins + coins;
    int currentLvl = _profile.level;
    bool leveledUp = false;

    // Stat atribut peningkatan sesuai kategori quest (hanya jika masih dalam kuota EXP harian)
    final attrGain = actualExpGranted > 0 ? 1 : 0;
    int newStr =
        _profile.strength + (category == QuestCategory.strength ? attrGain : 0);
    int newInt =
        _profile.intellect + (category == QuestCategory.intellect ? attrGain : 0);
    int newDis =
        _profile.discipline + (category == QuestCategory.discipline ? attrGain : 0);
    int newVit =
        _profile.vitality + (category == QuestCategory.vitality ? attrGain : 0);

    // Kalkulasi kenaikan level (bisa naik lebih dari 1 level jika EXP besar)
    while (newExp >= UserProfile.calculateMaxExp(currentLvl)) {
      newExp -= UserProfile.calculateMaxExp(currentLvl);
      currentLvl += 1;
      leveledUp = true;
    }

    final newTitle = UserProfile.getTitleForLevel(currentLvl);

    _profile = _profile.copyWith(
      level: currentLvl,
      title: newTitle,
      currentExp: newExp,
      coins: newCoins,
      strength: newStr,
      intellect: newInt,
      discipline: newDis,
      vitality: newVit,
      completedQuestsCount: _profile.completedQuestsCount + 1,
      dailyExpEarned: earnedToday + actualExpGranted,
      dailyExpDate: targetDate,
      lastActiveDate: now,
    );

    await _storageService.saveProfile(_profile);
    notifyListeners();

    if (leveledUp && onLevelUp != null) {
      onLevelUp!(currentLvl, newTitle);
    }

    return actualExpGranted;
  }

  Future<void> updateName(String newName) async {
    _profile = _profile.copyWith(name: newName);
    await _storageService.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> updateAvatar({
    required String avatarId,
    String? customAvatarPath,
  }) async {
    _profile = _profile.copyWith(
      avatarId: avatarId,
      customAvatarPath: customAvatarPath,
      clearCustomAvatar: customAvatarPath == null,
    );
    await _storageService.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> updateNotificationSound(String soundId) async {
    _profile = _profile.copyWith(notificationSoundId: soundId);
    NotificationService.instance.setSound(soundId);
    await _storageService.saveProfile(_profile);
    notifyListeners();
  }
}
