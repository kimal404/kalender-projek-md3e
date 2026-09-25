# Quest Kalender

Kalender tugas harian bergaya RPG. Quest yang selesai memberi EXP, koin, atribut, level, dan streak. Semua data tersimpan di perangkat, dalam bahasa Indonesia.

Versi `1.0.0+1` · Flutter · Android dan Web · [Dokumentasi lengkap](docs/DOKUMENTASI.md)

## Fitur

- Kalender bulan dengan quest per tanggal, filter kategori, dan filter rank E sampai S.
- Kontrak harian yang menandai hari selesai bila semua quest tuntas.
- Profil petualang: nama, gelar, level, EXP, koin, streak, dan empat atribut.
- Tujuh avatar bawaan, plus foto sendiri dari galeri atau kamera.
- Pengingat pada jam mulai quest, dengan enam pilihan suara.
- Papan guild untuk ringkasan misi dan sebaran rank.

## Cara bermain

Membuat quest memilih tanggal, jam, rank, dan kategori. Rank menentukan hadiah bawaan: E memberi 25 EXP, S memberi 500 EXP. Menyelesaikan quest menaikkan satu atribut sesuai kategorinya.

| Kategori | Atribut |
| --- | --- |
| Kekuatan | STR |
| Kecerdasan | INT |
| Disiplin | DIS |
| Kebugaran | VIT |

EXP untuk naik level adalah `100 + (level - 1) × 75`. Gelar berubah dari F-Rank Novice hingga Mythic Grandmaster di level 50. Streak bertambah jika aplikasi dibuka pada hari berikutnya, dan kembali ke 1 jika putus. Membatalkan quest yang sudah selesai tidak menarik kembali hadiahnya.

## Menjalankan

Perlu Flutter SDK yang sesuai `pubspec.yaml` (`Dart ^3.13.4`).

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d <device-id>
```

Perangkat USB dicek dengan `flutter devices`. Debug APK terbentuk di `build/app/outputs/flutter-apk/`.

## Susunan

```text
lib/domain      model quest, profil, avatar, dan suara
lib/data        penyimpanan lokal, notifikasi, dan repositori
lib/ui          tema, kalender, profil, dan papan guild
assets/avatars  tujuh avatar SVG
android         aplikasi Android dan nada di res/raw
```

State memakai `provider`. Quest dan profil disimpan sebagai JSON di `SharedPreferences`. Suara kustom berada di channel notifikasi terpisah karena Android mengunci suara channel setelah dibuat.

## Batasan

- Belum ada sinkronisasi cloud sungguhan. Tombol periksa sinkronisasi hanya mengonfirmasi penyimpanan lokal.
- Application ID masih `com.example.quest_kalender`, dan build rilis masih memakai kunci debug.
- Ikon launcher masih ikon bawaan Flutter.
- Nada kustom tersedia di Android. Di Apple, pilihan tersimpan tetapi suara bawaan aplikasi belum dibundel.

Panduan untuk pengembang dan agen kode ada di [AGENTS.md](AGENTS.md).
