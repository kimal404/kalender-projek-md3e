import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';

class StorageService {
  static const String _questsKey = 'quest_kalender_quests_v1';
  static const String _profileKey = 'quest_kalender_profile_v1';

  Future<List<Quest>> loadQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_questsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return _getInitialDefaultQuests();
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => Quest.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getInitialDefaultQuests();
    }
  }

  Future<void> saveQuests(List<Quest> quests) async {
    final prefs = await SharedPreferences.getInstance();
    final list = quests.map((q) => q.toMap()).toList();
    await prefs.setString(_questsKey, jsonEncode(list));
  }

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);
    if (jsonString == null || jsonString.isEmpty) {
      return UserProfile(lastActiveDate: DateTime.now());
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return UserProfile.fromMap(decoded);
    } catch (e) {
      return UserProfile(lastActiveDate: DateTime.now());
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  List<Quest> _getInitialDefaultQuests() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      Quest(
        id: 'init-1',
        title: 'Mulai Petualangan Kalender',
        description: 'Buka aplikasi Quest Kalender dan jelajahi fitur jadwal!',
        date: today,
        startTime: '08:00',
        endTime: '08:30',
        rank: QuestRank.e,
        category: QuestCategory.discipline,
        isCompleted: true,
        completedAt: now,
      ),
      Quest(
        id: 'init-2',
        title: 'Latihan Fisik Pagi (Workout)',
        description: 'Push-up 20x, sit-up 20x, atau jogging ringan 15 menit.',
        date: today,
        startTime: '09:00',
        endTime: '09:45',
        rank: QuestRank.d,
        category: QuestCategory.strength,
      ),
      Quest(
        id: 'init-3',
        title: 'Membaca Buku / Belajar Skill Baru',
        description:
            'Fokus belajar minimal 30 menit tanpa gangguan smartphone.',
        date: today,
        startTime: '14:00',
        endTime: '15:00',
        rank: QuestRank.c,
        category: QuestCategory.intellect,
      ),
      Quest(
        id: 'init-4',
        title: 'Minum 2 Liter Air & Istirahat Cukup',
        description: 'Jaga hidrasi tubuh dan tidur tepat waktu malam ini.',
        date: today,
        startTime: '21:00',
        endTime: '22:00',
        rank: QuestRank.d,
        category: QuestCategory.vitality,
      ),
    ];
  }
}
