import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:quest_kalender/domain/models/notification_sound.dart';
import 'package:quest_kalender/domain/models/quest_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Menjadwalkan pengingat quest ke notifikasi perangkat.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String channelName = 'Pengingat Quest';
  static const String channelDescription =
      'Notifikasi saat waktu mulai quest tiba';

  static const MethodChannel _soundChannel = MethodChannel(
    'quest_kalender/sound',
  );

  String _soundId = 'default';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (error) {
      debugPrint('Zona waktu perangkat tidak terbaca: $error');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);
    await _createAndroidChannels();
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    for (final sound in NotificationSounds.options) {
      final AndroidNotificationSound? androidSound = sound.id == 'silent'
          ? null
          : sound.rawResource == null
          ? null
          : RawResourceAndroidNotificationSound(sound.rawResource!);

      final channel = AndroidNotificationChannel(
        NotificationSounds.channelIdFor(sound.id),
        '$channelName · ${sound.label}',
        description: channelDescription,
        importance: Importance.high,
        playSound: sound.id != 'silent',
        sound: androidSound,
      );
      await android.createNotificationChannel(channel);
    }
  }

  void setSound(String soundId) {
    _soundId = NotificationSounds.byId(soundId).id;
  }

  Future<void> previewCurrentSound([String? soundIdOverride]) async {
    final sound = NotificationSounds.byId(soundIdOverride ?? _soundId);
    if (sound.id == 'silent') {
      try {
        await _soundChannel.invokeMethod('stopPreview');
      } catch (_) {}
      return;
    }

    // 1. Putar langsung di dalam aplikasi via native MediaPlayer agar selalu terdengar
    try {
      await _soundChannel.invokeMethod('playPreview', {'soundId': sound.id});
      return;
    } catch (error) {
      debugPrint('Fallback ke notifikasi sistem untuk contoh suara: $error');
    }

    // 2. Fallback untuk non-Android
    if (!_initialized) return;
    final details = _detailsFor(sound);
    try {
      await _plugin.show(
        id: 91001,
        title: 'Contoh suara quest',
        body: sound.label,
        notificationDetails: details,
      );
    } catch (error) {
      debugPrint('Gagal memutar contoh suara: $error');
    }
  }

  NotificationDetails _detailsFor(NotificationSoundOption sound) {
    final AndroidNotificationSound? androidSound = sound.id == 'silent'
        ? null
        : sound.rawResource == null
        ? null
        : RawResourceAndroidNotificationSound(sound.rawResource!);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationSounds.channelIdFor(sound.id),
        '$channelName · ${sound.label}',
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: sound.id != 'silent',
        sound: androidSound,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: sound.id != 'silent',
        sound: sound.rawResource == null ? null : '${sound.rawResource}.wav',
      ),
      macOS: DarwinNotificationDetails(
        presentSound: sound.id != 'silent',
        sound: sound.rawResource == null ? null : '${sound.rawResource}.wav',
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macos?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Jadwalkan ulang pengingat untuk satu quest.
  /// Quest selesai, tanpa jam mulai, atau yang waktunya sudah lewat dibatalkan.
  Future<void> syncQuest(Quest quest) async {
    if (!_initialized) return;

    await cancelQuest(quest.id);
    if (quest.isCompleted) return;

    final when = scheduledDateFor(quest);
    if (when == null) return;

    final now = tz.TZDateTime.now(tz.local);
    if (!when.isAfter(now)) return;

    final id = notificationIdFor(quest.id);
    final timeLabel = quest.startTime ?? '';
    final rankLabel = 'Rank ${quest.rank.code}';
    final body = quest.description.trim().isEmpty
        ? 'Waktunya memulai misi $rankLabel · $timeLabel'
        : quest.description.trim();

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: 'Quest dimulai: ${quest.title}',
        body: body,
        scheduledDate: when,
        notificationDetails: _detailsFor(NotificationSounds.byId(_soundId)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: quest.id,
      );
    } on PlatformException catch (error) {
      if (error.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          id: id,
          title: 'Quest dimulai: ${quest.title}',
          body: body,
          scheduledDate: when,
          notificationDetails: _detailsFor(NotificationSounds.byId(_soundId)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: quest.id,
        );
      } else {
        debugPrint('Gagal menjadwalkan pengingat quest: $error');
      }
    } catch (error) {
      debugPrint('Gagal menjadwalkan pengingat quest: $error');
    }
  }

  Future<void> cancelQuest(String questId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: notificationIdFor(questId));
  }

  Future<void> syncAll(Iterable<Quest> quests) async {
    if (!_initialized) return;
    for (final quest in quests) {
      await syncQuest(quest);
    }
  }

  /// ID notifikasi stabil dari UUID quest (31-bit positif).
  @visibleForTesting
  static int notificationIdFor(String questId) {
    return questId.hashCode & 0x7fffffff;
  }

  /// Gabungkan tanggal quest dengan jam mulai (`HH:mm`) di zona waktu lokal.
  @visibleForTesting
  static tz.TZDateTime? scheduledDateFor(Quest quest) {
    final start = quest.startTime;
    if (start == null || start.trim().isEmpty) return null;

    final parts = start.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return tz.TZDateTime(
      tz.local,
      quest.date.year,
      quest.date.month,
      quest.date.day,
      hour,
      minute,
    );
  }

  /// Dipakai tes agar layanan tidak menyentuh plugin native.
  @visibleForTesting
  bool get isInitialized => _initialized;
}
