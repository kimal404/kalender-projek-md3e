# Dokumentasi Quest Kalender

Dokumen ini menjelaskan aplikasi, arsitektur, aturan permainan, penyimpanan data, audio/notifikasi, animasi UI, proses build, dan batasan yang ada di kode saat ini.

## 1. Ringkasan

**Quest Kalender** adalah aplikasi Flutter untuk mencatat jadwal dan tugas harian sebagai misi (*quest*) bergaya RPG. Pengguna memilih tanggal, menerbitkan quest dengan tingkat kesulitan (*Rank*) dan kategori atribut, lalu menandainya selesai untuk memperoleh **EXP**, menaikkan **Level & Gelar**, meningkatkan **Atribut Karakter (`STR`, `INT`, `DIS`, `VIT`)**, serta mempertahankan **Streak Harian**.

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

## 2. Yang Dilihat Pengguna

Alur buka aplikasi:

1. Web menampilkan splash HTML `#boot-splash` sampai frame Flutter pertama selesai dimuat.
2. Android memakai warna latar `launch_background`.
3. `SplashScreen` Flutter menampilkan lambang perisai dengan animasi *elastic scale*, efek kilau (*shimmer*), teks **"QUEST KALENDER"**, dan bilah progres halus, lalu berpindah ke `HomeScreen`.
4. Pita debug Flutter dimatikan lewat `debugShowCheckedModeBanner: false`.

`HomeScreen` memiliki header RPG di bagian atas dan tiga tab utama pada navigasi bawah beranimasi (`AnimatedRpgBottomNav`):

| Tab | Isi |
| --- | --- |
| **Kalender & Quest** | Kontrak harian (beserta status Limit EXP Harian), kalender responsif (`Bulan \| Minggu \| Hari`), chip filter kategori/rank, daftar quest pada tanggal terpilih, dan tombol `Quest Baru` |
| **Profil Saya** | Dashboard karakter: avatar, nama, gelar, level karakter, quest tuntas, streak aktif, dan empat atribut RPG (`STR`, `INT`, `DIS`, `VIT`) |
| **Papan Guild** | Ringkasan total misi (Total, Terselesaikan, Menunggu), grafik sebaran quest per rank, pengaturan **Suara Pengingat** (dengan tombol *preview* langsung), dan status sinkronisasi lokal |

Header atas menampilkan avatar, nama, gelar, badge streak harian dengan efek *pulse*, serta bilah progres EXP & Level.

## 3. Struktur Kode

```text
lib/
  main.dart                         titik masuk, MultiProvider, inisialisasi locale & notifikasi
  domain/models/                    Quest, UserProfile, AvatarCatalog, NotificationSound
  data/services/                    StorageService, NotificationService, AuthSyncService
  data/repositories/                QuestRepository (cache memori & persistensi)
  ui/core/themes/                   AppTheme (palet warna RPG dark mode)
  ui/core/widgets/                  GuildBackdrop (latar bintang) & animated_tap_menu.dart (animasi menu 60fps)
  ui/features/splash/               SplashScreen dengan animasi shimmer
  ui/features/home/                 HomeScreen dan _EditNameDialog
  ui/features/calendar/             CalendarWidget (mode Bulan, Minggu, Hari responsif)
  ui/features/quests/               QuestCard, AddQuestDialog, dan QuestViewModel
  ui/features/character/            CharacterViewModel, AvatarView, AvatarPickerSheet, LevelUpDialog
assets/avatars/                     tujuh avatar bawaan berformat SVG
test/                               unit test aturan RPG, limit EXP harian, dan widget test
android/                            proyek Android, MainActivity (MethodChannel audio), dan nada WAV di res/raw
web/                                splash HTML, manifest, ikon web
```

Alur data:

```text
UI  ->  ViewModel  ->  Repository / Service  ->  SharedPreferences
                     ->  NotificationService ->  notifikasi & MethodChannel audio perangkat
```

## 4. Sistem Quest, Penguncian 1x Pakai, dan Limit EXP Harian

Model quest berada di `lib/domain/models/quest_model.dart`.

Field pada `Quest`:
`id`, `title`, `description`, `date`, `startTime`, `endTime`, `rank`, `category`, `expReward`, `coinReward`, `isCompleted`, `expClaimed`, `completedAt`.

### Rank dan Hadiah Dasar EXP

| Rank | Label | EXP Dasar |
| :---: | --- | ---: |
| **E** | Novice | 25 |
| **D** | Apprentice | 50 |
| **C** | Adept | 100 |
| **B** | Expert | 200 |
| **A** | Master | 350 |
| **S** | Legendary | 500 |

### Kategori dan Atribut

| Kode | Label | Atribut yang Naik |
| --- | --- | --- |
| `strength` | Kekuatan | **STR** |
| `intellect` | Kecerdasan | **INT** |
| `discipline` | Disiplin | **DIS** |
| `vitality` | Kebugaran | **VIT** |

### Aturan 1 Kali Pakai (Anti-Farming EXP)

- Setiap quest hanya dapat diselesaikan **1 kali pakai**.
- Saat pengguna menekan checkbox pada quest yang belum selesai, `QuestViewModel.toggleQuestCompletion` mengubah `isCompleted: true` dan `expClaimed: true`, memberikan EXP sesuai sisa kuota harian, menampilkan badge **`Terkunci (1x Pakai)`**, serta menyembunyikan menu **Ubah Quest**.
- Menekan kembali checkbox pada quest yang sudah selesai **tidak akan membatalkan status selesai** dan tidak akan memberikan EXP berulang. Aplikasi menampilkan snackbar informasi bahwa setiap tugas hanya bisa digunakan 1 kali.

### Sistem Limit EXP Harian (`500 EXP / Hari`)

- Konstanta `UserProfile.maxDailyExp` menetapkan batas maksimal **`500 EXP`** per hari.
- `UserProfile` menyimpan `dailyExpEarned` dan `dailyExpDate` di `SharedPreferences`. Dengan demikian, walaupun pengguna menghapus quest yang sudah selesai pada hari tersebut, jumlah EXP yang sudah diklaim hari itu tetap tercatat dan tidak me-reset kuota harian.
- Pada dialog pembuatan/pengubahan quest (`AddQuestDialog`), aplikasi menghitung:
  - `committedExp`: gabungan EXP yang sudah diklaim pada tanggal tersebut ditambah total EXP dari quest yang masih menunggu pada tanggal tersebut.
  - `remainingQuota`: `500 - committedExp`.
  - Jika `defaultExp` dari Rank yang dipilih melebihi `remainingQuota` (saat `remainingQuota > 0`), maka `expReward` otomatis disesuaikan dengan `remainingQuota`.
  - Jika `remainingQuota == 0` (`500 / 500 EXP` terpakai), tombol **Terbitkan Quest** dikunci untuk tanggal tersebut dan menampilkan peringatan bahwa Limit EXP Harian telah penuh.

## 5. Karakter dan Level

Model karakter berada di `lib/domain/models/user_profile_model.dart`.

Nilai awal: nama `"Petualang"`, gelar `"F-Rank Novice"`, level `1`, EXP `0`, streak `1`, dan seluruh atribut (`STR`, `INT`, `DIS`, `VIT`) bernilai `1`.

Rumus EXP maksimum untuk naik level:

```text
maxExp = 100 + (level - 1) * 75
```

Level 1 membutuhkan `100 EXP`, Level 2 membutuhkan `175 EXP`, Level 3 membutuhkan `250 EXP`, dan seterusnya.

| Rentang Level | Gelar |
| --- | --- |
| 1–4 | F-Rank Novice |
| 5–9 | D-Rank Scout |
| 10–14 | C-Rank Adventurer |
| 15–19 | B-Rank Veteran |
| 20–29 | A-Rank Vanguard |
| 30–39 | S-Rank Champion |
| 40–49 | Legendary Hero |
| 50+ | Mythic Grandmaster |

Saat naik level, `CharacterViewModel.onLevelUp` memicu `LevelUpDialog` yang menampilkan animasi partikel kilau dan kartu kenaikan level.

### Avatar

Tujuh avatar SVG bawaan tersedia di `assets/avatars/` dan `AvatarCatalog`:
`guardian` (Penjaga), `mage` (Penyihir), `scout` (Pengintai), `knight` (Ksatria), `scholar` (Cendekia), `ranger` (Pemanah), dan `healer` (Penyembuh). Pengguna juga dapat memilih foto dari Galeri atau Kamera yang disalin ke direktori dokumen aplikasi sebagai `user_avatar.jpg`.

## 6. Desain Dark Arcane Glassmorphism & Kalender Responsif

### Sistem Desain Dark Arcane Glassmorphism (`AppTheme` & `GuildBackdrop`)

- **Frosted Glass Containers**: Mengombinasikan `BackdropFilter(filter: ImageFilter.blur(...))` dengan `AppTheme.glassCardDecoration`, `glassButtonDecoration`, `glassPillDecoration`, dan `glassRecessedDecoration`.
- **Specular Gradients & Border Kontras**: Gradien putih semi-transparan `white.withAlpha(55)` ke `white.withAlpha(12)` dengan ketebalan 1.2px memberikan kesan pantulan kaca kristal RPG.
- **Multi-Orb Radiant Glow**: `GuildBackdrop` memancarkan 4 ambient radial glow beranimasi (*Arcane Gold*, *Mystic Cyan*, *Violet Nebula*, dan *Emerald Shimmer*) yang dibiaskan secara dinamis di balik elemen kaca.
- **Aksesibilitas Kontras Tinggi**: Seluruh teks judul dan label mempertahankan rasio kontras > 6.0:1 (melebihi standar WCAG AA).

### Kalender Responsif (`CalendarWidget`)

- Menggunakan `LayoutBuilder` untuk mendeteksi lebar layar (`isCompact` saat `< 460px`).
- Pada mode portrait, baris judul bulan + tombol `Hari Ini` + navigasi `<` `>` dipisahkan di baris atas, sedangkan tombol pemilih mode **`Bulan | Minggu | Hari`** direntangkan penuh (*full-width*) di baris kedua agar tidak terhalang di layar sempit.
- Nama bulan dan tahun (`MMMM yyyy`) dibungkus dengan `Flexible` + `FittedBox(fit: BoxFit.scaleDown)` sehingga setiap nama bulan (seperti *September 2026*) tampil utuh tanpa terpotong `...`.

### Animasi Menu Mikro (`lib/ui/core/widgets/animated_tap_menu.dart`)

- **`AnimatedPressScale`**: Memanfaatkan `AnimatedScale` berbasis GPU transform (`Curves.easeOutCubic`, `160ms`) yang mengecil halus (`0.94x`) saat disentuh dan memantul ringan saat dilepas tanpa memicu *layout pass*.
- **`AnimatedMenuChip`**: Berbasis glass pill decoration pada seluruh filter kategori, filter rank, serta pemilih Rank dan Kategori di `AddQuestDialog`.
- **`AnimatedRpgBottomNav`**: Navigasi bawah frosted glass khusus dengan kapsul indikator aktif yang bergeser halus (`200ms`) dan transisi konten antar tab menggunakan `FadeTransition` + `SlideTransition` mikro (`210ms`).

## 7. Penyimpanan Lokal

`StorageService` menggunakan dua kunci di `SharedPreferences`:

| Kunci | Isi |
| --- | --- |
| `quest_kalender_quests_v1` | JSON daftar seluruh quest |
| `quest_kalender_profile_v1` | JSON objek profil pengguna (termasuk `dailyExpEarned` & `dailyExpDate`) |

## 8. Notifikasi dan Suara Pengingat Native

`NotificationService` mengelola penjadwalan pengingat quest dan pemutaran contoh suara (*preview*):

- Setiap pilihan suara memiliki channel notifikasi Android tersendiri (`quest_reminders_<id>_v2`) dengan `AudioAttributesUsage.alarm` karena Android mengunci suara channel setelah pertama kali dibuat.
- Untuk memutar suara secara instan saat pengguna memilih nada di tab **Papan Guild** atau menekan ikon speaker, `NotificationService.previewCurrentSound` memanggil `MethodChannel('quest_kalender/sound')` yang ditangani langsung di `MainActivity.kt` menggunakan `android.media.MediaPlayer` (untuk file `.wav` di `res/raw/`) dan `RingtoneManager` (untuk nada sistem `default`).
- File `android/app/src/main/res/raw/keep.xml` (`tools:keep="@raw/bell,@raw/chime,@raw/horn,@raw/pulse"`) memastikan file suara `.wav` tidak dihapus oleh resource shrinker R8 saat proses `flutter build apk --release`.

| ID | Label | Sumber Audio |
| --- | --- | --- |
| `default` | Nada sistem | Nada notifikasi/alarm bawaan Android |
| `bell` | Lonceng | `res/raw/bell.wav` |
| `chime` | Lonceng angin | `res/raw/chime.wav` |
| `horn` | Terompet guild | `res/raw/horn.wav` |
| `pulse` | Denyut | `res/raw/pulse.wav` |
| `silent` | Senyap | Tanpa suara |

## 9. Membangun dan Menjalankan Pengujian

Dari akar direktori `quest_kalender`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Hasil APK Release berada di `build/app/outputs/flutter-apk/app-release.apk`.

## 10. Pengujian Otomatis (`test/`)

- `test/widget_test.dart`: Memastikan aplikasi utama dan ketiga tab (`Kalender & Quest`, `Profil Saya`, `Papan Guild`) ter-render dengan benar.
- `test/quest_rpg_test.dart`: Menguji:
  - Hadiah EXP bawaan Rank `E` sampai `S`;
  - Serialisasi `toMap` dan `fromMap` pada `Quest` (termasuk status `isCompleted` & `expClaimed`);
  - Rumus kebutuhan EXP kenaikan level (`calculateMaxExp`);
  - Pemberian EXP, kenaikan atribut, dan pemicu `onLevelUp`;
  - Penyimpanan avatar bawaan, foto kustom, dan pilihan suara pengingat;
  - Pembatasan **Limit EXP Harian (`500 EXP/hari`)** agar klaim EXP dalam satu hari tidak dapat melewati batas `500 EXP`.
