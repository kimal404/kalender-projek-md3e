import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest_kalender/data/repositories/quest_repository.dart';
import 'package:quest_kalender/data/services/storage_service.dart';
import 'package:quest_kalender/domain/models/user_profile_model.dart';
import 'package:quest_kalender/main.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';
import 'package:quest_kalender/ui/features/character/views/stat_radar_card.dart';
import 'package:quest_kalender/ui/features/quests/view_models/quest_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QuestKalenderApp renders properly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    final questRepository = QuestRepository(storageService: storageService);
    final charVM = CharacterViewModel(storageService: storageService);
    final questVM = QuestViewModel(
      repository: questRepository,
      characterViewModel: charVM,
    );

    await charVM.init();
    await questVM.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<QuestRepository>.value(value: questRepository),
          ChangeNotifierProvider<CharacterViewModel>.value(value: charVM),
          ChangeNotifierProvider<QuestViewModel>.value(value: questVM),
        ],
        child: const QuestKalenderApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Pastikan UI utama ter-render
    expect(find.text('Kalender & Quest'), findsOneWidget);
    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Papan Guild'), findsOneWidget);
  });

  testWidgets('Calendar mode switching animates between Bulan, Minggu, and Hari', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    final questRepository = QuestRepository(storageService: storageService);
    final charVM = CharacterViewModel(storageService: storageService);
    final questVM = QuestViewModel(
      repository: questRepository,
      characterViewModel: charVM,
    );

    await charVM.init();
    await charVM.updateName('Tester');
    await questVM.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<QuestRepository>.value(value: questRepository),
          ChangeNotifierProvider<CharacterViewModel>.value(value: charVM),
          ChangeNotifierProvider<QuestViewModel>.value(value: questVM),
        ],
        child: const QuestKalenderApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Mode awal adalah Bulan
    expect(questVM.calendarViewMode, equals('month'));

    // Tap 'Minggu'
    await tester.tap(find.text('Minggu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(questVM.calendarViewMode, equals('week'));

    // Tap 'Hari'
    await tester.tap(find.text('Hari'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(questVM.calendarViewMode, equals('day'));

    // Tap kembali ke 'Bulan'
    await tester.tap(find.text('Bulan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(questVM.calendarViewMode, equals('month'));
  });

  testWidgets('Welcome registration dialog appears on first launch and can be dismissed', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    final questRepository = QuestRepository(storageService: storageService);
    final charVM = CharacterViewModel(storageService: storageService);
    final questVM = QuestViewModel(
      repository: questRepository,
      characterViewModel: charVM,
    );

    await charVM.init();
    await questVM.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<QuestRepository>.value(value: questRepository),
          ChangeNotifierProvider<CharacterViewModel>.value(value: charVM),
          ChangeNotifierProvider<QuestViewModel>.value(value: questVM),
        ],
        child: const QuestKalenderApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran Guild'), findsOneWidget);
    expect(find.text('Nanti Saja'), findsOneWidget);

    await tester.tap(find.text('Nanti Saja'));
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran Guild'), findsNothing);
  });

  testWidgets('Dashboard switching animates smoothly between Kalender, Profil, and Papan Guild', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    final questRepository = QuestRepository(storageService: storageService);
    final charVM = CharacterViewModel(storageService: storageService);
    final questVM = QuestViewModel(
      repository: questRepository,
      characterViewModel: charVM,
    );

    await charVM.init();
    await charVM.updateName('Tester');
    await questVM.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<QuestRepository>.value(value: questRepository),
          ChangeNotifierProvider<CharacterViewModel>.value(value: charVM),
          ChangeNotifierProvider<QuestViewModel>.value(value: questVM),
        ],
        child: const QuestKalenderApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Pastikan dashboard awal adalah Kalender & Quest
    expect(find.text('Quest Baru'), findsOneWidget);
    expect(find.text('KONTRAK HARIAN GUILD'), findsOneWidget);

    // Ganti ke Dashboard Profil Saya
    await tester.tap(find.text('Profil Saya'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // animasi transisi berjalan
    await tester.pumpAndSettle();

    // Pastikan Dashboard Profil Saya aktif
    expect(find.text('DASHBOARD SAYA'), findsOneWidget);
    expect(find.text('Radar Poligon Gaya Hidup'), findsOneWidget);
    expect(find.text('Quest Tuntas'), findsOneWidget);
    expect(find.text('Quest Baru'), findsNothing); // FAB tidak ada di tab profil

    // Ganti ke Dashboard Papan Guild
    await tester.tap(find.text('Papan Guild'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // animasi transisi berjalan
    await tester.pumpAndSettle();

    // Pastikan Dashboard Papan Guild aktif
    expect(find.text('Ringkasan Guild Misi'), findsOneWidget);
    expect(find.text('Suara Pengingat'), findsOneWidget);

    // Ganti kembali ke Dashboard Kalender & Quest
    await tester.tap(find.text('Kalender & Quest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // animasi transisi berjalan
    await tester.pumpAndSettle();

    // Pastikan kembali ke Dashboard Kalender & Quest dengan FAB aktif
    expect(find.text('Quest Baru'), findsOneWidget);
    expect(find.text('KONTRAK HARIAN GUILD'), findsOneWidget);
  });

  testWidgets('StatRadarCard renders properly with polygon, mini chips, and archetype advice', (WidgetTester tester) async {
    final profile = UserProfile(
      lastActiveDate: DateTime(2026, 9, 25),
      strength: 15,
      intellect: 3,
      discipline: 3,
      vitality: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatRadarCard(profile: profile),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('KESEIMBANGAN KARAKTER'), findsOneWidget);
    expect(find.text('Radar Poligon Gaya Hidup'), findsOneWidget);
    expect(find.text('Tipe: Spesialis Fisik (Vanguard / Berserker)'), findsOneWidget);
    expect(find.text('STR'), findsWidgets);
    expect(find.text('INT'), findsWidgets);
    expect(find.text('DIS'), findsWidgets);
    expect(find.text('VIT'), findsWidgets);
    expect(find.text('15 Pts'), findsOneWidget);
    expect(find.text('3 Pts'), findsNWidgets(3));
  });
}

