# Quest Kalender v1.2.1 — Animated Dashboard Transitions & Progressive Metrics

Pembaruan **v1.2.1** menambahkan animasi transisi perpindahan dashboard yang sangat halus (*buttery-smooth directional slide & cross-fade*) setiap kali pengguna berpindah antar tab/dashboard, serta menyempurnakan metrik progresif pada dashboard Papan Guild dan Profil.

---

## ⚡ Sorotan Pembaruan v1.2.1

### 1. Directional Slide & Cross-Fade Dashboard Transition (`_AnimatedDashboardStack`)
- Menggantikan `IndexedStack` standar dengan komponen transisi dinamis `_AnimatedDashboardStack`.
- Setiap kali pengguna berpindah tab:
  - **Arah Terarah (*Directional Flow*)**: Bergeser ke tab kanan memicu slide masuk dari kanan (+7% lebar layar) dan slide keluar ke kiri (-7%), begitu pula sebaliknya saat bergeser ke kiri.
  - **Cross-Fade Lembut**: Transisi opasitas yang sinkron (`Curves.easeOutCubic`, 260ms) menghasilkan kesan antarmuka yang sangat hidup dan modern.
  - **Preservasi State 100%**: Memanfaatkan `Offstage(maintainState: true)` sehingga posisi scroll daftar quest, riwayat kalender, dan state widget tidak tereset sama sekali saat berganti dashboard.

### 2. Animasi Metrik Progresif Papan Guild & Profil
- **Counter Misi Bertahap**: Angka metrik ringkasan misi (*Total Quest*, *Terselesaikan*, *Menunggu*) di Papan Guild meluncur naik secara bertahap dengan `TweenAnimationBuilder<int>` (600ms).
- **Ekspansi Bar Rank**: Batang kemajuan proporsi quest berdasarkan Rank (E sampai S) menganimasikan pelebaran bar secara halus saat Papan Guild dibuka.
- **Stat Pill Switcher**: Lencana statistik profil (*Quest Tuntas*, *Streak Aktif*, *Level Karakter*) kini dilengkapi `AnimatedSwitcher` untuk pembaruan visual yang mulus.

---

## 🛡️ Integritas Sistem (100% Utuh)

- **Sistem Limit 500 EXP/Hari**: Tetap aktif dan terjaga di setiap tanggal.
- **Quest 1 Kali Pakai**: Quest tuntas tetap terkunci permanen untuk mencegah eksploitasi EXP.
- **Audio Native WAV**: 6 pilihan nada kustom (`Default`, `Lonceng`, `Lonceng Angin`, `Terompet Guild`, `Denyut`, `Senyap`) tetap dapat diputar secara native via MethodChannel Android.
- **Kustomisasi Avatar**: 7 avatar SVG bawaan + foto kamera/galeri berfungsi normal.
- **Hasil Pengujian**: Seluruh 13/13 unit & widget tests lulus 100%, 0 issues pada `flutter analyze`.
