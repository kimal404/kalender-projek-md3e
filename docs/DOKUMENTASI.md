# Dokumentasi Quest Kalender

Dokumen ini menjelaskan aplikasi, arsitektur, aturan permainan, data, build, dan batasan yang ada di kode saat ini.

## 1. Ringkasan

Quest Kalender adalah aplikasi Flutter untuk mencatat tugas harian sebagai quest RPG. Pengguna memilih tanggal, membuat misi, menandainya selesai, lalu karakter mendapat pengalaman, koin, dan kenaikan atribut.

| Item | Nilai |
| --- | --- |
| Nama paket Dart | `quest_kalender` |
| Versi | `1.0.0+1` |
| SDK Dart | `^3.13.4` |
| Application ID Android | `com.example.quest_kalender` |
| Label Android | `quest_kalender` |
| Platform yang ada di repo | Android dan Web |
| Bahasa UI | Indonesia (`id_ID`) |
| Penyimpanan | Lokal, `SharedPreferences` |
| Remote Git | https://github.com/senji830/kalender-projek |
| Branch | `master` |

Aplikasi tidak diterbitkan ke pub.dev (`publish_to: none`).

## 2. Yang dilihat pengguna

Alur buka aplikasi:

1. Web menampilkan splash HTML `#boot-splash` sampai frame Flutter pertama, paling lama 20 detik.
2. Android memakai warna latar `launch_background` tanpa gambar logo.
3. `SplashScreen` Flutter menampilkan lambang perisai, teks "QUEST KALENDER", dan progress sekitar 900 milidetik, lalu berpindah ke `HomeScreen`.
4. Pita debug Flutter dimatikan lewat `debugShowCheckedModeBanner: false`.

`HomeScreen` punya header karakter dan tiga tab:

| Tab | Isi |
| --- | --- |
| Kalender & Quest | Kontrak harian, kalender, filter kategori/rank, daftar quest tanggal terpilih, tombol quest baru |
| Status Karakter | Nama, gelar, level, statistik, empat atribut, tombol ubah nama |
| Papan Guild | Total, selesai, menunggu, sebaran rank, dan tombol periksa sinkronisasi |

Header menampilkan level, nama, gelar, streak, koin, dan bar EXP.

Quest kosong menampilkan ajakan menambah quest. Quest yang ada bisa ditandai selesai, diubah, atau dihapus. Hapus meminta konfirmasi.

## 3. Struktur kode

```text
lib/
  main.dart                         titik masuk, provider, locale
  domain/models/                    Quest, UserProfile, rank, kategori
  data/services/                    penyimpanan, notifikasi, stub sinkronisasi
  data/repositories/                cache dan akses quest
  ui/core/                          tema dan latar bintang
  ui/features/splash/               splash dalam aplikasi
  ui/features/home/                 dashboard dan dialog nama
  ui/features/calendar/             kalender
  ui/features/quests/               kartu, dialog, dan state quest
  ui/features/character/            state karakter dan dialog level up
test/                               tes widget dan aturan RPG
android/                            proyek Android
web/                                splash HTML, manifest, ikon web
```

Alur data:

```text
UI  ->  ViewModel  ->  Repository / Service  ->  SharedPreferences
                     ->  NotificationService ->  notifikasi perangkat
```

`main.dart` membuat satu `StorageService`, satu `QuestRepository`, satu `CharacterViewModel`, dan satu `QuestViewModel`. Keduanya di-`init()` sebelum `runApp`, lalu `HomeScreen` memanggil `init()` lagi. Pemanggilan kedua aman karena `_isReady` menghentikan pemuatan ulang.

## 4. Quest

Model ada di `lib/domain/models/quest_model.dart`.

Field: `id`, `title`, `description`, `date`, `startTime`, `endTime`, `rank`, `category`, `expReward`, `coinReward`, `isCompleted`, `completedAt`.

Jam disimpan sebagai teks `HH:mm`, bukan `DateTime`. ID baru dibuat dengan paket `uuid`.

### Rank dan hadiah bawaan

| Rank | Label | EXP | Koin |
| --- | --- | ---: | ---: |
| E | Novice | 25 | 5 |
| D | Apprentice | 50 | 10 |
| C | Adept | 100 | 25 |
| B | Expert | 200 | 50 |
| A | Master | 350 | 100 |
| S | Legendary | 500 | 200 |

Jika `expReward` atau `coinReward` tidak diisi, nilainya diambil dari rank. Rank yang tidak dikenal saat dibaca dari penyimpanan kembali menjadi D.

### Kategori

| Kode | Label | Atribut yang naik |
| --- | --- | --- |
| `strength` | Kekuatan | STR |
| `intellect` | Kecerdasan | INT |
| `discipline` | Disiplin | DIS |
| `vitality` | Kebugaran | VIT |

Kategori yang tidak dikenal kembali menjadi `discipline`.

Menyelesaikan quest memberi hadiah satu kali lewat `toggleQuestCompletion`. Membatalkan centang tidak menarik kembali EXP, koin, atribut, atau jumlah quest tuntas. Ini perilaku kode saat ini, bukan kelalaian dokumentasi.

Quest bawaan dibuat hanya jika penyimpanan quest masih kosong: satu quest disiplin yang sudah selesai, plus latihan, belajar, dan hidrasi untuk hari ini.

## 5. Karakter

Model ada di `lib/domain/models/user_profile_model.dart`.

Nilai awal: nama "Petualang", gelar "F-Rank Novice", level 1, EXP 0, koin 0, streak 1, dan semua atribut 1.

EXP maksimum level saat ini:

```text
maxExp = 100 + (level - 1) * 75
```

Level 1 butuh 100, level 2 butuh 175, level 3 butuh 250. Jika hadiah melebihi beberapa ambang, level bisa naik lebih dari satu kali. Sisa EXP dipertahankan.

| Level | Gelar |
| --- | --- |
| 1–4 | F-Rank Novice |
| 5–9 | D-Rank Scout |
| 10–14 | C-Rank Adventurer |
| 15–19 | B-Rank Veteran |
| 20–29 | A-Rank Vanguard |
| 30–39 | S-Rank Champion |
| 40–49 | Legendary Hero |
| 50+ | Mythic Grandmaster |

Naik level memanggil `onLevelUp`, yang membuka `LevelUpDialog`.

Streak dihitung saat profil dimuat:

- selisih 1 hari: streak bertambah 1;
- selisih lebih dari 1 hari: streak kembali ke 1;
- hari yang sama: tanggal aktif hanya diperbarui.

Nama diubah dari tab Status Karakter. Dialog `_EditNameDialog` memiliki controller sendiri dan menutupnya hanya setelah widget dialog dibuang. Nama kosong ditolak. Nama tersimpan lewat `CharacterViewModel.updateName`.

## 6. Kalender dan filter

`QuestViewModel` menyimpan tanggal terpilih, bulan tampilan, mode `month` / `week` / `day`, filter kategori, filter rank, dan teks pencarian.

Daftar di tab kalender hanya memuat quest pada tanggal terpilih, lalu menyaring kategori dan rank. Pencarian membandingkan judul dan deskripsi, tetapi belum ada kolom cari di UI.

Kontrak harian menghitung quest selesai dibagi total quest pada tanggal itu. Jika semua selesai, status berubah menjadi "KONTRAK HARIAN SELESAI".

## 7. Penyimpanan

`StorageService` memakai dua kunci:

| Kunci | Isi |
| --- | --- |
| `quest_kalender_quests_v1` | JSON daftar quest |
| `quest_kalender_profile_v1` | JSON satu profil |

Tanggal ditulis sebagai ISO-8601. JSON rusak tidak menjatuhkan aplikasi: quest kembali ke data bawaan, profil kembali ke karakter baru. Karena itu, mengubah nama field tanpa migrasi bisa terlihat seperti data hilang.

`QuestRepository` menyimpan salinan di memori setelah `init()`. Tambah, ubah, dan hapus langsung menulis ulang seluruh daftar.

## 8. Notifikasi

`NotificationService` adalah singleton. Inisialisasi dilakukan di `main()` sebelum UI.

- Channel Android: `quest_reminders` / "Pengingat Quest".
- Izin yang diminta: notifikasi, alarm presisi di Android, serta alert, badge, dan suara di iOS/macOS.
- Waktu gabungan dari tanggal quest dan `startTime` pada zona waktu perangkat.
- Quest tanpa jam, jam tidak valid, sudah lewat, atau sudah selesai tidak dijadwalkan.
- Mode utama `exactAllowWhileIdle`. Jika izin alarm presisi ditolak, jadwal diulang sebagai `inexactAllowWhileIdle`.
- ID notifikasi adalah `questId.hashCode` 31-bit positif.
- `init()` juga menjadwalkan ulang semua quest yang tersimpan.

Izin Android yang dideklarasikan: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, dan `SCHEDULE_EXACT_ALARM`.

## 9. Sinkronisasi

`AuthSyncService` hanya kontrak. `LocalAuthSyncService` meniru login lokal dan mengembalikan sukses setelah penundaan singkat. Tidak ada Firebase, Supabase, akun sungguhan, atau jaringan.

Tombol "Periksa Sinkronisasi" di Papan Guild tidak memanggil layanan itu. Tombol hanya menampilkan snackbar bahwa penyimpanan offline lokal aktif.

## 10. Tampilan

Tema gelap ada di `lib/ui/core/themes/app_theme.dart`.

| Token | Warna |
| --- | --- |
| `primaryGold` | `#FFB300` |
| `accentAmber` | `#FF8F00` |
| `darkBackground` | `#121420` |
| `cardBackground` | `#1E2235` |
| `surfaceLighter` | `#2B304A` |
| `textMuted` | `#9E9E9E` |
| `neonCyan` | `#00E5FF` |
| `neonPurple` | `#D500F9` |

`GuildBackdrop` menggambar gradasi, dua cahaya radial, dan 28 bintang. Angka bintang tetap karena memakai seed, bukan acak setiap frame.

Material 3 dipakai. Tidak ada font kustom atau aset gambar di `pubspec.yaml`; ikon UI berasal dari Material dan Cupertino.

## 11. Ketergantungan

Runtime:

| Paket | Peran |
| --- | --- |
| `provider` | state UI |
| `intl` | tanggal bahasa Indonesia |
| `shared_preferences` | penyimpanan lokal |
| `uuid` | ID quest |
| `flutter_local_notifications` | pengingat |
| `timezone` dan `flutter_timezone` | jadwal zona lokal |
| `cupertino_icons` | ikon iOS |

Dev: `flutter_test` dan `flutter_lints`.

Android memakai Java/Kotlin 17 dan core library desugaring `desugar_jdk_libs` 2.1.4. `minSdk`, `targetSdk`, dan `compileSdk` mengikuti nilai bawaan Flutter.

## 12. Membangun dan menjalankan

Dari akar repo:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter run -d chrome
flutter run -d <device-id>
flutter build apk --debug
```

Perangkat Android lewat USB harus mengizinkan debugging. Perintah perangkat:

```powershell
flutter devices
```

APK debug terakhir berada di `build/app/outputs/flutter-apk/app-debug.apk`. Folder `build/` tidak masuk Git.

Build rilis saat ini masih memakai signing config debug. Sebelum distribusi, application ID `com.example` dan kunci rilis perlu diganti.

## 13. Tes

`test/widget_test.dart` memastikan tiga label tab tampil.

`test/quest_rpg_test.dart` memeriksa:

- hadiah bawaan rank E dan S;
- serialisasi quest;
- rumus EXP level 1–3;
- kenaikan level saat EXP melebihi ambang.

Belum ada tes untuk dialog nama, notifikasi pada perangkat, kalender, atau pembatalan quest.

## 14. Git dan file yang diabaikan

`.gitignore` Flutter sudah mengabaikan:

- `.dart_tool/`, `.pub/`, `.pub-cache/`;
- `build/` dan `coverage/`;
- `.idea/`, `*.iml`;
- `.widget_preview/`;
- `.flutter-plugins-dependencies`;
- artefak debug, profile, dan release Android.

`android/.gitignore` juga mengabaikan `local.properties`, Gradle wrapper jar, dan keystore. Jangan menghapus aturan ini.

## 15. Batasan yang diketahui

- Ikon launcher Android dan ikon web masih ikon bawaan Flutter. Itu disengaja sampai ada permintaan menggantinya.
- Tidak ada folder iOS, Windows, Linux, atau macOS di repo meskipun Flutter dapat menambahkannya.
- Tidak ada akun cloud yang benar-benar tersambung.
- Membatalkan quest tidak mengembalikan hadiah.
- Pencarian quest ada di state, tetapi belum ditampilkan.
- Nama aplikasi di launcher Android masih `quest_kalender`, sedangkan judul Flutter adalah "Quest Kalender".
- Plugin `flutter_timezone` masih memakai Kotlin Gradle Plugin lama. Flutter memperingatkan bahwa versi mendatang dapat menolak build sampai plugin itu diperbarui.
- Kesalahan penyimpanan hanya dicatat dengan kembali ke data awal, tanpa laporan ke pengguna.

## 16. Riwayat perilaku penting

Dialog ubah nama sempat error karena `TextEditingController` dihancurkan saat dialog masih membongkar field-nya. Controller sekarang dimiliki `_EditNameDialog` dan dihancurkan di `dispose()`.
