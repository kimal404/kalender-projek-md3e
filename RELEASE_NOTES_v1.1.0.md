# 🌌 Quest Kalender v1.1.0 — Dark Arcane Glassmorphism Release

Selamat datang di pembaruan besar **Quest Kalender v1.1.0**! Versi ini menghadirkan perombakan visual menyeluruh dengan tema **Dark Arcane Glassmorphism**, pencahayaan ambient dinamis (*multi-orb radiant glow*), serta peningkatan performa dan aksesibilitas kontras tinggi.

---

### ✨ Apa yang Baru di v1.1.0?

#### 1. 🔮 Tema Visual Dark Arcane Glassmorphism
- **Frosted Glass Container**: Seluruh kartu quest, dialog, sheet modal, header RPG, dan navigasi bawah mengadopsi efek kaca buram presisi tinggi menggunakan kombinasi `BackdropFilter(filter: ImageFilter.blur(...))` dan `ClipRRect`.
- **Specular Gradient Borders**: Bingkai kaca kristal semi-transparan (`white.withAlpha(55)` ke `white.withAlpha(12)`) dengan ketebalan 1.2px yang memberikan pantulan cahaya kristal RPG yang tajam dan elegan.
- **Multi-Orb Radiant Glow (`GuildBackdrop`)**: Efek pencahayaan ambient 4 rona aura magis (*Arcane Gold*, *Mystic Cyan*, *Violet Nebula*, dan *Emerald Shimmer*) yang berputar lembut dan dibiaskan secara dinamis di balik panel kaca.
- **WCAG AA Compliance (> 6.0:1)**: Teks judul, lencana, kuota EXP, dan elemen interaktif tetap mempertahankan rasio kontras tinggi di atas latar belakang kaca gelap agar nyaman dibaca.

#### 2. 📅 Kalender Interaktif & Transisi Kaca
- **Frame Kalender Frosted Glass**: Kalender utama dibalut panel kaca dengan blur 14px.
- **Sliding Indicator Kristal**: Tombol geser pilihan mode (`Bulan | Minggu | Hari`) meluncur mulus di atas rel cekung *recessed glass* dengan pencahayaan neon cyan.
- **Sel Tanggal Berpenampilan Kaca**: Sel tanggal aktif maupun tanggal terpilih menggunakan efek tombol kaca yang responsif terhadap sentuhan.

#### 3. 🛡️ Header RPG & Dashboard Petualang
- **Top RPG Header Kaca**: Header atas melayang dengan efek frosted glass blur 16px, menampilkan status petualang, streak harian dengan pulse glow, dan bilah EXP tersembunyi (*recessed progress bar*).
- **Kartu Kontrak Harian**: Pemantauan kuota limit EXP harian (`500 EXP/hari`) dengan tata letak teks rapi dan pod batas yang tidak terpotong.
- **Kartu Atribut STR / INT / DIS / VIT**: Visualisasi atribut karakter dengan ikon lencana kaca (*glass pill badge*).

#### 4. 🪟 Dialog & Lembar Modal Kristal
- **`AddQuestDialog`**: Dialog penambahan quest dengan panel kaca buram (blur 18px), pod kalkulasi kuota EXP harian, dan tombol aksi kaca.
- **`LevelUpDialog`**: Kartu selebrasi naik level berpenampilan kaca kristal bercahaya.
- **`AvatarPickerSheet`**: Lembar pemilihan avatar bawaan maupun foto kustom dengan latar kaca lembut.

#### 5. ⚡ Performa & Pengujian
- **GPU-Accelerated**: Seluruh mikro-animasi menggunakan transformasi GPU ringan tanpa memicu relayout berat.
- **Analisis & Pengujian 100% Lulus**: 0 error pada `flutter analyze` dan 12/12 unit/widget test berhasil lolos.

---

### 📦 Berkas Instalasi (Assets)
- **`quest-kalender-v1.1.0.apk`** (Android APK Universal)
