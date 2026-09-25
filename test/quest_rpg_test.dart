import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Quest and Rank Tests', () {
    test('Default rewards match Rank specification', () {
      final questE = Quest(
        id: '1',
        title: 'Misi E',
        date: DateTime(2026, 9, 23),
        rank: QuestRank.e,
      );
      expect(questE.expReward, equals(25));
      expect(questE.coinReward, equals(5));

      final questS = Quest(
        id: '2',
        title: 'Misi S',
        date: DateTime(2026, 9, 23),
        rank: QuestRank.s,
      );
      expect(questS.expReward, equals(500));
      expect(questS.coinReward, equals(200));
    });

    test('Serialization toMap and fromMap works correctly', () {
      final now = DateTime(2026, 9, 23, 10, 0);
      final quest = Quest(
        id: 'test-123',
        title: 'Lari Pagi',
        description: '5 KM di taman',
        date: now,
        startTime: '06:00',
        endTime: '07:00',
        rank: QuestRank.b,
        category: QuestCategory.strength,
        isCompleted: true,
        completedAt: now,
      );

      final map = quest.toMap();
      final restored = Quest.fromMap(map);

      expect(restored.id, equals('test-123'));
      expect(restored.title, equals('Lari Pagi'));
      expect(restored.rank, equals(QuestRank.b));
      expect(restored.category, equals(QuestCategory.strength));
      expect(restored.isCompleted, isTrue);
    });
  });

  group('UserProfile and Level Up Tests', () {
    test('Level maxExp scales with level', () {
      expect(UserProfile.calculateMaxExp(1), equals(100));
      expect(UserProfile.calculateMaxExp(2), equals(175));
      expect(UserProfile.calculateMaxExp(3), equals(250));
    });

    test('CharacterViewModel awards EXP and handles Level Up', () async {
      final charVM = CharacterViewModel();
      bool levelUpTriggered = false;
      int reachedLevel = 1;

      charVM.onLevelUp = (lvl, title) {
        levelUpTriggered = true;
        reachedLevel = lvl;
      };

      // Awal: Level 1, 0 EXP, butuh 100 EXP untuk Level 2
      expect(charVM.profile.level, equals(1));
      expect(charVM.profile.currentExp, equals(0));

      // Tambah 125 EXP (akan naik ke Level 2 dengan sisa 25 EXP)
      await charVM.addExpAndCoins(
        exp: 125,
        coins: 50,
        category: QuestCategory.intellect,
      );

      expect(levelUpTriggered, isTrue);
      expect(reachedLevel, equals(2));
      expect(charVM.profile.level, equals(2));
      expect(charVM.profile.currentExp, equals(25));
      expect(charVM.profile.coins, equals(50));
      expect(charVM.profile.intellect, equals(2)); // INT meningkat
    });
  });
}
