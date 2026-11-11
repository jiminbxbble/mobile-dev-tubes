# DyLeks Mobile — Tugas Besar PPB (CCK3AAB3)

Aplikasi game belajar membaca bergaya **Gamifikasi Duolingo** yang dirancang khusus untuk **anak disleksia**. Berjalan **offline penuh**, tanpa login, dengan aksesibilitas ramah kognitif.

> 📖 **PENTING**: Sebelum merubah atau menambahkan kode, wajib membaca dan memperbarui [GEMINI.md](file:///H:/Thoriq%20Kuiah/Semester%204/CCK3AAB3%20-%20Pemrograman%20Perangkat%20Bergerak/Week%2008/TUBES/dyleks_mobile/GEMINI.md) sesuai aturan kerja **Documentation-First Protocol**.

---

## 🎨 Karakteristik Desain & Gamifikasi (Gaya Duolingo)

1. **Warna Core**: **Ungu Royal (`#7C3AED`)** dipadukan dengan palet gamifikasi harmonik:
   - **Emas Juara (`#F59E0B`)**: Skor XP, lencana piala, bintang prestasi, dan api streak.
   - **Hijau Sukses (`#10B981`)**: Jawaban benar, tombol konfirmasi lanjut, dan status selesai.
   - **Merah Korektif (`#EF4444`)**: Jawaban salah dan pengurang HP perisai.
   - **Biru Edukatif (`#06B6D4`)**: Tombol pengucapan audio TTS dan panduan mode bantuan.
   - **Kanvas Anti-Silau (`#FAF8FD`)**: Mencegah pantulan silau (*glare*) yang memicu *visual stress* pada disleksia.
2. **Viewport Ponsel Responsif (*Responsive Smartphone Viewport*)**:
   - Di monitor desktop / web, aplikasi otomatis dibungkus rapi dalam frame ponsel cerdas modern (`maxWidth: 430px`) berpusat di tengah layar dengan drop shadow elegan, mencegah distorsi melar.
3. **Tombol 3D Taktil & Ubin Kuis (`Tombol3D` / `TombolBesar` / `KartuTaktil`)**:
   - Memiliki ketebalan bibir bawah 4px dengan animasi respon amblas taktil saat disentuh.
4. **Jalur Batu Loncatan Berkelok Duolingo (*S-Curve Stepping Path*)**:
   - Peta belajar 8 tingkat dan peta 5 tahap petualangan dengan batu loncatan 3D, tag melayang *"MULAI!"*, maskot burung hantu 🦉 Leko, mahkota emas 👑, dan peti bonus XP 🎁.
5. **Bilah Navigasi Bawah 4 Tab (*Duolingo Bottom Bar*)**:
   - Tab Belajar (Jalur Peta), Tab Lencana (Piala 3D), Tab Misi (Misi Harian XP), dan Tab Setelan (Aksesibilitas & Font Disleksia).
6. **State Management Ringan**:
   - Menggunakan `ValueNotifier<int> perbaruiTampilan` dan `StatefulWidget` agar kode bersih dan mudah dijelaskan saat ujian COTS tanpa dependensi provider rumit.

---

## 🚀 Cara Menjalankan

```bash
cd dyleks_mobile
flutter pub get
flutter run
```

### Verifikasi Kode (Wajib 0 Issue Sebelum Push)

```bash
flutter analyze
flutter test
```

---

## 📂 Struktur Proyek

```text
lib/
├── main.dart                 # Titik awal app, tema ungu, TextScaler global
├── core/                     # Bagian bersama (Core Architecture)
│   ├── data_materi.dart      # Bank materi 8 level & konfigurasi warna
│   ├── penyimpanan.dart      # Class Data (SharedPreferences: XP, streak, level)
│   ├── suara.dart            # Text-to-speech Bahasa Indonesia & kamus fonetik
│   └── komponen.dart         # Tombol3D, LayarGame, KapsulStat, dialog bantuan
├── screens/                  # Layar utama aplikasi
│   ├── onboarding_screen.dart# Registrasi nama + avatar 3D tanpa login
│   ├── placement_screen.dart # Tes penempatan 5 soal
│   ├── home_screen.dart      # Beranda, kapsul stat, hero level, 8 jalur game
│   ├── stage_map_screen.dart # Peta 5 tahap zig-zag, aturan XP & naik level
│   └── settings_screen.dart  # Pengaturan font disleksia, mode demo, tes suara
└── games/                    # 8 Minigame mandiri (1 file = 1 game)
    ├── daftar_game.dart      # Router penghubung level -> game
    └── game1_... s/d game8_...
```

---

## 👥 Alur Kolaborasi Tim

Pembagian tugas dan panduan tanya-jawab COTS:
* Aturan Git & pembagian pengerjaan lengkap di [`PEMBAGIAN.md`](file:///H:/Thoriq%20Kuiah/Semester%204/CCK3AAB3%20-%20Pemrograman%20Perangkat%20Bergerak/Week%2008/TUBES/dyleks_mobile/PEMBAGIAN.md).
* Panduan pertanyaan ujian dosen ada di [`cots-QNA.md`](file:///H:/Thoriq%20Kuiah/Semester%204/CCK3AAB3%20-%20Pemrograman%20Perangkat%20Bergerak/Week%2008/TUBES/dyleks_mobile/cots-QNA.md).
