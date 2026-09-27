# Quest Kalender

Kalender tugas harian bergaya RPG. Setiap quest yang diselesaikan memberikan **EXP**, meningkatkan **Atribut Karakter (STR / INT / DIS / VIT)**, menaikkan **Level & Gelar**, serta menjaga **Streak Harian**. Seluruh data tersimpan secara lokal di perangkat dalam bahasa Indonesia.

Versi `1.2.1+6` · Flutter · Android & Web · [Dokumentasi Lengkap](docs/DOKUMENTASI.md)

## Fitur Utama

- **Kalender Responsif (`Bulan | Minggu | Hari`)**: Tampilan nama bulan lengkap tanpa terpotong baik di mode portrait maupun landscape, dilengkapi indikator dot quest per tanggal, filter kategori, dan filter Rank `E` sampai `S`.
- **Tugas 1 Kali Pakai (Terkunci Saat Selesai)**: Setiap quest yang sudah di-checklist otomatis terkunci (`Terkunci • 1x Pakai`) dan tidak dapat di-uncheck kembali untuk mencegah *farming* EXP berulang.
- **Sistem Limit EXP Harian (`500 EXP / Hari`)**: Setiap tanggal memiliki kuota maksimal **500 EXP/hari**. Dialog tambah quest menampilkan sisa kuota EXP harian secara *real-time*, menyesuaikan hadiah EXP bila mendekati batas, dan mengunci penambahan quest baru jika kuota tanggal tersebut sudah penuh.
- **Kontrak Harian Guild**: Menampilkan progres ketuntasan misi harian serta pantauan **Limit EXP Harian (`X / 500 EXP Diklaim` & `Terjadwal`)**.
- **Profil Petualang & Kustomisasi Avatar**: Nama, gelar otomatis berdasarkan level, bar EXP, level karakter, streak aktif, empat atribut RPG (`STR`, `INT`, `DIS`, `VIT`), 7 avatar SVG bawaan, serta dukungan unggah foto dari Galeri atau Kamera.
- **Suara Pengingat Kustom (Native Audio & Notifikasi)**: Pengingat tepat pada jam mulai quest dengan 6 pilihan nada (`Default`, `Lonceng`, `Lonceng Angin`, `Terompet Guild`, `Denyut`, `Senyap`) yang dapat langsung diputar (*preview*) dari tab **Papan Guild**.
- **Desain Modern Flat Minimalist & Animasi Halus Bertahap (`60/120 FPS`)**: Desain datar minimalis (*flat minimalist*) dengan permukaan slate solid gelap, garis tepi tipis presisi (*hairline borders 1px*), dan eliminasi total blur bayangan berat untuk performa ultra-ringan di semua smartphone. Dilengkapi animasi perpindahan dashboard terarah (*directional slide & cross-fade*), animasi progresif (*progressive count-up* EXP, atribut & metrik guild), dan *spring micro-interactions*.

## Cara Bermain & Aturan RPG

Saat membuat quest baru, pengguna memilih tanggal, jam mulai/selesai, tingkat kesulitan (**Rank**), dan **Kategori Atribut**. Rank menentukan hadiah EXP dasar (sebelum disesuaikan sisa kuota harian):

| Rank | Label | Hadiah Dasar EXP |
| :---: | --- | ---: |
| **E** | Novice | `25 EXP` |
| **D** | Apprentice | `50 EXP` |
| **C** | Adept | `100 EXP` |
| **B** | Expert | `200 EXP` |
| **A** | Master | `350 EXP` |
| **S** | Legendary | `500 EXP` |

Menyelesaikan quest dalam kuota harian menaikkan `+1` poin atribut sesuai kategorinya:

| Kategori | Atribut |
| --- | --- |
| Kekuatan | **STR** (*Strength*) |
| Kecerdasan | **INT** (*Intellect*) |
| Disiplin | **DIS** (*Discipline*) |
| Kebugaran | **VIT** (*Vitality*) |

- **Rumus Kebutuhan EXP Naik Level**: `100 + (level - 1) × 75`
- **Batas Maksimal EXP Harian**: `500 EXP / hari` (tercatat permanen di profil untuk hari tersebut meskipun quest yang sudah selesai dihapus).
- **Gelar Petualang**: Naik bertahap dari *F-Rank Novice* (Lv. 1) hingga *Mythic Grandmaster* (Lv. 50+).
- **Streak Harian**: Bertambah `+1` jika aplikasi dibuka pada hari berturut-turut, dan kembali ke `1` jika terlewat lebih dari satu hari.

## Menjalankan & Membangun Aplikasi

Pastikan Flutter SDK terpasang sesuai `pubspec.yaml` (`Dart ^3.13.4`).

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d <device-id>
```

Untuk membangun APK Release Android:

```powershell
flutter build apk --release
```

Hasil build APK Release tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

## Susunan Proyek

```text
lib/domain      model quest, profil (termasuk limit EXP harian), avatar, dan suara
lib/data        penyimpanan lokal (SharedPreferences), notifikasi, dan repositori
lib/ui          tema, widget animasi ringan, kalender, profil, dan papan guild
assets/avatars  tujuh avatar SVG bawaan
android         aplikasi Android, MainActivity MethodChannel audio, dan nada WAV di res/raw
```

## Batasan Saat Ini

- Penyimpanan dan sinkronisasi masih berjalan secara lokal (`SharedPreferences`). Tombol periksa sinkronisasi hanya mengonfirmasi status penyimpanan offline.
- Application ID masih `com.example.quest_kalender`, dan build rilis masih menggunakan konfigurasi signing debug.
- Pemutaran langsung nada kustom menggunakan native Android (`MediaPlayer` & `RingtoneManager`).

Panduan teknis untuk pengembang dan agen kode tersedia di [AGENTS.md](AGENTS.md) dan [docs/DOKUMENTASI.md](docs/DOKUMENTASI.md).
