// ignore_for_file: prefer_initializing_formals
import 'package:flutter/material.dart';
import 'package:quest_kalender/data/repositories/quest_repository.dart';
import 'package:quest_kalender/data/services/notification_service.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';

class QuestViewModel extends ChangeNotifier {
  final QuestRepository _repository;
  CharacterViewModel? _characterViewModel;

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _calendarViewMode = 'month'; // 'month', 'week', 'day'
  QuestCategory? _selectedCategory;
  QuestRank? _selectedRank;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isReady = false;

  final NotificationService _notifications;

  QuestViewModel({
    required QuestRepository repository,
    CharacterViewModel? characterViewModel,
    NotificationService? notificationService,
  }) : _repository = repository,
       _characterViewModel = characterViewModel,
       _notifications = notificationService ?? NotificationService.instance;

  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  String get calendarViewMode => _calendarViewMode;
  QuestCategory? get selectedCategory => _selectedCategory;
  QuestRank? get selectedRank => _selectedRank;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  void updateCharacterViewModel(CharacterViewModel characterViewModel) {
    _characterViewModel = characterViewModel;
  }

  Future<void> init() async {
    if (_isReady) return;
    _isLoading = true;
    notifyListeners();

    await _repository.init();
    await _notifications.syncAll(_repository.getAllQuests());
    _isReady = true;
    _isLoading = false;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    if (_selectedDate.year != _currentMonth.year ||
        _selectedDate.month != _currentMonth.month) {
      _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    }
    notifyListeners();
  }

  void setCalendarViewMode(String mode) {
    _calendarViewMode = mode;
    notifyListeners();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    notifyListeners();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    notifyListeners();
  }

  void setCategoryFilter(QuestCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setRankFilter(QuestRank? rank) {
    _selectedRank = rank;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Quest> get questsForSelectedDate {
    return _repository.getQuestsForDate(_selectedDate).where((quest) {
      if (_selectedCategory != null && quest.category != _selectedCategory) {
        return false;
      }
      if (_selectedRank != null && quest.rank != _selectedRank) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = quest.title.toLowerCase().contains(query);
        final matchesDesc = quest.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }
      return true;
    }).toList();
  }

  List<Quest> getQuestsForDate(DateTime date) {
    return _repository.getQuestsForDate(date);
  }

  List<Quest> getAllQuests() {
    return _repository.getAllQuests();
  }

  Future<void> addQuest(Quest quest) async {
    await _repository.addOrUpdateQuest(quest);
    await _notifications.syncQuest(quest);
    notifyListeners();
  }

  Future<void> updateQuest(Quest quest) async {
    await _repository.addOrUpdateQuest(quest);
    await _notifications.syncQuest(quest);
    notifyListeners();
  }

  Future<void> deleteQuest(String id) async {
    await _repository.deleteQuest(id);
    await _notifications.cancelQuest(id);
    notifyListeners();
  }

  Future<void> toggleQuestCompletion(Quest quest) async {
    final bool newCompletionStatus = !quest.isCompleted;
    final updatedQuest = quest.copyWith(
      isCompleted: newCompletionStatus,
      completedAt: newCompletionStatus ? DateTime.now() : null,
    );

    await _repository.addOrUpdateQuest(updatedQuest);
    await _notifications.syncQuest(updatedQuest);

    if (newCompletionStatus && _characterViewModel != null) {
      await _characterViewModel!.addExpAndCoins(
        exp: quest.expReward,
        coins: quest.coinReward,
        category: quest.category,
      );
    }

    notifyListeners();
  }
}
