import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/data/services/storage_service.dart';

class QuestRepository {
  final StorageService _storageService;
  List<Quest> _cachedQuests = [];
  bool _isInitialized = false;

  QuestRepository({StorageService? storageService})
    : _storageService = storageService ?? StorageService();

  Future<void> init() async {
    if (!_isInitialized) {
      _cachedQuests = await _storageService.loadQuests();
      _isInitialized = true;
    }
  }

  List<Quest> getAllQuests() {
    return List.unmodifiable(_cachedQuests);
  }

  List<Quest> getQuestsForDate(DateTime date) {
    return _cachedQuests.where((q) {
      return q.date.year == date.year &&
          q.date.month == date.month &&
          q.date.day == date.day;
    }).toList();
  }

  Map<DateTime, List<Quest>> getQuestsGroupedByDay(DateTime month) {
    final Map<DateTime, List<Quest>> map = {};
    for (final quest in _cachedQuests) {
      if (quest.date.year == month.year && quest.date.month == month.month) {
        final dayKey = DateTime(
          quest.date.year,
          quest.date.month,
          quest.date.day,
        );
        map.putIfAbsent(dayKey, () => []).add(quest);
      }
    }
    return map;
  }

  Future<void> addOrUpdateQuest(Quest quest) async {
    final index = _cachedQuests.indexWhere((q) => q.id == quest.id);
    if (index >= 0) {
      _cachedQuests[index] = quest;
    } else {
      _cachedQuests.add(quest);
    }
    await _storageService.saveQuests(_cachedQuests);
  }

  Future<void> deleteQuest(String id) async {
    _cachedQuests.removeWhere((q) => q.id == id);
    await _storageService.saveQuests(_cachedQuests);
  }

  Quest? getQuestById(String id) {
    try {
      return _cachedQuests.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}
