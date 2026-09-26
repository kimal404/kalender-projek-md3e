import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest_kalender/data/repositories/quest_repository.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';
import 'package:quest_kalender/ui/features/quests/view_models/quest_view_model.dart';

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

    test('QuestViewModel memfilter daftar quest dengan setSearchQuery', () async {
      final repo = QuestRepository();
      final vm = QuestViewModel(repository: repo);
      final date = DateTime(2026, 9, 26);
      vm.selectDate(date);

      final q1 = Quest(
        id: 'q1',
        title: 'Membaca Buku Sejarah',
        description: 'Bab 1 dan 2',
        date: date,
        rank: QuestRank.e,
        category: QuestCategory.intellect,
      );
      final q2 = Quest(
        id: 'q2',
        title: 'Latihan Pushup',
        description: '3 set 15 repetisi',
        date: date,
        rank: QuestRank.d,
        category: QuestCategory.strength,
      );

      await vm.addQuest(q1);
      await vm.addQuest(q2);

      expect(vm.questsForSelectedDate.length, equals(2));

      vm.setSearchQuery('sejarah');
      expect(vm.questsForSelectedDate.length, equals(1));
      expect(vm.questsForSelectedDate.first.id, equals('q1'));

      vm.setSearchQuery('pushup');
      expect(vm.questsForSelectedDate.length, equals(1));
      expect(vm.questsForSelectedDate.first.id, equals('q2'));

      vm.setSearchQuery('tidak-ada');
      expect(vm.questsForSelectedDate.isEmpty, isTrue);

      vm.setSearchQuery('');
      expect(vm.questsForSelectedDate.length, equals(2));
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

    test('Avatar bawaan tersimpan dan foto sendiri bisa diganti', () async {
      final charVM = CharacterViewModel();
      expect(charVM.profile.avatarId, equals('guardian'));
      expect(charVM.profile.customAvatarPath, isNull);

      await charVM.updateAvatar(avatarId: 'mage');
      expect(charVM.profile.avatarId, equals('mage'));

      await charVM.updateAvatar(
        avatarId: 'mage',
        customAvatarPath: '/data/user_avatar.jpg',
      );
      expect(charVM.profile.customAvatarPath, equals('/data/user_avatar.jpg'));

      await charVM.updateAvatar(avatarId: 'knight');
      expect(charVM.profile.avatarId, equals('knight'));
      expect(charVM.profile.customAvatarPath, isNull);

      final restored = UserProfile.fromMap(charVM.profile.toMap());
      expect(restored.avatarId, equals('knight'));
    });

    test('Pilihan suara notifikasi tersimpan di profil', () async {
      final charVM = CharacterViewModel();
      expect(charVM.profile.notificationSoundId, equals('default'));

      await charVM.updateNotificationSound('chime');
      expect(charVM.profile.notificationSoundId, equals('chime'));

      final restored = UserProfile.fromMap(charVM.profile.toMap());
      expect(restored.notificationSoundId, equals('chime'));
    });

    test('Batas maksimal EXP harian (500 EXP/hari) tidak bisa dilewati', () async {
      final charVM = CharacterViewModel();
      final today = DateTime(2026, 9, 25);

      // Klaim pertama: 350 EXP -> berhasil penuh 350 EXP
      final granted1 = await charVM.addExpAndCoins(
        exp: 350,
        questDate: today,
      );
      expect(granted1, equals(350));
      expect(charVM.profile.dailyExpForDate(today), equals(350));

      // Klaim kedua di hari yang sama: minta 350 EXP -> dipotong sisa kuota 150 EXP (total 500 EXP)
      final granted2 = await charVM.addExpAndCoins(
        exp: 350,
        questDate: today,
      );
      expect(granted2, equals(150));
      expect(charVM.profile.dailyExpForDate(today), equals(500));

      // Klaim ketiga di hari yang sama: kuota habis -> 0 EXP
      final granted3 = await charVM.addExpAndCoins(
        exp: 100,
        questDate: today,
      );
      expect(granted3, equals(0));
      expect(charVM.profile.dailyExpForDate(today), equals(500));
    });

    test('Nama petualang default Petualang dan bisa diperbarui via updateName', () async {
      final charVM = CharacterViewModel();
      expect(charVM.profile.name, equals('Petualang'));
      expect(charVM.profile.completedQuestsCount, equals(0));

      await charVM.updateName('Arthur Pendragon');
      expect(charVM.profile.name, equals('Arthur Pendragon'));

      final restored = UserProfile.fromMap(charVM.profile.toMap());
      expect(restored.name, equals('Arthur Pendragon'));
    });
  });
}
