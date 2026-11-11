# Panduan Tanya-Jawab UTS / COTS — Bagian Thoriq (DyLeks Mobile)

Dokumen ini disusun khusus untuk **Thoriq** berdasarkan ketentuan **Aturan Teknis UTS PPB (Sub-CLO-3-1-1 Otomasi & Sub-CLO-3-1-2 Antarmuka)**, di mana dosen dapat menunjuk anggota kelompok secara acak untuk menjelaskan implementasi dan menunjukkan baris *source code* tertentu.

---

## Ringkasan Tanggung Jawab Thoriq (11 File)

Thoriq bertanggung jawab atas **Arsitektur Inti (Core), Penyimpanan Lokal, Text-to-Speech (TTS), Navigasi 5 Layar Utama, dan Integrasi Game**:

1. `lib/main.dart` — Titik masuk aplikasi (`main`), tema terang/gelap, dan skala ukuran teks global.
2. `lib/core/penyimpanan.dart` — Penyimpanan lokal dengan `SharedPreferences` (XP, Streak, Level, Lencana).
3. `lib/core/suara.dart` — Mesin suara Text-to-Speech (`flutter_tts`) Bahasa Indonesia.
4. `lib/core/komponen.dart` — Komponen UI bersama (`LayarGame`, `TombolBesar`, `TombolSuara`, `selesaiGame`).
5. `lib/core/data_materi.dart` — Struktur data 8 level dan bank soal/kata.
6. `lib/screens/onboarding_screen.dart` — Layar pengisian nama & pemilihan avatar (tanpa login).
7. `lib/screens/placement_screen.dart` — Kuis Tes Penempatan (5 soal) penentu level awal.
8. `lib/screens/home_screen.dart` — Layar Beranda (status Streak, XP, Lencana, Kartu Level Aktif, Peta 8 Level).
9. `lib/screens/stage_map_screen.dart` — Peta 5 Tahap zig-zag, Mode Bantuan (Scaffolding), dan perhitungan XP/Naik Level.
10. `lib/screens/settings_screen.dart` — Pengaturan (Mode Gelap, Ukuran Teks, Tes Suara, Mode Demo, Hapus Progres).
11. `lib/games/daftar_game.dart` — Penghubung nomor level (1–8) ke *widget* masing-masing game.

---

## Bagian 1: Pertanyaan Arsitektur & State Management (`lib/main.dart`)

### Q1: "Kenapa aplikasi ini tidak memakai Provider, Bloc, atau GetX? Bagaimana cara kalian mengubah tema gelap dan ukuran teks secara global?"
* **Lokasi Kode:** `lib/main.dart` (Baris 9 dan Baris 24–48)
* **Jawaban:**
  > "Kami sengaja menggunakan pendekatan bawaan Flutter yang ringan yaitu `ValueNotifier<int> perbaruiTampilan` (baris 9) yang dipasangkan dengan `ValueListenableBuilder` di dalam `DyleksApp` (baris 24). Ketika pengguna mengubah Mode Gelap atau Ukuran Teks di `SettingsScreen`, kami cukup memanggil `perbaruiTampilan.value++`. Hal itu memicu `ValueListenableBuilder` untuk membangun ulang `MaterialApp` dengan `themeMode` dan `textScaler` terbaru tanpa perlu *library state management* pihak ketiga."

### Q2: "Tunjukkan di kode bagian mana yang mengatur ukuran teks 100%, 115%, dan 125% agar berdampak ke semua layar!"
* **Lokasi Kode:** `lib/main.dart` (Baris 42–45)
* **Potongan Kode:**
  ```dart
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(Data.ukuranTeks)),
    child: child!,
  ),
  ```
* **Penjelasan:**
  > "Di properti `builder` milik `MaterialApp`, kami membungkus seluruh layar (`child!`) dengan `MediaQuery.copyWith` dan mengatur `textScaler: TextScaler.linear(Data.ukuranTeks)`. Jadi nilai `1.0`, `1.15`, atau `1.25` dari pengaturan otomatis mengalikan ukuran semua widget `Text` di seluruh aplikasi."

### Q3: "Kenapa fungsi `main()` menggunakan `async` dan `WidgetsFlutterBinding.ensureInitialized()`?"
* **Lokasi Kode:** `lib/main.dart` (Baris 11–17)
* **Penjelasan:**
  > "Karena sebelum `runApp()` dijalankan, aplikasi perlu melakukan operasi asinkron (`await`) yang mengakses *platform channel* Android, yaitu mengunci orientasi layar ke *portrait* (`SystemChrome.setPreferredOrientations`), membaca data dari memori HP (`Data.muat()`), dan menginisialisasi mesin suara (`Suara.siapkan()`). `WidgetsFlutterBinding.ensureInitialized()` wajib dipanggil agar komunikasi antara kode Dart dan sistem operasi Android siap sebelum `runApp`."

---

## Bagian 2: Penyimpanan Lokal & Gamifikasi (`lib/core/penyimpanan.dart`)

### Q4: "Aplikasi ini berjalan full offline tanpa database server. Bagaimana data progres anak disimpan?"
* **Lokasi Kode:** `lib/core/penyimpanan.dart` (Baris 39–68)
* **Jawaban:**
  > "Kami menggunakan *package* `shared_preferences` yang dibungkus dalam satu class `Data` dengan variabel dan *method* `static`. Saat aplikasi dibuka, `Data.muat()` membaca key-value dari penyimpanan lokal HP (seperti `nama`, `xp`, `streak`, `levelSekarang`, dan `tahapSelesai`). Setiap ada perubahan progres, kami memanggil `Data.simpan()` untuk menulisnya kembali ke memori HP."

### Q5: "Bagaimana cara menyimpan `List<int> tahapSelesai` ke `SharedPreferences`, padahal `SharedPreferences` tidak punya `setIntList`?"
* **Lokasi Kode:** `lib/core/penyimpanan.dart` (Baris 44–45 & Baris 60)
* **Potongan Kode:**
  ```dart
  // Saat simpan (baris 60): diubah dari List<int> menjadi List<String>
  await _prefs.setStringList('tahapSelesai', tahapSelesai.map((e) => '$e').toList());

  // Saat muat (baris 44-45): diubah kembali dari List<String> menjadi List<int>
  final tahap = _prefs.getStringList('tahapSelesai');
  tahapSelesai = tahap == null ? List.filled(8, 0) : tahap.map(int.parse).toList();
  ```
* **Penjelasan:**
  > "Karena `SharedPreferences` hanya mendukung `List<String>` (`setStringList`), saat menyimpan kami mengonversi setiap angka menjadi `String` dengan `.map((e) => '$e').toList()`. Saat memuat kembali di `Data.muat()`, kami mengubahnya balik ke `int` menggunakan `.map(int.parse).toList()`."

### Q6: "Jelaskan logika otomasi Streak harian! Bagaimana sistem tahu kalau streak harus bertambah, tidak bertambah dua kali sehari, atau hangus (padam)?"
* **Lokasi Kode:** `lib/core/penyimpanan.dart` (Baris 76–100)
* **Penjelasan:**
  1. **Mencegah tambah 2x di hari yang sama:** Di `tambahStreak()` (baris 91), dicek `if (tanggalStreak == hariIni) return;`. Jika hari ini sudah pernah main, streak tidak bertambah lagi.
  2. **Menyambung streak:** Jika `tanggalStreak == kemarin`, maka `streak++`. Jika tidak, `streak` mulai dari `1`.
  3. **Mengecek streak padam:** Saat aplikasi baru dibuka, `cekStreakPadam()` (baris 81–86) memeriksa apakah `tanggalStreak` bukan `hariIni` dan bukan `kemarin`. Jika sudah lewat lebih dari 1 hari tidak bermain, `streak` di-reset menjadi `0`, tetapi `rekorStreak` tetap tersimpan.

---

## Bagian 3: Otomasi Text-to-Speech Bahasa Indonesia (`lib/core/suara.dart`)

### Q7: "Bagaimana cara kalian memastikan suara TTS menggunakan Bahasa Indonesia dan ramah untuk anak disleksia?"
* **Lokasi Kode:** `lib/core/suara.dart` (Baris 21–87)
* **Penjelasan:**
  1. **Memilih Engine Google TTS:** Di Android (baris 40–47), aplikasi memeriksa apakah mesin `com.google.android.tts` tersedia, lalu mengaktifkannya.
  2. **Filter Suara Bahasa Indonesia:** Di baris 49–62, aplikasi mengambil daftar suara perangkat (`_tts.getVoices`) dan mencari suara yang memiliki *locale* `id-ID` / `in-ID` atau bernama `Indonesia` / `Gadis` / `Andika`.
  3. **Kecepatan Bicara Lambat:** Di baris 84, kecepatan bicara diatur lambat (`setSpeechRate(0.4)` di Android) dengan `setPitch(1.1)` agar pelafalan suku kata terdengar jelas bagi anak disleksia.
  4. **Kamus Pelafalan Fonetik (`_pelafalan`, baris 21–24):** Huruf konsonan tunggal seperti `'b'`, `'d'`, `'p'`, `'q'` dan digraf `'ng'`, `'ny'`, `'sy'`, `'kh'` dipetakan ke bunyi fonetiknya (`'be'`, `'de'`, `'pe'`, `'ki'`, `'eng'`, `'nya'`) supaya TTS tidak mengejanya dengan logat Inggris.

---

## Bagian 4: Komponen Bersama & Komunikasi Antar-Layar (`lib/core/komponen.dart`)

### Q8: "Bagaimana cara 8 game buatan anggota tim mengirim hasil menang/kalah ke layar Peta Tahap milik Thoriq?"
* **Lokasi Kode:** `lib/core/komponen.dart` (Baris 9–20) & `lib/screens/stage_map_screen.dart` (Baris 60–66)
* **Penjelasan:**
  > "Kami membuat kontrak data melalui class `HasilGame` yang berisi 3 properti: `menang` (`bool`), `salah` (`int`), dan `dibantu` (`bool`). Saat permainan di game mana pun selesai, game tersebut memanggil fungsi `selesaiGame(context, menang: ..., salah: ..., dibantu: ...)` yang di dalamnya menjalankan `Navigator.pop(context, HasilGame(...))`. Di `StageMapScreen`, hasil kembalian dari `await Navigator.push<HasilGame>(...)` tersebut langsung ditangkap dan diolah oleh fungsi `_prosesHasil()`."

### Q9: "Bagaimana cara mencegah anak tidak sengaja menekan tombol Back di HP saat sedang di tengah permainan?"
* **Lokasi Kode:** `lib/core/komponen.dart` (Baris 47–51)
* **Penjelasan:**
  > "Semua game dibungkus oleh widget `LayarGame` yang menggunakan `PopScope(canPop: false, ...)`. Ketika anak menekan tombol Back sistem Android atau tombol silang di `AppBar`, navigasi keluar ditahan dan fungsi `_konfirmasiKeluar()` memunculkan `AlertDialog` konfirmasi terlebih dahulu."

---

## Bagian 5: Alur Layar Utama (`lib/screens/`)

### Q10: "Jelaskan aturan penentuan level awal di Tes Penempatan (`PlacementScreen`)!"
* **Lokasi Kode:** `lib/screens/placement_screen.dart` (Baris 74–85) & `lib/core/penyimpanan.dart` (Baris 118–124)
* **Penjelasan:**
  - Ada 5 soal (4 soal audio dengar-pilih dan 1 soal visual ejaan).
  - Jika benar semua (**5 poin**) -> mulai dari **Tingkat 6**.
  - Jika benar **3–4 poin** -> mulai dari **Tingkat 3**.
  - Jika benar **0–2 poin** (atau memilih tombol *Lewati*) -> mulai dari **Tingkat 1**.
  - Fungsi `Data.aturLevelAwal(level)` memastikan semua tingkat di bawah level awal otomatis ditandai selesai 5/5 tahap (`tahapSelesai[i] = 5`), dan memiliki proteksi `if (level <= levelSekarang) return;` sehingga jika anak mengulangi tes penempatan dari menu Pengaturan dengan skor lebih rendah, level yang sudah dicapai **tidak akan pernah turun**.

### Q11: "Di `StageMapScreen`, bagaimana cara kalian membuat tampilan 5 tombol tahap berpola zig-zag seperti Duolingo?"
* **Lokasi Kode:** `lib/screens/stage_map_screen.dart` (Baris 22 & Baris 157–164)
* **Potongan Kode:**
  ```dart
  final List<double> _geserX = [0, 40, 0, -40, 0];
  ```
* **Penjelasan:**
  > "Kami menyiapkan daftar offset horizontal `_geserX = [0, 40, 0, -40, 0]`, lalu di dalam perulangan `for (int tahap = 1; tahap <= 5; tahap++)` kami membungkus setiap lingkaran tahap (`_nodeTahap`) dengan widget `Transform.translate(offset: Offset(_geserX[tahap - 1], 0))`. Dengan begitu, tahap 1 berada di tengah (`0`), tahap 2 bergeser ke kanan (`+40`), tahap 3 di tengah (`0`), tahap 4 ke kiri (`-40`), dan tahap 5 kembali di tengah (`0`)."

### Q12: "Jelaskan rumus perhitungan XP, Mode Bantuan (Scaffolding), dan syarat Naik Level di `StageMapScreen`!"
* **Lokasi Kode:** `lib/screens/stage_map_screen.dart` (Baris 50–108)
* **Penjelasan:**
  1. **Mode Bantuan Otomatis (Baris 54–57):** Jika pada suatu tahap anak gagal 3 kali berturut-turut (`Data.gagalBeruntun[kunci] >= 3`), sebelum masuk ke game sistem memunculkan dialog `tawarkanBantuan(context)`. Jika anak memilih *Ya*, parameter `bantuan: true` dikirim ke `buatGame()` untuk menyederhanakan soal (misal di Game 1 opsi jawaban dikurangi dari 5 menjadi 3, di Game 7 meteor diperlambat).
  2. **Perhitungan XP (Baris 74–83 & 103–105):**
     - Menang di tahap yang baru terbuka (`status == 'aktif'`): **+20 XP**.
     - Menang saat mengulang tahap lama (`status == 'selesai'`): **+10 XP**.
     - Bonus Sempurna (`hasil.salah == 0 && !hasil.dibantu`): tambahan **+5 XP**.
     - Gagal/kalah tetapi menyelesaikan permainan sampai akhir: tetap diberi apresiasi **+2 XP usaha** agar anak tidak patah semangat.
  3. **Syarat Naik Level (Baris 86–94):**
     - Setiap menyelesaikan tahap berstatus `'aktif'`, nilai `Data.tahapSelesai[widget.level - 1]` bertambah 1.
     - Saat nilainya mencapai `5` (kelima tahap selesai) pada level tertinggi saat ini (`widget.level == Data.levelSekarang`) dan belum mencapai level 8, maka `Data.levelSekarang++` dieksekusi untuk membuka level berikutnya.

---

## Bagian 6: Jembatan Integrasi Game (`lib/games/daftar_game.dart`)

### Q13: "Bagaimana `StageMapScreen` membuka game yang berbeda untuk tiap level?"
* **Lokasi Kode:** `lib/games/daftar_game.dart` (Baris 17–35)
* **Penjelasan:**
  > "Melalui fungsi `Widget buatGame(int level, int tahap, bool bantuan)` yang menggunakan `switch (level)` untuk mengembalikan *instance widget* game yang sesuai (Level 1 -> `LatihanBertahapGame`, Level 2 -> `PetualanganHurufGame`, dst. sampai Level 8 -> `MorphemeBridgeGame`). Dengan memisahkan pemetaan ini di satu file `daftar_game.dart`, kode `StageMapScreen` tetap bersih dan tidak bergantung langsung pada implementasi internal tiap game."

---

## Bagian 7: Desain Gamifikasi Duolingo & Aksesibilitas Disleksia (Sub-CLO-3-1-2)

### Q14: "Bagaimana implementasi desain ala Duolingo dan pertimbangan aksesibilitas disleksia pada antarmuka aplikasi?"
* **Lokasi Kode:** `lib/core/komponen.dart` (`Tombol3D`), `lib/main.dart` (Tema & Kanvas), dan `lib/screens/stage_map_screen.dart`
* **Penjelasan:**
  1. **Tombol 3D Taktil (`Tombol3D`):** Tombol memiliki ketebalan bibir bawah 4px dengan fungsi `hitungWarnaBayangan()` otomatis. Menggunakan `GestureDetector` dengan animasi respon klik turun 3px saat disentuh (*tactile response*) yang memberikan kepuasan motorik bagi anak-anak.
  2. **Kanvas Anti-Silau (`#FAF8FD`):** Alih-alih warna putih murni (`#FFFFFF`), latar belakang menggunakan warna krem lavender lembut untuk mencegah *glare* (pantulan silau) yang memicu *visual stress* pada pembaca disleksia.
  3. **Palet Warna Gamifikasi Core Ungu (`#7C3AED`):** Dipadukan dengan warna fungsional (Emas XP `#F59E0B`, Hijau Sukses `#10B981`, Merah Korektif `#EF4444`, dan Biru Edukasi `#06B6D4`) untuk memandu fokus perhatian anak secara intuitif.
  4. **Peta Batu Loncatan Ber-Tag 'MULAI!':** Tahap aktif ditandai dengan batu loncatan 3D bercahaya dan tag melayang animatif, sementara tahap selesai diberi bintang emas prestasi.
