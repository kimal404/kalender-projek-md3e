# Dokumentasi Quest Kalender

Dokumen ini menjelaskan aplikasi, arsitektur, aturan permainan, penyimpanan data, audio/notifikasi, animasi UI, proses build, dan batasan yang ada di kode saat ini.

## 1. Ringkasan

**Quest Kalender** adalah aplikasi Flutter untuk mencatat jadwal dan tugas harian sebagai misi (*quest*) bergaya RPG. Pengguna memilih tanggal, menerbitkan quest dengan tingkat kesulitan (*Rank*) dan kategori atribut, lalu menandainya selesai untuk memperoleh **EXP**, menaikkan **Level & Gelar**, meningkatkan **Atribut Karakter (`STR`, `INT`, `DIS`, `VIT`)**, serta mempertahankan **Streak Harian**.

| Item | Nilai |
| --- | --- |
| Nama paket Dart | `quest_kalender` |
| Versi | `1.2.2+7` |
| SDK Dart | `^3.13.4` |
| Application ID Android | `com.example.quest_kalender` |
| Label Android | `quest_kalender` |
| Platform yang ada di repo | Android dan Web |
| Bahasa UI | Indonesia (`id_ID`) |
| Penyimpanan | Lokal, `SharedPreferences` |
| Remote Git | https://github.com/senji830/kalender-projek |
| Branch | `master` |
| Rilis Terkini | `v1.2.2` |

### Riwayat Rilis

| Tag | Versi | Tanggal | Sorotan Perubahan |
| --- | --- | --- | --- |
| [`v1.0.0`](https://github.com/senji830/kalender-projek/releases/tag/v1.0.0) | `1.0.0+1` | Sep 2026 | Rilis perdana: Sistem RPG, limit 500 EXP/hari, tugas 1x pakai, tema Claymorphism 3D |
| [`v1.1.0`](https://github.com/senji830/kalender-projek/releases/tag/v1.1.0) | `1.1.0+2` | Sep 2026 | Pembaruan besar UI/UX: Tema Dark Arcane Glassmorphism, multi-orb glow, kalender kristal |
| [`v1.1.1`](https://github.com/senji830/kalender-projek/releases/tag/v1.1.1) | `1.1.1+3` | Sep 2026 | Optimalisasi Performa: Eliminasi overhead BackdropFilter berulang, isolasi raster RepaintBoundary |
| [`v1.1.2`](https://github.com/senji830/kalender-projek/releases/tag/v1.1.2) | `1.1.2+4` | Sep 2026 | Buttery-Smooth Experience: Retensi state IndexedStack (scroll offset tersimpan), eliminasi IntrinsicHeight via Stack, tuning radius blur shadow rendah overhead GPU, bouncing physics |
| [`v1.2.0`](https://github.com/senji830/kalender-projek/releases/tag/v1.2.0) | `1.2.0+5` | Sep 2026 | Overhaul Modern Flat Minimalist & Progressive Animations: Eliminasi total blur bayangan berat untuk 120 FPS, hairline border 1px, kanvas obsidian dot-grid statis, animasi bertahap (count-up EXP/atribut, cross-fade tab, spring physics) |
| [`v1.2.1`](https://github.com/senji830/kalender-projek/releases/tag/v1.2.1) | `1.2.1+6` | Sep 2026 | Animasi Pergantian Dashboard & Metrik Progresif: Transisi slide horizontal terarah (_AnimatedDashboardStack) + cross-fade antar dashboard, counter progresif metrik guild board & rank, serta AnimatedSwitcher stat pill profil |
| [`v1.2.2`](https://github.com/senji830/kalender-projek/releases/tag/v1.2.2) | `1.2.2+7` | Sep 2026 | Perbaikan Transisi & Anti-Flicker: Eliminasi animasi berulang/berkedip saat ganti dashboard via struktur render-tree konstan (FractionalTranslation + Offstage + PageStorageKey) dan penghapusan staggered delay bertabrakan |

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
  ui/core/themes/                   AppTheme (palet warna RPG dark mode & glassmorphism decorations)
  ui/core/widgets/                  GuildBackdrop (ambient glow), glass_container.dart, & animated_tap_menu.dart
  ui/features/splash/               SplashScreen dengan animasi shimmer
  ui/features/home/                 HomeScreen dan _EditNameDialog
  ui/features/calendar/             CalendarWidget (mode Bulan, Minggu, Hari responsif & sliding indicator)
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

## 6. Desain Modern Flat Minimalist & Animasi Halus Bertahap (Zero-Lag 60/120 FPS)

### Sistem Desain Modern Flat Minimalist (`AppTheme` & `GuildBackdrop`)

- **Modern Flat Surfaces & Hairline Borders**: Menggunakan `AppTheme.flatCardDecoration`, `flatButtonDecoration`, `flatPillDecoration`, dan `flatRecessedDecoration`. Menghilangkan seluruh `BoxShadow` Gaussian blur yang berat dan menggantikannya dengan garis batas tipis presisi (*hairline border 1px*, `borderSubtle: 0xFF2A2E42`) serta warna latar slate solid yang tenang (`bgSlate: 0xFF181B2A`, `cardSlate: 0xFF141724`).
- **Kanvas Obsidian & Subtle Dot-Matrix Grid**: `GuildBackdrop` menggunakan kanvas obsidian pekat (`0xFF0B0D14`) dengan pola grid titik minimalis (`_MinimalGridPainter`, `shouldRepaint => false`) berjarak 28px dengan opacity 2.5%, menghemat beban komputasi shader GPU hingga 0%.
- **Kompatibilitas Penuh**: Helper lama (`glassCardDecoration`, `glassButtonDecoration`, dll.) dialihkan (*forwarded*) secara otomatis ke dekorasi flat tanpa merusak struktur kode yang ada.
- **Aksesibilitas Kontras Tinggi**: Seluruh teks judul dan label mempertahankan rasio kontras > 6.0:1 (melebihi standar WCAG AA).

### Animasi Halus Bertahap (*Progressive Animations*)

- **Directional Slide & Cross-Fade Dashboard Transition**: Pergantian antar dashboard (*Kalender & Quest*, *Profil Saya*, *Papan Guild*) menggunakan `_AnimatedDashboardStack` dengan animasi luncur horizontal terarah (*directional slide* `Offset(±0.07, 0)`) dan *cross-fade* lembut (`Curves.easeOutCubic`, 260ms). Menggunakan `Offstage(maintainState: true)` sehingga posisi scroll dan state setiap dashboard tersimpan utuh 100%.
- **Progressive Count-Up Numbers**: Bar EXP, angka poin atribut RPG (`STR`, `INT`, `DIS`, `VIT`), metrik ringkasan misi di Papan Guild, dan distribusi bar rank menggunakan `TweenAnimationBuilder` (`Curves.easeOutCubic`, 600ms) sehingga nilai meluncur naik secara bertahap saat dashboard dibuka.
- **Spring Physics Checkbox**: Checkbox quest (`_SpringCheckbox`) dilengkapi animasi elastis pegas (*bouncy spring physics*, `Curves.elasticOut` / `Curves.easeOutBack`) dengan transisi visual flat gold solid saat tuntas.
- **`AnimatedPressScale` & `AnimatedMenuChip`**: Interaksi mikro sentuhan responsif menggunakan transform GPU hardware (`0.94x`, 160ms) dengan tampilan pill datar minimalis.
- **`AnimatedRpgBottomNav`**: Bar navigasi bawah flat obsidian dengan sliding capsule pill indikator aktif (200ms) dan transisi ikon yang bersih.

### Kalender Responsif (`CalendarWidget`)

- Menggunakan `LayoutBuilder` untuk mendeteksi lebar layar (`isCompact` saat `< 460px`).
- Pada mode portrait, baris judul bulan + tombol `Hari Ini` + navigasi `<` `>` dipisahkan di baris atas, sedangkan tombol pemilih mode **`Bulan | Minggu | Hari`** direntangkan penuh (*full-width*) di baris kedua dengan track recessed flat dan sliding pill indikator yang mulus.
- Nama bulan dan tahun (`MMMM yyyy`) dibungkus dengan `Flexible` + `FittedBox(fit: BoxFit.scaleDown)` sehingga setiap nama bulan (seperti *September 2026*) tampil utuh tanpa terpotong `...`.
- Sel tanggal kalender bulan dan hari-hari aktif menggunakan flat buttons dengan garis tepi tajam berwarna emas/cyan saat terpilih tanpa shadow blur.

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

### Berkas Hasil Build APK Release
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/quest-kalender-v1.1.0.apk` (~54.4 MB)

Rilis dan aset biner APK dapat diunduh melalui [GitHub Releases](https://github.com/senji830/kalender-projek/releases).

## 10. Pengujian Otomatis (`test/`)

Aplikasi dilengkapi 12 skenario pengujian otomatis (100% lulus):

### 1. `test/quest_rpg_test.dart` (9 Unit Tests):
- **Hadiah EXP Bawaan Rank**: Memastikan Rank `E` sampai `S` memberikan nilai EXP dasar yang sesuai spesifikasi.
- **Serialisasi Data**: Menguji `toMap` dan `fromMap` model `Quest`, termasuk status `isCompleted` dan `expClaimed`.
- **Pencarian Quest**: Memastikan `QuestViewModel` memfilter daftar quest dengan kueri pencarian (`setSearchQuery`).
- **Skala EXP Naik Level**: Memverifikasi rumus `100 + (level - 1) * 75`.
- **Kenaikan Atribut & Level**: Memastikan `CharacterViewModel` mendistribusikan EXP, menaikkan atribut STR/INT/DIS/VIT, dan memicu event `onLevelUp`.
- **Kustomisasi Avatar**: Memastikan avatar bawaan SVG tersimpan dan foto kustom pengguna dapat disimpan dan diganti.
- **Preferensi Audio**: Memastikan pilihan nada notifikasi pengingat tersimpan di profil pengguna.
- **Limit EXP Harian (`500 EXP/hari`)**: Menguji secara ketat bahwa akumulasi EXP dalam 1 hari tidak pernah dapat melebihi batas 500 EXP.
- **Nama Petualang**: Memastikan nama default `"Petualang"` dapat diperbarui melalui `updateName`.

### 2. `test/widget_test.dart` (3 Widget Tests):
- **Render Aplikasi Utama**: Memastikan `HomeScreen` dan seluruh tab bawah (`Kalender & Quest`, `Profil Saya`, `Papan Guild`) tampil tanpa error layout.
- **Animasi Mode Kalender**: Memverifikasi transisi animasi dan indikator geser saat berpindah antara opsi **`Bulan`**, **`Minggu`**, dan **`Hari`**.
- **Dialog Selamat Datang / Registrasi**: Memastikan modal onboarding pendaftaran awal muncul saat pertama kali aplikasi dibuka dan dapat ditutup setelah menyimpan nama petualang.
