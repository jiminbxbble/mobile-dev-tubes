# 🎮 GEMINI.md — Pedoman Arsitektur, Desain, & Standar Kerja DyLeks Mobile

> **Dokumen Panduan Tunggal (*Single Source of Truth*)** untuk pengembangan aplikasi **DyLeks Mobile** (Tugas Besar / UTS CCK3AAB3 Pemrograman Perangkat Bergerak, Semester 4 Rekayasa Perangkat Lunak).

---

## 📌 1. Aturan Emas Pengerjaan: *Documentation-First Protocol*

Dalam proyek ini, ditetapkan aturan kedisiplinan rekayasa perangkat lunak tingkat lanjut:

1. **Dokumentasi Dahulu, Baru Kode (*Spec-First Principle*)**:
   - Dilarang keras memodifikasi atau menulis kode sebelum spesifikasi logika, dampak arsitektur, dan alur UI tercatat dalam dokumentasi (`GEMINI.md` / `README.md`).
   - Setiap ide fitur baru wajib diawali dengan pendefinisian input, output, state, dan tampilan visual.
2. **Sinkronisasi Ganda (*Dual-Sync Rule*)**:
   - Setiap kali terjadi perubahan fitur, modifikasi palet warna, penambahan soal materi, atau refaktorisasi widget, file dokumentasi terkait **wajib diperbarui secara bersamaan**.
3. **Standar Bebas Duplikasi (*DRY - Don't Repeat Yourself*)**:
   - Logika umum (penyimpanan data, suara TTS, komponen tombol 3D, evaluasi skor) wajib diletakkan di dalam folder `lib/core/` dan dilarang dibuat ulang di dalam masing-masing file game.
4. **Verifikasi Tanpa Cacat (*Zero-Issue Linting & Test*)**:
   - Setiap kode yang selesai dikerjakan wajib lulus uji `flutter analyze` (0 issue) dan `flutter test` (100% pass) sebelum boleh diserahkan ke anggota tim.

---

## 🎨 2. Spesifikasi Desain Gamifikasi Duolingo AAA (Total Revamp)

Aplikasi **DyLeks Mobile** mengadopsi bahasa visual **Gamifikasi Duolingo AAA** yang ramah anak disleksia (*Dyslexia-Friendly UI*), berenergi tinggi, dan taktil:

### A. Arsitektur Kanvas Ponsel Responsif (*Responsive Smartphone Viewport*)
- **Desktop/Web Viewport**: Di layar browser (lebar > 500px), aplikasi dibungkus dalam **Frame Ponsel Modern (`width: 430px`, `height: 890px`)** di tengah layar dengan sudut melengkung 38px, bezel luar 6px `#31285E`, dan ambient drop shadow gelap `#110D24`. Di layar smartphone fisik, aplikasi mengisi layar secara penuh (100% native).
- **Mencegah Distorsi**: Mencegah tombol, input, dan kartu melar pipih di monitor desktop, memberikan rasa memegang smartphone nyata.

### B. Palet Warna Gamifikasi Taktil
| Token Warna | Hex Code | Elemen & Karakter Visual |
| :--- | :--- | :--- |
| **Ungu Utama (*Primary Face*)** | `#7C3AED` | Royal Violet Duolingo ceria untuk header, ubin aktif, & tombol primer. |
| **Ungu Tebal (*3D Base*)** | `#5B21B6` | Bibir 3D bawah (4px) untuk kedalaman fisik taktil saat ditekan. |
| **Emas Juara (*Gold Amber*)** | `#F59E0B` (Base: `#D97706`) | XP, Mahkota Level Selesai 👑, Bintang Prestasi ⭐, Peti Harta 🎁. |
| **Hijau Sukses (*Mint Emerald*)** | `#10B981` (Base: `#059669`) | Umpan Balik Benar, Tombol Lanjut, Banner Sukses, Checkmark. |
| **Merah Korektif (*Coral Rose*)** | `#EF4444` (Base: `#DC2626`) | Koreksi Ramah, Nyawa / Heart counter, Jawaban Salah. |
| **Biru Edukatif (*Electric Cyan*)** | `#06B6D4` (Base: `#0891B2`) | Tombol Suara TTS Pelafalan, Mode Bantuan Scaffolding. |
| **Kanvas Anti-Silau** | `#FAF8FD` (Light) / `#13111C` (Dark) | Mencegah *visual stress* & silau putih murni pada mata anak disleksia. |
| **Garis Kartun Tebal** | `#E5E7EB` / `#DDD6FE` | Border tegas 2.0px - 2.5px agar bentuk huruf & kartu mudah dibedakan. |

---

## 🕹️ 3. Arsitektur Komponen UI & Alur Interaksi

### 1. `HomeScreen` (Pusat Pembelajaran & Navigasi Utama)
- **Top Bar (`HeaderGamifikasi`)**:
  - Kapsul `🔥 Streak` harian (membuka popup modal kalender api).
  - Kapsul `⭐ XP` terkumpul.
  - Kapsul `❤️ Nyawa / Energi` (5/5).
- **Unit Banner Duolingo**:
  - Header bertingkat "BAGIAN 1 · TINGKAT 1-8: DASAR MEMBACA".
  - Kartu unit 3D dengan tombol "Panduan Materi 📖".
- **Jalur Batu Loncatan Berkelok (*Serpentine S-Curve Stepping Stones*)**:
  - Menggunakan `CustomPainter` untuk menggambar garis jalur tebal menghubungkan antar batu loncatan.
  - Batu loncatan bulat 3D (`width: 76`, `height: 76`):
    - **Selesai**: Emas Juara `#F59E0B` dengan Mahkota 👑 atau Bintang 3.
    - **Aktif**: Ungu Utama `#7C3AED` dengan tooltip melayang `"MULAI!"` dan maskot 🦉 Leko menyemangati di samping.
    - **Terkunci**: Abu-abu kartun `#E5E7EB` dengan ikon gembok 🔒.
  - Peti Harta Karun 🎁 diselingi di antara level untuk reward bonus XP.
- **Bilah Navigasi Bawah (*Duolingo Bottom Navigation Bar*)**:
  - Tab 0: 🏠 **Belajar** (Jalur Peta Pembelajaran Berkelok).
  - Tab 1: 🏆 **Lencana** (Galeri Piala & Koleksi Lencana 3D).
  - Tab 2: 🎯 **Misi** (Misi Harian: Latihan 1 Tahap, Skor Sempurna, Streak Harian).
  - Tab 3: ⚙️ **Pengaturan** (Aksesibilitas Disleksia, Ukuran Font, Suara TTS, Profil).

### 2. `StageMapScreen` (Peta 5 Tahap Petualangan)
- Menampilkan 5 tahap bertahap dengan batu loncatan 3D zig-zag.
- Menekan tahap aktif memunculkan Bottom Sheet Duolingo dengan target XP (+20 XP), deskripsi ramah, dan tombol 3D `"MULAI TAHAP X 🚀"`.
- Mode Bantuan otomatis aktif jika gagal 3 kali berturut-turut.

### 3. `OnboardingScreen` (Pendaftaran Interaktif & Seleksi 3 Maskot Nano Banana)
- Maskot 🦉 Leko dalam gelembung sapaan animasi melayang: *"Hai! Aku Leko. Siapa namamu?"*.
- Input nama besar dengan border ungu tegas.
- **Pilihan 3 Sahabat Belajar 3D (Nano Banana)**:
  1. `avatar_leko.png`: **Leko (Burung Hantu Cerdas)** — Karakter Pintar & Teliti (Fokus Fonem & Membaca).
  2. `avatar_milo.png`: **Milo (Kucing Oranye Ceria)** — Karakter Berani & Cepat (Fokus Tantangan Kuis).
  3. `avatar_kiko.png`: **Kiko (Panda Ramah Lucu)** — Karakter Sabar & Lembut (Fokus Latihan Perlahan & Kinestik).
- Kartu seleksi taktil 3D dengan animasi bounce saat dipilih dan penanda centang aktif.
- Tombol 3D `"MULAI PETUALANGAN! 🚀"` (menggunakan `TombolBesar` agar kompatibel dengan widget testing).

### 4. `PlacementScreen` (Tes Penempatan Diagnostik 5 Soal)
- Bilah progres halus membulat di bagian atas.
- Gelembung soal suara dengan `TombolSuara`.
- Ubin opsi `KartuTaktil` 3D (normal -> terpilih -> periksa).
- Bottom Sheet umpan balik hijau/merah saat tombol "PERIKSA" ditekan.

### 5. 8 Minigame Edukatif Disleksia
- Dibangun dengan layout `LayarGame` konsisten: tombol tutup aman `(X)`, bilah progres soal, dan ubin interaktif.

---

## 🎬 4. Spesifikasi Animasi Gamifikasi & Aset Maskot Nano Banana

Untuk memberikan pengalaman emosional yang hangat, menyenangkan, dan imersif (*Delightful UX*) bagi anak disleksia, aplikasi dilengkapi dengan sistem animasi gamifikasi berbasis aset visual **Nano Banana (Google DeepMind Image Generation)**:

### A. Matriks Pose & Emosi Maskot Leko
| File Aset | Karakteristik Visual Nano Banana | Konteks Penggunaan & Perilaku Animasi |
| :--- | :--- | :--- |
| `leko_idle.png` | Leko berdiri ramah dengan mata berbinar bulat besar. | **Floating Idle**: Melayang naik-turun halus (±6px) di samping batu loncatan aktif di Peta Belajar. |
| `leko_cheer.png` | Leko melompat gembira merayakan kemenangan mengangkat kedua sayap dengan bintang di matanya. | **Celebration Bounce**: Efek melenting (*elastic pop scale* 0.8 -> 1.15 -> 1.0) pada dialog selesai tahap/level. |
| `leko_reading.png` | Leko memegang buku terbuka dengan kacamata baca pintar. | Tampil di dialog Panduan Materi Unit 1 dan layar selamat datang Onboarding. |
| `leko_streak.png` | Leko memegang obor api belajar emas membara. | **Breathing Glow**: Tampil berdenyut hangat di modal Api Belajar Harian. |
| `chest_gold_3d.png` | Peti harta karun emas 3D Duolingo dengan aksen ungu. | **Wiggle Shake**: Bergoyang saat ditekan dan meledakkan partikel bonus XP. |

### B. Primitif Komponen Animasi Flutter (`lib/core/komponen_animasi.dart`)
1. **`AnimasiMelayang` (`FloatingBobbing`)**:
   - Menerapkan kurva sinusoidal `Curves.easeInOut` dengan siklus 2000ms untuk efek mengambang gravitasi nol.
2. **`AnimasiRayakan` (`CelebrationBounce`)**:
   - Menggunakan `Curves.elasticOut` berdurasi 900ms untuk efek lonjakan perayaan kemenangan.
3. **`AnimasiDenyut` (`PulseGlow`)**:
   - Efek denyut skala halus (1.0 - 1.08) untuk memikat perhatian anak pada elemen yang perlu disentuh (Call to Action).

---

## 👥 5. Distribusi Tanggung Jawab Tim (Sesuai Git Branch)

| Anggota | Peran & Layar Utama | Modul Game | File Commit |
| :--- | :--- | :--- | :--- |
| **Thoriq (Lead)** | Arsitektur Inti, Database Lokal, Mesin TTS, Beranda, & Peta Tahap | Core Framework & Router | `main.dart`, `core/` (5 file), `home_screen.dart`, `stage_map_screen.dart`, `daftar_game.dart` |
| **Raisha** | Layar Pendaftaran Nama + Avatar 3D | Level 1 (Vokal) & Level 2 (Memori) | `onboarding_screen.dart`, `game1_...`, `game2_...` |
| **Annisa** | Layar Pengaturan Aksesibilitas Disleksia | Level 3 (Tracer b/d/p/q) & Level 4 (Bicara AI) | `settings_screen.dart`, `game3_...`, `game4_...` |
| **Rafikah** | Layar Tes Penempatan Kemampuan Membaca | Level 5 (Labirin), 6 (Balon), 7 (Shield), 8 (Morfem) | `placement_screen.dart`, `game5_...`, `game6_...`, `game7_...`, `game8_...` |
