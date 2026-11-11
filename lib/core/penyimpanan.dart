import 'package:shared_preferences/shared_preferences.dart';

// ===============================================
// PENYIMPANAN DATA DI HP (tanpa server, tanpa login)
// Semua data disimpan pakai shared_preferences.
// Dipakai lewat: Data.nama, Data.xp, Data.simpan(), dll.
// ===============================================

class Data {
  static late SharedPreferences _prefs;

  // ---- Profil ----
  static String nama = '';
  static String avatar = 'milo';

  // ---- Progres ----
  static int levelSekarang = 1; // level tertinggi yang terbuka (1-8)
  // tahapSelesai[0] = jumlah tahap selesai di level 1, dst (0-5)
  static List<int> tahapSelesai = List.filled(8, 0);

  // ---- Gamifikasi ----
  static int xp = 0;
  static int streak = 0;
  static int rekorStreak = 0;
  static String tanggalStreak = ''; // tanggal terakhir streak bertambah
  static List<String> lencana = [];

  // ---- Pengaturan ----
  static bool temaGelap = false;
  static double ukuranTeks = 1.0; // 1.0 = normal, 1.2 = besar, 1.4 = ekstra besar

  // Penghitung gagal beruntun per tahap (untuk mode bantuan).
  // Tidak disimpan permanen supaya sederhana.
  static Map<String, int> gagalBeruntun = {};

  static bool get sudahDaftar => nama.isNotEmpty;

  // gunanya adalah untuk memanggil SharedPreferences.getInstance() sekali saja saat app dibuka
  static Future<void> muat() async {
    // SharedPreferences.getInstance() itu async, jadi harus pakai await
    _prefs = await SharedPreferences.getInstance();
    // Muat semua data dari penyimpanan ke variabel statis
    nama = _prefs.getString('nama') ?? '';
    // kalau belum ada nama, pakai string kosong
    avatar = _prefs.getString('avatar') ?? 'milo';
    // kalau belum ada avatar, pakai emoji kucing
    levelSekarang = _prefs.getInt('levelSekarang') ?? 1;
    // kalau belum ada levelSekarang, pakai 1
    final tahap = _prefs.getStringList('tahapSelesai');
    // kalau belum ada tahapSelesai, pakai List.filled(8, 0)
    tahapSelesai = tahap == null ? List.filled(8, 0) : tahap.map(int.parse).toList();
    // kalau ada, ubah dari List<String> ke List<int>
    xp = _prefs.getInt('xp') ?? 0;
    streak = _prefs.getInt('streak') ?? 0;
    rekorStreak = _prefs.getInt('rekorStreak') ?? 0;
    tanggalStreak = _prefs.getString('tanggalStreak') ?? '';
    lencana = _prefs.getStringList('lencana') ?? [];
    temaGelap = _prefs.getBool('temaGelap') ?? false;
    ukuranTeks = _prefs.getDouble('ukuranTeks') ?? 1.0;
    cekStreakPadam();
  }
// Dipanggil saat app ditutup atau data berubah
  static Future<void> simpan() async {
    // ini gunanya untuk menyimpan semua variabel statis ke penyimpanan permanen
    await _prefs.setString('nama', nama);
    // kalau nama kosong, akan disimpan string kosong
    await _prefs.setString('avatar', avatar);
    // ini gunanya untuk menyimpan semua variabel statis ke penyimpanan permanen
    await _prefs.setInt('levelSekarang', levelSekarang);
    // ini gunanya untuk menyimpan semua variabel statis ke penyimpanan permanen
    await _prefs.setStringList('tahapSelesai', tahapSelesai.map((e) => '$e').toList());
    // ini kode untuk mengubah List<int> ke List<String> sebelum disimpan
    await _prefs.setInt('xp', xp);
    await _prefs.setInt('streak', streak);
    await _prefs.setInt('rekorStreak', rekorStreak);
    await _prefs.setString('tanggalStreak', tanggalStreak);
    await _prefs.setStringList('lencana', lencana);
    await _prefs.setBool('temaGelap', temaGelap);
    await _prefs.setDouble('ukuranTeks', ukuranTeks);
  }

  // kode untuk menghapus semua data (dipakai saat reset)
  static Future<void> hapusSemua() async {
    await _prefs.clear();
    await muat();
  }
  // maka yang terjadi adalah method ini tidak bisa dipanggil tanpa membuat instance dari class Data, sehingga akan sulit untuk menghapus semua data secara global. Dengan tetap menggunakan static, kita bisa memanggil Data.hapusSemua() dari mana saja tanpa harus membuat objek Data baru.

  // ---------- Tanggal ----------
  static String _tanggal(DateTime t) => '${t.year}-${t.month}-${t.day}';
  // Gunanya adalah untuk menyimpan tanggal dalam format "YYYY-M-D" tanpa jam, menit, detik. Ini memudahkan perbandingan tanggal.
  static String get hariIni => _tanggal(DateTime.now());
  static String get kemarin => _tanggal(DateTime.now().subtract(const Duration(days: 1)));

  // Saat app dibuka: kalau terakhir main sebelum kemarin, streak padam.
  static void cekStreakPadam() {
    if (tanggalStreak.isEmpty) return;
    if (tanggalStreak != hariIni && tanggalStreak != kemarin) {
      streak = 0;
    }
  }

  // Dipanggil saat anak menyelesaikan 1 tahap.
  // Main 2x di hari yang sama hanya menambah streak 1x.
  static void tambahStreak() {
    if (tanggalStreak == hariIni) return;
    if (tanggalStreak == kemarin) {
      streak++;
    } else {
      streak = 1;
    }
    tanggalStreak = hariIni;
    if (streak > rekorStreak) rekorStreak = streak;
    if (streak >= 3) bukaLencana('streak');
  }

  // Mengembalikan true kalau lencana baru terbuka
  static bool bukaLencana(String id) {
    if (lencana.contains(id)) return false;
    lencana.add(id);
    return true;
  }

  // Status tahap: 'selesai', 'aktif', atau 'kunci'
  static String statusTahap(int level, int tahap) {
    final selesai = tahapSelesai[level - 1];
    if (tahap <= selesai) return 'selesai';
    if (tahap == selesai + 1) return 'aktif';
    return 'kunci';
  }

  // Dipakai tes penempatan: level di bawahnya dianggap selesai
  static void aturLevelAwal(int level) {
    if (level <= levelSekarang) return; // tidak pernah turun
    levelSekarang = level;
    for (int i = 0; i < level - 1; i++) {
      tahapSelesai[i] = 5;
    }
  }
}
