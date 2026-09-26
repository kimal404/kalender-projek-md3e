# ⚡ Quest Kalender v1.1.1 — Zero-Lag Performance Patch

Pembaruan **Quest Kalender v1.1.1** berfokus pada **optimalisasi performa ekstrem dan eliminasi lag (60fps/120fps ultra-smooth)** pada perangkat Android!

---

### 🚀 Apa Saja Optimalisasi di v1.1.1?

#### 1. 🏎️ Eliminasi Bottleneck `BackdropFilter` pada Elemen Bergulir (Scrolling)
- **Akar Masalah Sebelumnya**: Penggunaan `BackdropFilter` pada setiap kartu quest (`QuestCard`), kartu dashboard, dan item kalender memaksa GPU ponsel melakukan belasan operasi *saveLayer* dan shader Gaussian blur berulang pada setiap frame saat layar disentuh atau digulir.
- **Solusi Zero-Lag**: Menghilangkan `BackdropFilter` berat dari seluruh daftar scrollable, menggantikannya dengan **Ultra-Fast Translucent Glass** murni berbasis `BoxDecoration` (`AppTheme.glassCardDecoration`).
- **Efek Visual Tetap Mewah**: Karena latar belakang `GuildBackdrop` memancarkan rona ambient dinamis (*Arcane Gold*, *Mystic Cyan*, *Violet Nebula*, dan *Emerald*), transparansi panel kaca tetap membias cahaya ambient secara alami dan realistis dengan biaya render GPU mendekati 0ms.

#### 2. 🛡️ Raster Caching dengan `RepaintBoundary`
- Komponen latar belakang (`GuildBackdrop`), header atas (`_buildTopRpgHeader`), dan navigasi bawah (`AnimatedRpgBottomNav`) kini dilindungi oleh `RepaintBoundary`.
- Lapisan statis di-cache satu kali ke dalam memori tekstur GPU tanpa memicu pengecatan ulang (*repaint*) ketika daftar quest digulir naik-turun.

#### 3. 🎯 Navigasi Bawah & Kalender Responsif
- Transisi tab bawah dan pergantian mode kalender (`Bulan | Minggu | Hari`) kini meluncur instan tanpa ada *dropped frame* atau *stuttering*.

#### 4. 🧪 Hasil Uji Kualitas
- **`flutter analyze`**: **0 issues** (clean).
- **`flutter test`**: **12/12 tests passed** (100% lulus).

---

### 📦 Berkas Instalasi (Assets)
- **`quest-kalender-v1.1.1.apk`** (Android APK Universal)
