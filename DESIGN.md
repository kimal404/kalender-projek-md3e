# Design System & Identity: Quest Kalender

Dokumentasi filosofi desain, sistem token warna, tipografi, dan parameter interaksi visual untuk aplikasi **Quest Kalender**.

---

## 1. Design Dials (Parameter Desain)

Sesuai dengan panduan integritas estetika dan anti-slop, antarmuka Quest Kalender diatur oleh tiga skala dial:

| Parameter | Nilai (1–3) | Penjelasan Desain |
|---|:---:|---|
| **ENERGY** | **2 (Balanced)** | Nuansa RPG gamified berenergi tinggi namun tetap elegan untuk produktivitas. Pancaran cahaya kristal kaca (frosted glass) berpadu dengan aksen emas guild dan aura neon tanpa membebani mata. |
| **RHYTHM** | **2 (Structured)** | Tata letak papan quest modular bergaya guild fantasy. Komponen tersusun dalam panel kaca kristal (glass cards) dengan padding terukur (16dp/18dp), radius melengkung 14–24dp, dan hierarki visual yang bersih. |
| **MOTION** | **2 (Tactile & Fluid)** | Animasi interaksi yang responsif, lentur, dan taktil. Transisi tab berdurasi 210ms dengan kurva `easeOutCubic`, sliding pill kalender 240ms, micro-spring touch feedback 180ms, dan efek bias pendaran kaca dinamis. |

---

## 2. Palet Warna & Token Visual (Dark Arcane Theme)

Quest Kalender menggunakan palet gelap bertema **Dark Arcane Glassmorphism (Midnight Obsidian & Luminous Gold)** dengan kepatuhan kontras aksesibilitas WCAG AA:

| Token | Nilai Hex | Peran Visual | Rasio Kontras pada Background |
|---|---|---|:---:|
| `primaryGold` | `#FFB300` | Aksen utama guild, tombol kristal utama (CTA), bintang reputasi, level-up highlight | 11.2:1 (Sangat Tinggi) |
| `accentAmber` | `#FF8F00` | Aksen hangat sekunder, badge peringatan, highlight transisi | 8.9:1 |
| `darkBackground` | `#0B0D1B` | Kanvas dasar gelap obsidian pekat | — |
| `cardBackground` | `#15192E` | Lapisan dasar surface kartu dan dialog | — |
| `surfaceLighter` | `#232845` | Border pemisah sekunder, elevasi chip netral | — |
| `textMuted` | `#B8BAC8` | Teks sekunder, metadata tanggal, keterangan label kecil (Slate Mist) | > 6.2:1 (Lolos WCAG AA) |
| `neonCyan` | `#00E5FF` | Mana kustomisasi, status offline lokal, atribut kecerdasan (INT), link avatar | 12.8:1 |
| `neonPurple` | `#D500F9` | Indikator progres Arcane EXP bar, aura nebula mistis | 4.8:1 |
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

---

## 5. Dark Arcane Glassmorphism System (Frosted Crystal UX)

Antarmuka Quest Kalender mengusung sentuhan **Dark Arcane Glassmorphism**: permukaan antarmuka membiaskan cahaya latar belakang seperti pelat kaca kristal buram magis (*frosted glass*), dipadukan dengan border kilau tipis (*specular border highlights*) dan pendaran aura RPG tembus pandang.

### A. Anatomi Visual Kaca Kristal (Frosted Glass Panel)
1. **Backdrop Filter Refraction:**
   - Setiap panel kartu utama, kalender, dialog, navbar, dan header dibungkus oleh `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10-18, sigmaY: 10-18))` dalam wadah `ClipRRect`.
   - Mengaburkan pendaran cahaya dari bola energi magis di latar belakang kanvas (`GuildBackdrop`), menghasilkan ilusi optik kedalaman lapisan 3D.
2. **Translucent Multi-stop Body:**
   - Gradasi translusen dari warna obsidian bersemprotan cahaya atas `Color(0xFF1E223D).withAlpha(165)` hingga dasar yang lebih gelap `Color(0xFF101326).withAlpha(195)`.
3. **Specular Gradient Borders (Kilauan Tepi):**
   - Garis batas halus (*hairline border*) berketebalan 1–1.2px dengan gradasi pantulan cahaya: sisi atas menerima kilauan kristal putih `Colors.white.withAlpha(55)`, sedangkan sisi bawah meluruh ke bayangan kaca `Colors.white.withAlpha(14)`.
   - Pada kartu beraksen (Gold, Cyan, Crimson, Violet), tepi kaca memancarkan glow neon halus (`accentColor.withAlpha(120)`).
4. **Recessed Glass Track (`glassRecessedDecoration`):**
   - Digunakan untuk wadah pencarian, slot metrik, limit EXP, dan rel indikator kalender. Menggunakan isian kaca gelap tembus pandang dengan batas tipis yang memberi efek terpasang rapi ke dalam panel.
5. **Glass Pills & Tokens (`glassPillDecoration`):**
   - Digunakan pada filter chip, indikator streak petualang, dan badge hadiah quest. Menghadirkan wujud seperti kancing kristal mini.
6. **Luminous Glass Buttons (`glassButtonDecoration`):**
   - Tombol utama CTA dan pilihan kalender aktif dengan gradasi emas kristal bercahaya dan bayangan pendar emas lembut (`primaryGold.withAlpha(80)`).

### B. Refraksi Latar Belakang Magis (Guild Backdrop Orbs)
Di balik kaca buram, latar belakang kanvas memancarkan 4 bola energi magis bergradasi radial:
- **Arcane Gold Orb:** Memancar di sudut kanan atas kalender.
- **Mystic Neon Cyan Orb:** Memancar di area tengah bawah papan quest.
- **Violet Nebula Orb:** Memancar di sisi kiri tengah dekat status petualang.
- **Emerald Vitality Orb:** Memancar di sudut kanan bawah guild board.

Saat pengguna menggulir atau beralih tab, pergerakan konten di atas bola-bola cahaya ini menciptakan refraksi cahaya dinamis yang hidup dan bernyawa.
