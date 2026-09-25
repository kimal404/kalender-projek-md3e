// ignore_for_file: prefer_initializing_formals
import 'package:flutter/material.dart';
import 'package:quest_kalender/data/repositories/quest_repository.dart';
import 'package:quest_kalender/data/services/notification_service.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
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

  Future<void> rescheduleNotifications() async {
    await _notifications.syncAll(_repository.getAllQuests());
  }

  Future<void> deleteQuest(String id) async {
    await _repository.deleteQuest(id);
    await _notifications.cancelQuest(id);
    notifyListeners();
  }

  /// Total EXP yang sudah diklaim pada tanggal [date].
  int getEarnedDailyExpForDate(DateTime date) {
    final completedQuestsExp = _repository
        .getQuestsForDate(date)
        .where((q) => q.isCompleted || q.expClaimed)
        .fold<int>(0, (sum, q) => sum + q.expReward);

    final profileDailyExp =
        _characterViewModel?.profile.dailyExpForDate(date) ?? 0;

    final rawMax = completedQuestsExp > profileDailyExp
        ? completedQuestsExp
        : profileDailyExp;
    return rawMax.clamp(0, UserProfile.maxDailyExp);
  }

  /// Total EXP dari seluruh quest (baik yang sudah diklaim maupun yang masih terjadwal) pada [date].
  int getTotalCommittedExpForDate(DateTime date, {String? excludeQuestId}) {
    final earnedExp = getEarnedDailyExpForDate(date);
    final pendingExp = _repository
        .getQuestsForDate(date)
        .where((q) => !q.isCompleted && !q.expClaimed && q.id != excludeQuestId)
        .fold<int>(0, (sum, q) => sum + q.expReward);

    return (earnedExp + pendingExp).clamp(0, UserProfile.maxDailyExp);
  }

  /// Sisa kuota EXP harian yang tersedia untuk membuat/mengklaim quest pada [date].
  int getRemainingExpQuotaForDate(DateTime date, {String? excludeQuestId}) {
    final committed = getTotalCommittedExpForDate(
      date,
      excludeQuestId: excludeQuestId,
    );
    return (UserProfile.maxDailyExp - committed).clamp(
      0,
      UserProfile.maxDailyExp,
    );
  }

  /// Menyelesaikan quest (1 kali pakai, tidak bisa di-uncheck lagi).
  Future<QuestCompletionResult> toggleQuestCompletion(Quest quest) async {
    // Tugas hanya bisa 1 kali pakai: jika sudah selesai / sudah klaim EXP, kunci!
    if (quest.isCompleted || quest.expClaimed) {
      return const QuestCompletionResult(
        status: QuestCompletionStatus.alreadyCompleted,
        expGranted: 0,
      );
    }

    // Cek sisa limit EXP harian berdasarkan quest yang sudah diklaim pada tanggal tersebut
    final earnedOnDate = getEarnedDailyExpForDate(quest.date);
    final remainingForDate = (UserProfile.maxDailyExp - earnedOnDate).clamp(
      0,
      UserProfile.maxDailyExp,
    );
    final cappedExp = quest.expReward.clamp(0, remainingForDate);

    int grantedExp = cappedExp;
    if (_characterViewModel != null) {
      grantedExp = await _characterViewModel!.addExpAndCoins(
        exp: cappedExp,
        coins: 0,
        category: quest.category,
        questDate: quest.date,
      );
    }

    final updatedQuest = quest.copyWith(
      isCompleted: true,
      expClaimed: true,
      expReward: grantedExp,
      completedAt: DateTime.now(),
    );

    await _repository.addOrUpdateQuest(updatedQuest);
    await _notifications.syncQuest(updatedQuest);

    notifyListeners();

    return QuestCompletionResult(
      status: grantedExp > 0
          ? QuestCompletionStatus.completed
          : QuestCompletionStatus.dailyLimitReached,
      expGranted: grantedExp,
    );
  }
}

enum QuestCompletionStatus {
  completed,
  alreadyCompleted,
  dailyLimitReached,
}

class QuestCompletionResult {
  final QuestCompletionStatus status;
  final int expGranted;

  const QuestCompletionResult({
    required this.status,
    required this.expGranted,
  });
}
