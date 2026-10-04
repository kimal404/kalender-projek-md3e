# Quest Kalender v1.3.0 — 4-Axis Stat Radar Polygon & Character Archetype System

Pembaruan **v1.3.0** menghadirkan visualisasi grafis **Radar Poligon Gaya Hidup (*Stat Radar Chart*)** pada dashboard profil petualang, serta **Sistem Archetype / Kepribadian Karakter** dan **Rekomendasi Penyeimbang Hidup (*Balance Advice*)**.

---

## 🌟 Fitur Baru & Peningkatan

### 1. Radar Poligon Gaya Hidup (4-Axis Diamond Polygon)
- **Visualisasi Atribut RPG Terintegrasi**: Menggabungkan empat sumbu atribut karakter:
  - ⬆️ **STR** (Kekuatan — Merah `#EF5350`)
  - ➡️ **INT** (Kecerdasan — Biru `#42A5F5`)
  - ⬇️ **DIS** (Disiplin — Ungu `#AB47BC`)
  - ⬅️ **VIT** (Kebugaran — Hijau `#66BB6A`)
- **Struktur Grid Konsentris**: Cincin pembagi persentase 25%, 50%, 75%, dan 100% dengan garis *hairline* presisi (`0.8px`) serta titik sudut (*vertex dot*) beraksen kontras.
- **Animasi Bertahap (*Progressive Spring/Cubic Expansion*)**:
  - Menggunakan `TweenAnimationBuilder` (650ms, `Curves.easeOutCubic`) sehingga grafik poligon mengembang mulus saat dashboard Profil Saya dibuka.
  - Performa 100% **Zero-Lag (60/120 FPS)** digambar langsung menggunakan native `CustomPainter` tanpa dependensi eksternal berat.

### 2. Klasifikasi Tipe Petualang (*Character Archetype System*)
Sistem menganalisis proporsi poin quest yang telah diselesaikan untuk menentukan kepribadian produktivitas pengguna:
- **Harmoni Seimbang (All-Rounder)**: Saat selisih poin antar atribut $\le 2$ (kehidupan seimbang).
- **Spesialis Fisik (Vanguard / Berserker)**: Fokus aktivitas fisik dan olahraga mendominasi.
- **Spesialis Intelek (Scholar / Arcanist)**: Fokus belajar, membaca, dan riset mendominasi.
- **Spesialis Eksekusi (Tactician / Arbiter)**: Penyelesaian tugas kerja dan rutinitas harian mendominasi.
- **Spesialis Kebugaran (Guardian / Monk)**: Prioritas istirahat, hidrasi, dan pemulihan tubuh mendominasi.

### 3. Rekomendasi Penyeimbang Hidup (*Guild Master Balance Advice*)
Memberikan saran kontekstual yang jujur dan dapat ditindaklanjuti secara harian jika terdapat aspek kehidupan yang tertinggal jauh (misal menyarankan hidrasi/tidur bila VIT tertinggal, atau olahraga ringan bila STR tertinggal).

---

## 🛡️ Integritas Sistem & Kualitas

- **Limit EXP Harian (500 EXP/Hari)**: Tetap aktif dan terjaga ketat di setiap tanggal.
- **Quest 1 Kali Pakai**: Tugas tuntas tetap terkunci permanen untuk mencegah eksploitasi EXP.
- **Desain Modern Flat Minimalist**: Menghindari beban Gaussian box shadow berat, menjaga framerate tetap di 60/120 FPS.
- **Pengujian Otomatis**: 14/14 unit & widget tests lulus 100%, 0 issues pada `flutter analyze`.
