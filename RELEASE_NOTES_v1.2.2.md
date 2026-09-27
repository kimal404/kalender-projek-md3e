# Quest Kalender v1.2.2 — Fix Dashboard Transition Flickering & Double Animation

Pembaruan **v1.2.2** menyelesaikan masalah visual animasi yang tampak berulang dua kali atau berkedip (*flickering*) saat berpindah antar dashboard.

---

## ⚡ Solusi & Peningkatan

### 1. Eliminasi Unmounting Subtree pada Transisi Selesai
- **Akar Masalah**: Sebelumnya, saat animasi transisi mencapai titik akhir (status `completed`), `Transform.translate` dan `Opacity` dicopot (*unmounted*) dari pohon widget. Perubahan struktur render tree ini memicu deattachment/re-attachment yang menyebabkan kedipan (*blink*) 1 frame dan mereset animasi internal anak widget (seperti counter angka dan progress bar) sehingga berjalan untuk kedua kalinya.
- **Solusi**: Diperbarui menjadi struktur render tree statis dan konstan (`Offstage` -> `TickerMode` -> `IgnorePointer` -> `AnimatedBuilder` dengan `FractionalTranslation` + `Opacity` -> `RepaintBoundary` -> `KeyedSubtree(key: PageStorageKey)`).
- **Hasil**: Struktur pohon widget 100% konsisten sebelum, selama, dan sesudah transisi. Tidak ada lagi remounting render object, tidak ada kedipan, dan animasi berjalan tepat **satu kali** secara presisi.

### 2. Penghapusan Efek Stagger Bertabrakan
- Menghapus komponen pembungkus vertikal delayed slide (`_StaggerFadeSlide`) di tab Profil yang sebelumnya memicu pergerakan bertingkat setelah transisi horizontal selesai.
- Seluruh dashboard kini masuk sebagai satu kesatuan antarmuka yang tenang, mulus, dan solid.

---

## 🛡️ Integritas Fitur (100% Utuh)

- **Limit EXP Harian (500 EXP/Hari)**: Tetap aktif dan terjaga di setiap tanggal.
- **Quest 1 Kali Pakai**: Tugas tuntas tetap terkunci permanen.
- **Audio Native WAV**: 6 pilihan nada kustom tetap dapat diputar langsung secara native.
- **Preservasi State**: Scroll posisi di setiap dashboard tetap tersimpan utuh saat berpindah tab.
- **Pengujian**: 13/13 unit & widget tests lulus 100%, 0 issues pada `flutter analyze`.
