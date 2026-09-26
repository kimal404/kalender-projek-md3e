# Design System & Identity: Quest Kalender

Dokumentasi filosofi desain, sistem token warna, tipografi, dan parameter interaksi visual untuk aplikasi **Quest Kalender**.

---

## 1. Design Dials (Parameter Desain)

Sesuai dengan panduan integritas estetika dan anti-slop, antarmuka Quest Kalender diatur oleh tiga skala dial:

| Parameter | Nilai (1–3) | Penjelasan Desain |
|---|:---:|---|
| **ENERGY** | **2 (Balanced)** | Nuansa RPG gamified yang bersemangat namun tetap fokus pada produktivitas harian. Warna aksen emas guild dan aksen neon dipakai secara terukur tanpa membuat layar bising atau melelahkan mata. |
| **RHYTHM** | **2 (Structured)** | Tata letak papan quest modular bergaya guild fantasy. Komponen tersusun dalam kartu (cards) dengan padding konsisten (16dp/18dp), radius melengkung 14–18dp, dan hierarki visual yang jelas. |
| **MOTION** | **2 (Tactile)** | Animasi interaksi yang responsif dan taktil. Transisi tab berdurasi 210ms dengan kurva `easeOutCubic`, stagger fade-slide masuk bertahap (70ms interval), dan feedback sentuhan langsung tanpa jeda yang memperlambat alur kerja. |

---

## 2. Palet Warna & Token Visual (Dark RPG Theme)

Quest Kalender menggunakan palet gelap bertema **Guild Petualang Malam (Midnight Obsidian & Gold)** dengan kepatuhan kontras aksesibilitas WCAG AA:

| Token | Nilai Hex | Peran Visual | Rasio Kontras pada Background |
|---|---|---|:---:|
| `primaryGold` | `#FFB300` | Aksen utama guild, tombol aksi utama (CTA), bintang reputasi, level-up highlight | 11.2:1 (Sangat Tinggi) |
| `accentAmber` | `#FF8F00` | Aksen hangat sekunder, badge peringatan, highlight transisi | 8.9:1 |
| `darkBackground` | `#0F1126` | Kanvas latar belakang utama (Midnight Obsidian) | — |
| `cardBackground` | `#1A1F3A` | Latar kartu informasi, dialog, dan surface papan quest (Slate Guild) | — |
| `surfaceLighter` | `#2A2F4D` | Border pemisah, elevasi kartu, chip filter tidak aktif | — |
| `textMuted` | `#B8BAC8` | Teks sekunder, metadata tanggal, keterangan label kecil (Slate Mist) | > 6.2:1 (Lolos WCAG AA) |
| `neonCyan` | `#00E5FF` | Mana kustomisasi, status offline lokal, atribut kecerdasan (INT), link avatar | 12.8:1 |
| `neonPurple` | `#D500F9` | Indikator progres Arcane EXP bar, aura mistis | 4.8:1 |
| `healthGreen` | `#69F0AE` | Indikator status selesai (Quest Clear), badge aman, kontrak tuntas | 13.5:1 |

---

## 3. Tipografi & Hierarki Teks

- **Display & Judul Utama (`18–20px`, Bold, Letter-spacing `0.5`):** Digunakan untuk header profil petualang, judul tab, dan dialog perayaan (Level Up, Registrasi).
- **Subjudul & Judul Quest (`14–16px`, Bold):** Digunakan pada nama misi, judul kartu atribut, dan ringkasan guild.
- **Isi & Deskripsi (`12–14px`, Regular / Medium, line-height `1.4`):** Digunakan pada deskripsi tugas, detail misi, dan pesan sambutan.
- **Label / Tag / Meta (`10–11px`, Bold / Semi-bold):** Digunakan untuk Rank misi (Rank S, A, B, C, D, E, F), EXP badge, dan streak counter.

---

## 4. Prinsip Kejujuran Antarmuka (Anti-Slop UX Integrity)

1. **Tanpa Kontrol Semu (No Fake Controls):**
   - Tidak ada tombol "Periksa Sinkronisasi Cloud" palsu. Data ditampilkan secara transparan sebagai **Penyimpanan Offline Lokal Aktif (Hive)**.
2. **Umpan Balik Instan & Konkret:**
   - Pencarian misi langsung merespons teks pencarian (Real-time Filter) dengan pesan status jelas dan tombol "Reset Pencarian".
3. **Integritas Mekanika RPG:**
   - Setiap misi hanya dapat diselesaikan 1 kali per hari untuk mencegah eksploitasi EXP.
   - Limit perolehan EXP harian (500 EXP/hari) dipantau secara transparan dengan bilah progres terverifikasi.
4. **Target Sentuh Ergonomis:**
   - Semua elemen interaktif (tombol, chip filter, avatar picker, icon button) memiliki target sentuh minimum $\ge 48 \times 48$ dp untuk kenyamanan navigasi satu tangan.
