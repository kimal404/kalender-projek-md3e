import 'package:flutter/material.dart';
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

    if (differenceInDays == 1) {
      // Login hari berikutnya berturut-turut
      _profile = _profile.copyWith(
        streakDays: _profile.streakDays + 1,
        lastActiveDate: now,
      );
      _storageService.saveProfile(_profile);
    } else if (differenceInDays > 1) {
      // Streak putus
      _profile = _profile.copyWith(streakDays: 1, lastActiveDate: now);
      _storageService.saveProfile(_profile);
    } else {
      // Masih di hari yang sama
      _profile = _profile.copyWith(lastActiveDate: now);
      _storageService.saveProfile(_profile);
    }
  }

  Future<void> addExpAndCoins({
    required int exp,
    required int coins,
    QuestCategory? category,
  }) async {
    int newExp = _profile.currentExp + exp;
    int newCoins = _profile.coins + coins;
    int currentLvl = _profile.level;
    bool leveledUp = false;

    // Stat atribut peningkatan sesuai kategori quest
    int newStr =
        _profile.strength + (category == QuestCategory.strength ? 1 : 0);
    int newInt =
        _profile.intellect + (category == QuestCategory.intellect ? 1 : 0);
    int newDis =
        _profile.discipline + (category == QuestCategory.discipline ? 1 : 0);
    int newVit =
        _profile.vitality + (category == QuestCategory.vitality ? 1 : 0);

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
      lastActiveDate: DateTime.now(),
    );

    await _storageService.saveProfile(_profile);
    notifyListeners();

    if (leveledUp && onLevelUp != null) {
      onLevelUp!(currentLvl, newTitle);
    }
  }

  Future<void> updateName(String newName) async {
    _profile = _profile.copyWith(name: newName);
    await _storageService.saveProfile(_profile);
    notifyListeners();
  }
}
