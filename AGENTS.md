# AGENTS.md

Panduan untuk agen kode yang mengerjakan repositori Quest Kalender.
Dokumentasi produk lengkap ada di [docs/DOKUMENTASI.md](docs/DOKUMENTASI.md).

## Proyek

Aplikasi Flutter kalender tugas bergaya RPG. Pengguna membuat quest,
menyelesaikannya, lalu mendapat EXP, koin, atribut, level, dan streak.
Data tersimpan lokal di perangkat. Bahasa antarmuka: Indonesia.

Remote: https://github.com/senji830/kalender-projek
Branch kerja: `master`

## Batasan

- Jangan mengubah ikon launcher, favicon, atau splash native Flutter kecuali diminta.
- Jangan menambahkan backend, Firebase, atau Supabase sungguhan. `AuthSyncService` masih stub lokal.
- Jangan menaikkan reward, mengubah rumus level, atau membalik EXP saat quest dibatalkan kecuali diminta. Membatalkan quest saat ini tidak mengurangi EXP, koin, atau atribut.
- Jangan memasukkan `build/`, `.dart_tool/`, `.idea/`, `local.properties`, keystore, atau rahasia ke Git.
- Rilis Android masih ditandatangani dengan kunci debug. Jangan membuat kunci rilis baru tanpa permintaan.
- Package ID masih `com.example.quest_kalender`. Jangan menggantinya tanpa permintaan.

## Cara mengubah kode

1. Ikuti arsitektur yang sudah ada: model di `lib/domain`, penyimpanan di `lib/data`, layar dan view model di `lib/ui`.
2. State layar memakai `provider`. Jangan menambah paket state management lain.
3. Widget dialog yang memegang `TextEditingController` harus `StatefulWidget`, dan controller hanya di-`dispose` di `dispose()` widget itu.
4. Quest dan profil disimpan sebagai JSON di `SharedPreferences`. Pertahankan kunci `quest_kalender_quests_v1` dan `quest_kalender_profile_v1`, atau sediakan migrasi jika formatnya berubah.
5. Notifikasi dijadwalkan dari jam mulai quest (`HH:mm`) lewat `NotificationService`. Quest selesai, tanpa jam, atau yang waktunya sudah lewat tidak boleh tetap terjadwal.
6. Suara pengingat memakai ID di `NotificationSounds`. Jangan memakai satu channel Android untuk semua nada: Android mengunci suara channel saat pertama dibuat. Nada baru butuh file di `android/app/src/main/res/raw/` dan entri katalog.
7. Avatar bawaan ada di `assets/avatars/` dan `AvatarCatalog`. Foto pengguna disalin ke dokumen aplikasi, bukan disimpan dari path galeri sementara.
8. UI baru harus memakai warna di `AppTheme`, bukan warna acak di luar palet yang sudah ada.
9. Salinan untuk pengguna tetap bahasa Indonesia.
10. Bottom sheet yang isinya bisa lebih tinggi dari layar harus bisa digulir. Jangan biarkan overflow pita kuning-hitam.

## Perintah

Jalankan dari akar repositori `quest_kalender`:

```powershell
dart format .
flutter analyze
flutter test
```

Untuk memasang ke HP yang terhubung USB:

```powershell
flutter devices
flutter run -d <device-id> --debug --no-resident
```

Perubahan Dart pada UI bisa di-hot-reload. Perubahan `init()`, provider, atau penyimpanan butuh hot restart atau pemasangan ulang.

## Selesai

Sebelum selesai, pastikan tes yang relevan lulus dan diff tidak berisi file generate atau rahasia. Commit dan push hanya jika pengguna memintanya. Pesan commit ditulis dalam bahasa Indonesia, satu atau dua kalimat, fokus pada alasan perubahan.
