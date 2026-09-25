import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quest_kalender/data/repositories/quest_repository.dart';
import 'package:quest_kalender/data/services/notification_service.dart';
import 'package:quest_kalender/data/services/storage_service.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';
import 'package:quest_kalender/ui/features/character/view_models/character_view_model.dart';
import 'package:quest_kalender/ui/features/quests/view_models/quest_view_model.dart';
import 'package:quest_kalender/ui/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  await NotificationService.instance.init();

  final storageService = StorageService();
  final questRepository = QuestRepository(storageService: storageService);
  final characterViewModel = CharacterViewModel(storageService: storageService);
  final questViewModel = QuestViewModel(
    repository: questRepository,
    characterViewModel: characterViewModel,
  );

  // Muat profil dulu supaya suara notifikasi sudah terpasang
  // sebelum quest dijadwalkan ulang.
  await characterViewModel.init();
  await questViewModel.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<QuestRepository>.value(value: questRepository),
        ChangeNotifierProvider<CharacterViewModel>.value(
          value: characterViewModel,
        ),
        ChangeNotifierProxyProvider<CharacterViewModel, QuestViewModel>(
          create: (_) => questViewModel,
          update: (context, charVM, questVM) {
            questVM ??= questViewModel;
            questVM.updateCharacterViewModel(charVM);
            return questVM;
          },
        ),
      ],
      child: const QuestKalenderApp(),
    ),
  );
}

class QuestKalenderApp extends StatelessWidget {
  const QuestKalenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quest Kalender',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
