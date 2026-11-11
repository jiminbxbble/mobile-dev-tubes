import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import 'settings_screen.dart';
import 'stage_map_screen.dart';

// ===============================================
// BERANDA GAMIFIKASI DUOLINGO AAA (DYLEKS MOBILE)
// 4 Tab Navigasi: Belajar (Jalur Berkelok), Lencana,
// Misi Harian, dan Pengaturan Aksesibilitas.
// ===============================================

class LencanaDef {
  final String nama;
  final IconData ikon;
  final String desc;
  final Color warna;
  const LencanaDef(this.nama, this.ikon, this.desc, this.warna);
}

const Map<String, LencanaDef> dataLencanaLengkap = {
  'level1': LencanaDef('Master Vokal', Icons.record_voice_over_rounded, 'Selesaikan Tingkat 1: Latihan Vokal Tunggal', Color(0xFF7C3AED)),
  'level2': LencanaDef('Ahli Memori', Icons.style_rounded, 'Selesaikan Tingkat 2: Pasangan Huruf & Visual', Color(0xFF10B981)),
  'level3': LencanaDef('Penjiplak Handal', Icons.draw_rounded, 'Selesaikan Tingkat 3: Tracer Kinestik b/d/p/q', Color(0xFFF59E0B)),
  'level4': LencanaDef('Pahlawan Bicara', Icons.mic_rounded, 'Selesaikan Tingkat 4: Pelafalan Fonem AI', Color(0xFFF43F5E)),
  'level5': LencanaDef('Penjelajah Labirin', Icons.explore_rounded, 'Selesaikan Tingkat 5: Labirin Arah Spasial', Color(0xFF06B6D4)),
  'level6': LencanaDef('Pemecah Gelembung', Icons.bubble_chart_rounded, 'Selesaikan Tingkat 6: Letuskan Balon Suku Kata', Color(0xFF9333EA)),
  'level7': LencanaDef('Benteng Ejaan', Icons.shield_rounded, 'Selesaikan Tingkat 7: Sight Word Shield', Color(0xFF0D9488)),
  'level8': LencanaDef('Arsitek Morfem', Icons.account_tree_rounded, 'Selesaikan Tingkat 8: Morpheme Bridge', Color(0xFF4F46E5)),
  'streak': LencanaDef('Setia Belajar', Icons.local_fire_department_rounded, 'Raih Streak Belajar Berturut-turut', Color(0xFFF59E0B)),
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabAktif = 0; // 0 = Belajar, 1 = Lencana, 2 = Misi, 3 = Setelan

  @override
  void initState() {
    super.initState();
    if (!Suara.indonesiaTersedia) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: const Color(0xFF1E1B2E),
            duration: const Duration(seconds: 6),
            content: const Text(
              'Suara Indonesia belum aktif di perangkat. Cara memasang ada di Setelan -> Panduan Suara.',
            ),
          ),
        );
      });
    }
  }

  Future<void> _bukaLevel(int level) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => StageMapScreen(level: level)));
    if (mounted) setState(() {});
  }

  void _ketukLevel(InfoLevel info) {
    if (info.nomor > Data.levelSekarang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF1E1B2E),
          content: Text('Selesaikan Tingkat ${info.nomor - 1} dulu ya!', style: const TextStyle(fontSize: 15)),
        ),
      );
      return;
    }
    _bukaLevel(info.nomor);
  }

  void _lihatStreak() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1E1B2E),
        title: const Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 32),
            SizedBox(width: 8),
            Text('Api Belajar Harian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimasiDenyut(
              skalaMaks: 1.08,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/leko_streak.jpg',
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${Data.streak} Hari Berturut-turut',
                style: const TextStyle(fontSize: 20, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 6),
                Text('Rekor Terbaik: ${Data.rekorStreak} hari', style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
            if (Data.streak == 0)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Mainkan 1 tahap hari ini untuk menyalakan apimu!',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.orangeAccent)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Hebat!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _lihatXp() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 30),
            SizedBox(width: 8),
            Text('Poin Belajar (XP)', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${Data.xp}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
            const SizedBox(height: 8),
            const Text('Kumpulkan XP dengan menyelesaikan tahap petualangan setiap hari!',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))],
      ),
    );
  }

  void _lihatNyawa() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 30),
            SizedBox(width: 8),
            Text('Energi Belajar', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('5 / 5', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
            SizedBox(height: 8),
            Text('Energi belajarmu penuh! DyLeks dirancang ramah anak: tidak ada pengurangan nyawa yang menghukum.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Mengerti'))],
      ),
    );
  }

  void _bukaPanduanMateri() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            AnimasiMelayang(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/leko_reading.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Panduan Unit 1: Fondasi Disleksia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi DyLeks menggunakan metode multisensori (VAKT: Visual, Auditori, Kinestetik, dan Taktil). '
              'Setiap tingkat dirancang untuk mengikis keraguan visual pada huruf serupa (b/d/p/q) dan memperkuat kesadaran fonologis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Tombol3D(
              teks: 'SAYA MENGERTI',
              ikon: Icons.check_circle_rounded,
              warna: const Color(0xFF7C3AED),
              onTekan: () => Navigator.pop(c),
            ),
          ],
        ),
      ),
    );
  }

  void _bukaPetiBonus() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: Color(0xFFF59E0B), size: 30),
            SizedBox(width: 8),
            Text('Peti Harta Karun!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimasiRayakan(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/chest_gold_3d.jpg',
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 28),
                SizedBox(width: 6),
                Text('+15 XP Bonus!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Selamat! Kamu telah mencapai separuh perjalanan petualangan membaca.', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Tombol3D(
            teks: 'AMBIL HADIAH',
            ikon: Icons.redeem_rounded,
            warna: const Color(0xFF10B981),
            onTekan: () {
              Data.xp += 15;
              Data.simpan();
              setState(() {});
              Navigator.pop(c);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FD),
      bottomNavigationBar: DuolingoBottomBar(
        indeksSekarang: _tabAktif,
        onPilih: (i) => setState(() => _tabAktif = i),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // BARIS GAMIFIKASI ATAS DUOLINGO
            HeaderGamifikasi(
              streak: Data.streak,
              xp: Data.xp,
              nyawa: 5,
              avatar: Data.avatar,
              onStreak: _lihatStreak,
              onXp: _lihatXp,
              onLencana: _lihatNyawa,
              onProfil: () => setState(() => _tabAktif = 3),
            ),

            // KONTEN SESUAI TAB
            Expanded(
              child: IndexedStack(
                index: _tabAktif,
                children: [
                  _bangunTabBelajar(),
                  _bangunTabLencana(),
                  _bangunTabMisi(),
                  const SettingsScreen(tampilkanAppBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // TAB 0: MODUL BELAJAR 8 TINGKAT (GAYA DUOLINGO 3D)
  // UX Jelas & Informatif: Hero Card Tingkat Aktif
  // diikuti Daftar 8 Kartu Modul Taktil 3D.
  // ===============================================
  Widget _bangunTabBelajar() {
    final levelAktif = daftarLevel[Data.levelSekarang - 1];
    final int selesaiAktif = Data.tahapSelesai[Data.levelSekarang - 1];
    final Color warnaAktif = Color(levelAktif.warna);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // 1. HERO SPOTLIGHT CARD TINGKAT AKTIF (DUOLINGO 3D HERO)
        Container(
          decoration: BoxDecoration(
            color: warnaAktif,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: hitungWarnaBayangan(warnaAktif),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BAGIAN 1 · TINGKAT ${levelAktif.nomor} DARI 8',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _bukaPanduanMateri,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                    tooltip: 'Panduan Materi',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tingkat ${levelAktif.nomor}: ${levelAktif.namaLevel}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          levelAktif.namaGame,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: selesaiAktif / 5,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$selesaiAktif dari 5 tahap diselesaikan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  AnimasiMelayang(
                    amplitudo: 5,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 4),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/leko_cheer.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Tombol3D(
                teks: 'LANJUTKAN TINGKAT ${levelAktif.nomor}',
                ikon: Icons.play_arrow_rounded,
                warna: const Color(0xFF10B981),
                onTekan: () => _bukaLevel(levelAktif.nomor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. HEADER DAFTAR MODUL
        const Row(
          children: [
            Icon(Icons.explore_rounded, color: Color(0xFF7C3AED), size: 22),
            SizedBox(width: 8),
            Text(
              'Peta Petualangan Membaca',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E1B2E)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih modul untuk melatih keterampilan membaca secara bertahap:',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),

        // 3. DAFTAR 8 KARTU MODUL BELAJAR 3D DUOLINGO
        for (int i = 0; i < daftarLevel.length; i++) ...[
          // Peti Bonus Separuh Jalan (antara Tingkat 4 dan 5)
          if (i == 4) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: _bukaPetiBonus,
                child: AnimasiDenyut(
                  skalaMaks: 1.03,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 4), blurRadius: 0),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/chest_gold_3d.jpg',
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peti Kejutan Separuh Jalan!',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFB45309)),
                              ),
                              Text(
                                'Ketuk untuk klaim bonus +15 XP petualangan',
                                style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '+15 XP',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          Builder(builder: (context) {
            final info = daftarLevel[i];
            final int selesai = Data.tahapSelesai[i];
            final bool isAktif = info.nomor == Data.levelSekarang;
            final bool isSelesai = info.nomor < Data.levelSekarang ||
                (info.nomor == Data.levelSekarang && selesai == 5);
            final bool isTerkunci = info.nomor > Data.levelSekarang;
            final Color warnaLevel = Color(info.warna);

            // Styling 3D ala Duolingo berdasarkan status
            final Color latarKartu = isTerkunci
                ? const Color(0xFFF9FAFB)
                : (isAktif ? Colors.white : const Color(0xFFFAFAFA));
            final Color borderKartu = isAktif
                ? warnaLevel
                : (isSelesai ? const Color(0xFF10B981) : const Color(0xFFE5E7EB));
            final Color bayanganKartu = isAktif
                ? hitungWarnaBayangan(warnaLevel)
                : (isSelesai ? const Color(0xFF059669) : const Color(0xFFD1D5DB));
            final double lebarBorder = isAktif ? 2.5 : 2.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => _ketukLevel(info),
                child: Container(
                  decoration: BoxDecoration(
                    color: latarKartu,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderKartu, width: lebarBorder),
                    boxShadow: [
                      BoxShadow(
                        color: bayanganKartu,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Ikon Kotak Bulat 3D
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isTerkunci
                              ? Colors.grey.shade200
                              : warnaLevel.withValues(alpha: isAktif ? 0.18 : 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isTerkunci ? Colors.grey.shade300 : warnaLevel.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isTerkunci ? Icons.lock_rounded : info.ikon,
                          color: isTerkunci ? Colors.grey.shade400 : warnaLevel,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Teks Informasi Modul
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tingkat ${info.nomor}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isTerkunci ? Colors.grey.shade500 : warnaLevel,
                                  ),
                                ),
                                if (isAktif) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDE9FE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'AKTIF',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              info.namaGame,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isTerkunci ? Colors.grey.shade600 : const Color(0xFF1E1B2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              info.namaLevel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (isAktif || isSelesai) ...[
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: selesai / 5,
                                  minHeight: 5,
                                  backgroundColor: Colors.grey.shade200,
                                  color: isSelesai ? const Color(0xFF10B981) : warnaLevel,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Trailing Badge / Action Button
                      if (isSelesai)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                              SizedBox(width: 4),
                              Text(
                                '5/5',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isAktif)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: warnaLevel,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: hitungWarnaBayangan(warnaLevel),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                      else
                        Icon(
                          Icons.lock_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ===============================================
  // TAB 1: SHOWCASE LENCANA 3D
  // ===============================================
  Widget _bangunTabLencana() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 30),
            SizedBox(width: 10),
            Text('Koleksi Lencana Juara', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E1B2E))),
          ],
        ),
        const SizedBox(height: 4),
        Text('Buka lencana dengan menyelesaikan setiap tingkat latihan!', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: dataLencanaLengkap.entries.map((e) {
            final bool terbuka = Data.lencana.contains(e.key);
            final lencana = e.value;
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Row(
                      children: [
                        Icon(lencana.ikon, color: lencana.warna, size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: Text(lencana.nama, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lencana.desc, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: terbuka ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                terbuka ? Icons.check_circle_rounded : Icons.lock_rounded,
                                size: 16,
                                color: terbuka ? const Color(0xFF059669) : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                terbuka ? 'Sudah Terbuka' : 'Masih Terkunci',
                                style: TextStyle(
                                  color: terbuka ? const Color(0xFF059669) : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: terbuka ? const Color(0xFFFFFBEB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: terbuka ? const Color(0xFFF59E0B) : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: terbuka ? const Color(0xFFD97706) : const Color(0xFFD1D5DB),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: terbuka ? lencana.warna.withValues(alpha: 0.15) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        terbuka ? lencana.ikon : Icons.lock_rounded,
                        color: terbuka ? lencana.warna : Colors.grey.shade400,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lencana.nama,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: terbuka ? const Color(0xFF1E1B2E) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===============================================
  // TAB 2: MISI HARIAN DUOLINGO
  // ===============================================
  Widget _bangunTabMisi() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Row(
          children: [
            Icon(Icons.flag_rounded, color: Color(0xFF7C3AED), size: 30),
            SizedBox(width: 10),
            Text('Misi Petualangan Hari Ini', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E1B2E))),
          ],
        ),
        const SizedBox(height: 4),
        Text('Selesaikan misi harian untuk mendapatkan bonus XP!', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 20),

        _kartuMisi(
          judul: 'Latihan 1 Tahap Petualangan',
          deskripsi: 'Selesaikan tahap apa saja hari ini',
          progres: Data.streak > 0 ? 1.0 : 0.0,
          labelProgres: Data.streak > 0 ? '1/1' : '0/1',
          bonusXp: 10,
        ),
        _kartuMisi(
          judul: 'Raih Skor Sempurna Tanpa Salah',
          deskripsi: 'Jawab semua pertanyaan tanpa keliru',
          progres: 0.5,
          labelProgres: '1/2',
          bonusXp: 20,
        ),
        _kartuMisi(
          judul: 'Koleksi 3 Lencana Juara',
          deskripsi: 'Buka lencana baru dari tingkat membaca',
          progres: (Data.lencana.length / 3).clamp(0.0, 1.0),
          labelProgres: '${Data.lencana.length}/3',
          bonusXp: 30,
        ),
      ],
    );
  }

  Widget _kartuMisi({
    required String judul,
    required String deskripsi,
    required double progres,
    required String labelProgres,
    required int bonusXp,
  }) {
    final bool selesai = progres >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selesai ? const Color(0xFF10B981) : const Color(0xFFE5E7EB), width: 2),
        boxShadow: [
          BoxShadow(
            color: selesai ? const Color(0xFF059669) : const Color(0xFFD1D5DB),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  'assets/images/chest_gold_3d.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1B2E))),
                    Text(deskripsi, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('+$bonusXp XP', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progres,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              color: selesai ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(labelProgres, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}
