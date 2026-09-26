import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest_kalender/data/repositories/quest_repository.dart';
import 'package:quest_kalender/data/services/storage_service.dart';
import 'package:quest_kalender/main.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';
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
}
