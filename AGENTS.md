# AGENTS.md

Panduan untuk agen kode yang mengerjakan repositori **Quest Kalender**.
Dokumentasi produk lengkap ada di [docs/DOKUMENTASI.md](docs/DOKUMENTASI.md).

## Proyek

Aplikasi Flutter kalender tugas bergaya RPG dengan tema **Dark Arcane Glassmorphism**. Pengguna membuat quest, menyelesaikannya (1 kali pakai per tugas), lalu mendapat **EXP** (dengan batas maksimal **500 EXP/hari**), kenaikan **Atribut (`STR`, `INT`, `DIS`, `VIT`)**, **Level**, **Gelar**, dan **Streak Harian**.
Data tersimpan lokal di perangkat. Bahasa antarmuka: Indonesia.

Remote: https://github.com/senji830/kalender-projek
Branch kerja: `master`
Tag Rilis Terkini: `v1.1.2` (Riwayat rilis: `v1.0.0`, `v1.1.0`, `v1.1.1`, `v1.1.2`)

## Batasan & Aturan Penting

- **Tema Desain (Dark Arcane Glassmorphism)**: Pertahankan konsistensi antarmuka kaca buram (*frosted glass*). Gunakan `AppTheme.glassCardDecoration`, `glassButtonDecoration`, `glassPillDecoration`, `glassRecessedDecoration`. Hindari membungkus banyak kartu scrollable dengan `BackdropFilter` secara terpisah untuk menjaga frame rate 60/120 FPS.
- **Performa & Smooth Experience**:
  - Pertahankan `IndexedStack` untuk tab di `HomeScreen` agar state, scroll offset, dan widget tree tidak dihancurkan saat berganti tab.
  - Hindari `IntrinsicHeight` pada item daftar scrollable (`QuestCard`). Gunakan layout `Stack` dengan `Positioned` untuk garis sisi kartu guna menghindari double speculative layout pass.
  - Pertahankan radius blur shadow yang ringan (<= 12px) di `AppTheme` untuk mencegah GPU fill-rate exhaustion pada perangkat Android mid/low-end.
  - Gunakan `RepaintBoundary` untuk mengisolasi area dinamis seperti `CalendarWidget` dan tab.
- **Aksesibilitas & Kontras**: Teks judul, label, lencana, dan tombol aksi wajib mempertahankan rasio kontras tinggi **WCAG AA (> 6.0:1)** di atas latar belakang kaca gelap.
- Jangan mengubah ikon launcher, favicon, atau splash native Flutter kecuali diminta.
- Jangan menambahkan backend, Firebase, atau Supabase sungguhan. `AuthSyncService` masih stub lokal.
- Sistem poin **Gold/Koin** sudah dihapus dari UI agar progres berfokus pada EXP, Level, Atribut RPG, dan Streak. Jangan menampilkan kembali indikator Gold/Koin di UI kecuali diminta.
- Setiap tugas (`Quest`) yang sudah diselesaikan bersifat **1 kali pakai (`expClaimed: true`)** dan terkunci (tidak bisa di-uncheck lagi untuk *farming* EXP).
- Setiap tanggal memiliki **Limit EXP Harian (`UserProfile.maxDailyExp = 500`)** yang wajib ditegakkan baik saat menambah quest di `AddQuestDialog` maupun saat mengklaim EXP di `CharacterViewModel` / `QuestViewModel`.
- Jangan memasukkan `build/`, `.dart_tool/`, `.idea/`, `local.properties`, keystore, atau rahasia ke Git.
- Rilis Android masih ditandatangani dengan kunci debug (`com.example.quest_kalender`). Jangan menggantinya tanpa permintaan.

## Cara Mengubah Kode

1. Ikuti arsitektur yang sudah ada: model di `lib/domain`, penyimpanan di `lib/data`, layar dan view model di `lib/ui`.
2. State layar memakai `provider`. Jangan menambah paket state management lain.
3. Widget dialog yang memegang `TextEditingController` harus `StatefulWidget`, dan controller hanya di-`dispose` di `dispose()` widget itu.
4. Quest dan profil disimpan sebagai JSON di `SharedPreferences`. Pertahankan kunci `quest_kalender_quests_v1` dan `quest_kalender_profile_v1`.
5. Notifikasi dijadwalkan dari jam mulai quest (`HH:mm`) lewat `NotificationService`. Pemutaran suara langsung (*preview*) menggunakan `MethodChannel('quest_kalender/sound')` di `MainActivity.kt` dan file WAV di `android/app/src/main/res/raw/` yang dijaga oleh `keep.xml`.
6. Untuk komponen menu atau tombol pilihan baru, gunakan widget animasi ringan di `lib/ui/core/widgets/animated_tap_menu.dart` (`AnimatedPressScale`, `AnimatedMenuChip`, `AnimatedRpgBottomNav`) berpadu dengan dekorasi kaca `AppTheme` agar tetap smooth `60fps+` di GPU.
7. Komponen panel kaca baru dapat langsung menggunakan dekorasi kaca `AppTheme.glassCardDecoration(...)`.
8. UI baru harus memakai warna di `AppTheme` dan bahasa Indonesia.

## Perintah & Rilis

Jalankan dari akar repositori `quest_kalender`:

```powershell
flutter analyze
flutter test
flutter build apk --release
```

Hasil build APK berada di:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/quest-kalender-v1.1.0.apk`

Untuk membuat tag rilis baru dan mengunggah ke GitHub:
```powershell
git tag -a v1.1.0 -m "Release v1.1.0: Dark Arcane Glassmorphism UI/UX Overhaul"
git push origin v1.1.0
gh release create v1.1.0 build/app/outputs/flutter-apk/quest-kalender-v1.1.0.apk --title "Quest Kalender v1.1.0 - Dark Arcane Glassmorphism Release" --notes-file RELEASE_NOTES_v1.1.0.md
```

<!-- antislop:start -->
## antislop
For UI, copy, people, mobile layout, or code comments work, read `antislop.md` (core) and then the skill for the task:
- UI / visual: `skills/antislop-ui/SKILL.md`
- Copy & text: `skills/antislop-copywriting/SKILL.md`
- People: `skills/antislop-human/SKILL.md`
- Mobile / responsive: `skills/antislop-layoutmobile/SKILL.md`
- Code comments: `skills/antislop-code/SKILL.md`
Before starting, ask the user when antislop applies: during the work, or after it is done.
To update antislop later: download `antislop.md` again, or run `npx antislop-ai --update` if it was installed as skill folders.
<!-- antislop:end -->
