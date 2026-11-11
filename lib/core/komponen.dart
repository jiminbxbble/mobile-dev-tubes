import 'package:flutter/material.dart';
import 'suara.dart';

// ===============================================
// UI KIT GAMIFIKASI DUOLINGO AAA (DYLEKS MOBILE)
// Desain sistem taktil 3D, ubin kuis interaktif,
// jalur batu loncatan berkelok, dan bilah gamifikasi.
// ===============================================

Color hitungWarnaBayangan(Color warna) {
  final hsl = HSLColor.fromColor(warna);
  return hsl.withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0)).toColor();
}

// Hasil kontrak komunikasi yang dikirim minigame ke Peta Tahap
class HasilGame {
  final bool menang;
  final int salah;
  final bool dibantu;
  final String? ringkasan;
  const HasilGame({required this.menang, this.salah = 0, this.dibantu = false, this.ringkasan});
}

void selesaiGame(
  BuildContext context, {
  required bool menang,
  int salah = 0,
  bool dibantu = false,
  String? ringkasan,
}) {
  Navigator.pop(
    context,
    HasilGame(menang: menang, salah: salah, dibantu: dibantu, ringkasan: ringkasan),
  );
}

// ===============================================
// 1. TOMBOL 3D TAKTIL DUOLINGO (TOMBOL PRIMER)
// Memiliki fisik 2-lapis yang amblas saat ditekan.
// ===============================================
class Tombol3D extends StatefulWidget {
  final String teks;
  final VoidCallback? onTekan;
  final Color warna;
  final Color? warnaBayangan;
  final Color warnaTeks;
  final IconData? ikon;
  final double tinggi;
  final double? lebar;
  final double ukuranFont;
  final BorderRadius? radius;

  const Tombol3D({
    super.key,
    required this.teks,
    required this.onTekan,
    this.warna = const Color(0xFF7C3AED), // Ungu Royal Duolingo
    this.warnaBayangan,
    this.warnaTeks = Colors.white,
    this.ikon,
    this.tinggi = 52,
    this.lebar,
    this.ukuranFont = 17,
    this.radius,
  });

  @override
  State<Tombol3D> createState() => _Tombol3DState();
}

class _Tombol3DState extends State<Tombol3D> {
  bool _ditekan = false;

  @override
  Widget build(BuildContext context) {
    final bool aktif = widget.onTekan != null;
    final Color warnaMuka = aktif ? widget.warna : const Color(0xFFE5E7EB);
    final Color warnaAlas = aktif
        ? (widget.warnaBayangan ?? hitungWarnaBayangan(widget.warna))
        : const Color(0xFFD1D5DB);
    final Color warnaTeks = aktif ? widget.warnaTeks : const Color(0xFF9CA3AF);
    final BorderRadius r = widget.radius ?? BorderRadius.circular(16);

    const double tebal3D = 4.0;
    final double marginAtas = _ditekan ? tebal3D : 0.0;
    final double tinggiShadow = _ditekan ? 0.0 : tebal3D;

    return SizedBox(
      width: widget.lebar ?? double.infinity,
      height: widget.tinggi + tebal3D,
      child: GestureDetector(
        onTapDown: aktif ? (_) => setState(() => _ditekan = true) : null,
        onTapUp: aktif
            ? (_) {
                setState(() => _ditekan = false);
                widget.onTekan?.call();
              }
            : null,
        onTapCancel: aktif ? () => setState(() => _ditekan = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          margin: EdgeInsets.only(top: marginAtas),
          decoration: BoxDecoration(
            color: warnaMuka,
            borderRadius: r,
            border: Border.all(color: warnaAlas.withValues(alpha: 0.35), width: 1.5),
            boxShadow: tinggiShadow > 0
                ? [
                    BoxShadow(
                      color: warnaAlas,
                      offset: Offset(0, tinggiShadow),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.ikon != null) ...[
                  Icon(widget.ikon, color: warnaTeks, size: widget.ukuranFont + 4),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.teks.toUpperCase(),
                  style: TextStyle(
                    color: warnaTeks,
                    fontSize: widget.ukuranFont,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TombolBesar (Kompatibel dengan ElevatedButton untuk uji widget)
class TombolBesar extends StatelessWidget {
  final String teks;
  final VoidCallback? onTekan;
  final Color warna;

  const TombolBesar({
    super.key,
    required this.teks,
    required this.onTekan,
    this.warna = const Color(0xFF7C3AED),
  });

  @override
  Widget build(BuildContext context) {
    final bayangan = hitungWarnaBayangan(warna);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: warna,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          elevation: 4,
          shadowColor: bayangan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: onTekan != null ? bayangan : const Color(0xFFD1D5DB),
              width: 2,
            ),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        onPressed: onTekan,
        child: Text(teks.toUpperCase()),
      ),
    );
  }
}

// ===============================================
// 2. KARTU TAKTIL PILIHAN KUIS (INTERACTIVE TILE)
// Balok opsi jawaban kuis yang memiliki kedalaman 3D fisik.
// ===============================================
enum StatusKartu { normal, terpilih, benar, salah }

class KartuTaktil extends StatelessWidget {
  final String teks;
  final StatusKartu status;
  final VoidCallback? onTekan;
  final double tinggi;
  final double ukuranFont;
  final Widget? awalan;

  const KartuTaktil({
    super.key,
    required this.teks,
    this.status = StatusKartu.normal,
    required this.onTekan,
    this.tinggi = 64,
    this.ukuranFont = 22,
    this.awalan,
  });

  @override
  Widget build(BuildContext context) {
    Color warnaLatar = Colors.white;
    Color warnaGaris = const Color(0xFFE5E7EB);
    Color warnaBayangan = const Color(0xFFD1D5DB);
    Color warnaTeks = const Color(0xFF1E1B2E);
    double offsetAtas = 0.0;
    double tinggiBayangan = 4.0;

    switch (status) {
      case StatusKartu.terpilih:
        warnaLatar = const Color(0xFFF5F3FF);
        warnaGaris = const Color(0xFF7C3AED);
        warnaBayangan = const Color(0xFF5B21B6);
        warnaTeks = const Color(0xFF7C3AED);
        offsetAtas = 2.0;
        tinggiBayangan = 2.0;
        break;
      case StatusKartu.benar:
        warnaLatar = const Color(0xFFD1FAE5);
        warnaGaris = const Color(0xFF10B981);
        warnaBayangan = const Color(0xFF059669);
        warnaTeks = const Color(0xFF065F46);
        break;
      case StatusKartu.salah:
        warnaLatar = const Color(0xFFFEE2E2);
        warnaGaris = const Color(0xFFEF4444);
        warnaBayangan = const Color(0xFFDC2626);
        warnaTeks = const Color(0xFF991B1B);
        break;
      case StatusKartu.normal:
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTekan,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: tinggi,
          margin: EdgeInsets.only(top: offsetAtas),
          decoration: BoxDecoration(
            color: warnaLatar,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: warnaGaris, width: 2.2),
            boxShadow: tinggiBayangan > 0
                ? [
                    BoxShadow(
                      color: warnaBayangan,
                      offset: Offset(0, tinggiBayangan),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (awalan != null) ...[
                  awalan!,
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    teks,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ukuranFont,
                      fontWeight: FontWeight.bold,
                      color: warnaTeks,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper tampilan avatar (mendukung 3 Maskot 3D Nano Banana & fallback emoji)
Widget bangunAvatarWidget(String avatar, {double ukuran = 26}) {
  if (avatar == 'leko' || avatar == 'leko_reading') {
    return ClipOval(
      child: Image.asset('assets/images/avatar_leko.jpg', width: ukuran, height: ukuran, fit: BoxFit.cover),
    );
  } else if (avatar == 'milo') {
    return ClipOval(
      child: Image.asset('assets/images/avatar_milo.jpg', width: ukuran, height: ukuran, fit: BoxFit.cover),
    );
  } else if (avatar == 'kiko') {
    return ClipOval(
      child: Image.asset('assets/images/avatar_kiko.jpg', width: ukuran, height: ukuran, fit: BoxFit.cover),
    );
  }
  return Text(avatar, style: TextStyle(fontSize: ukuran * 0.8));
}

// ===============================================
// 3. BARIS STATUS GAMIFIKASI ATAS (TOP BAR)
// Streak api, XP, dan Hati nyawa ala Duolingo.
// ===============================================
class HeaderGamifikasi extends StatelessWidget {
  final int streak;
  final int xp;
  final int nyawa;
  final String? avatar;
  final VoidCallback? onStreak;
  final VoidCallback? onXp;
  final VoidCallback? onLencana;
  final VoidCallback? onProfil;

  const HeaderGamifikasi({
    super.key,
    required this.streak,
    required this.xp,
    this.nyawa = 5,
    this.avatar,
    this.onStreak,
    this.onXp,
    this.onLencana,
    this.onProfil,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // AVATAR PROFIL
          if (avatar != null)
            InkWell(
              onTap: onProfil,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                ),
                child: bangunAvatarWidget(avatar!, ukuran: 24),
              ),
            ),
          // STREAK API
          _kapsul(
            ikon: Icons.local_fire_department_rounded,
            nilai: '$streak',
            warna: const Color(0xFFF59E0B),
            onTekan: onStreak,
          ),
          // XP EMAS
          _kapsul(
            ikon: Icons.star_rounded,
            nilai: '$xp XP',
            warna: const Color(0xFFF59E0B),
            onTekan: onXp,
          ),
          // NYAWA MERAH
          _kapsul(
            ikon: Icons.favorite_rounded,
            nilai: '$nyawa',
            warna: const Color(0xFFEF4444),
            onTekan: onLencana,
          ),
        ],
      ),
    );
  }

  Widget _kapsul({required IconData ikon, required String nilai, required Color warna, VoidCallback? onTekan}) {
    return InkWell(
      onTap: onTekan,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: warna.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: warna.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, color: warna, size: 20),
            const SizedBox(width: 6),
            Text(
              nilai,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: warna),
            ),
          ],
        ),
      ),
    );
  }
}

// KapsulStat lama (untuk kompatibilitas)
class KapsulStat extends StatelessWidget {
  final IconData ikon;
  final String label;
  final Color warnaAksen;
  final VoidCallback? onTekan;

  const KapsulStat({
    super.key,
    required this.ikon,
    required this.label,
    this.warnaAksen = const Color(0xFFF59E0B),
    this.onTekan,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTekan,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: warnaAksen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: warnaAksen.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, color: warnaAksen, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: HSLColor.fromColor(warnaAksen).withLightness(0.35).toColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================
// 4. BATU LONCATAN 3D DUOLINGO (STEPPING STONE)
// Tombol melingkar 3D untuk jalur petualangan.
// ===============================================
class BatuLoncatan3D extends StatefulWidget {
  final int nomor;
  final IconData? ikonData;
  final String? ikon;
  final String status; // 'selesai', 'aktif', 'terkunci'
  final Color warna;
  final VoidCallback onTekan;
  final double ukuran;
  final String? labelPopup;

  const BatuLoncatan3D({
    super.key,
    required this.nomor,
    this.ikonData,
    this.ikon,
    required this.status,
    required this.warna,
    required this.onTekan,
    this.ukuran = 78,
    this.labelPopup,
  });

  @override
  State<BatuLoncatan3D> createState() => _BatuLoncatan3DState();
}

class _BatuLoncatan3DState extends State<BatuLoncatan3D> {
  bool _ditekan = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelesai = widget.status == 'selesai';
    final bool isAktif = widget.status == 'aktif';
    final bool isTerkunci = widget.status == 'terkunci';

    Color warnaMuka = Colors.grey.shade300;
    Color warnaAlas = Colors.grey.shade400;

    if (isSelesai) {
      warnaMuka = const Color(0xFFF59E0B); // Emas
      warnaAlas = const Color(0xFFD97706);
    } else if (isAktif) {
      warnaMuka = widget.warna;
      warnaAlas = hitungWarnaBayangan(widget.warna);
    }

    const double tebal3D = 6.0;
    final double marginAtas = _ditekan ? tebal3D : 0.0;
    final double tinggiShadow = _ditekan ? 0.0 : tebal3D;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // POPUP TOOLTIP "MULAI!" JIKA AKTIF
        if (isAktif) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0xFF5B21B6), offset: Offset(0, 3), blurRadius: 0),
              ],
            ),
            child: Text(
              widget.labelPopup ?? 'MULAI!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(12, 6),
            painter: _SegitigaPanahPainter(const Color(0xFF5B21B6)),
          ),
          const SizedBox(height: 4),
        ],

        // LINGKARAN BATU 3D
        GestureDetector(
          onTapDown: !isTerkunci ? (_) => setState(() => _ditekan = true) : null,
          onTapUp: !isTerkunci
              ? (_) {
                  setState(() => _ditekan = false);
                  widget.onTekan();
                }
              : null,
          onTapCancel: () => setState(() => _ditekan = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            margin: EdgeInsets.only(top: marginAtas),
            width: widget.ukuran,
            height: widget.ukuran,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: warnaMuka,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
              boxShadow: tinggiShadow > 0
                  ? [
                      BoxShadow(
                        color: warnaAlas,
                        offset: Offset(0, tinggiShadow),
                        blurRadius: 0,
                      ),
                    ]
                : [],
            ),
            child: Center(
              child: isSelesai
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
                        Icon(Icons.check_rounded, color: Colors.white, size: 16),
                      ],
                    )
                  : (isAktif
                      ? (widget.ikonData != null
                          ? Icon(widget.ikonData, color: Colors.white, size: 34)
                          : (widget.ikon != null && widget.ikon!.isNotEmpty
                              ? Text(
                                  widget.ikon!,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                )
                              : Text(
                                  '${widget.nomor}',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                                )))
                      : const Icon(Icons.lock_rounded, color: Color(0xFF9CA3AF), size: 30)),
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================
// 5. BILAH NAVIGASI BAWAH DUOLINGO (BOTTOM NAV)
// ===============================================
class DuolingoBottomBar extends StatelessWidget {
  final int indeksSekarang;
  final ValueChanged<int> onPilih;

  const DuolingoBottomBar({
    super.key,
    required this.indeksSekarang,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(0, Icons.school_rounded, 'Belajar'),
            _item(1, Icons.military_tech_rounded, 'Lencana'),
            _item(2, Icons.flag_rounded, 'Misi'),
            _item(3, Icons.settings_rounded, 'Setelan'),
          ],
        ),
      ),
    );
  }

  Widget _item(int indeks, IconData ikon, String label) {
    final bool aktif = indeks == indeksSekarang;
    const Color warnaAktif = Color(0xFF7C3AED);

    return InkWell(
      onTap: () => onPilih(indeks),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: aktif ? warnaAktif.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: aktif ? warnaAktif.withValues(alpha: 0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: aktif ? warnaAktif : Colors.grey.shade400, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: aktif ? FontWeight.w900 : FontWeight.bold,
                color: aktif ? warnaAktif : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================
// 6. KERANGKA LAYAR GAME ALA DUOLINGO (LESSON SCREEN)
// Bilah progres tebal membulat + tombol keluar aman.
// ===============================================
class LayarGame extends StatelessWidget {
  final String judul;
  final Color warna;
  final Widget isi;
  final double? progres;
  final int nyawa;

  const LayarGame({
    super.key,
    required this.judul,
    required this.warna,
    required this.isi,
    this.progres,
    this.nyawa = 5,
  });

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final keluar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 8),
            Text('Keluar tahap?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Jangan berhenti sekarang! Progres di tahap ini belum selesai.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Lanjut Main', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (keluar == true && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sudahPop, _) {
        if (!sudahPop) _konfirmasiKeluar(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8FD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E1B2E),
          title: Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 28, color: Colors.grey),
            onPressed: () => _konfirmasiKeluar(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 4),
                  Text('$nyawa', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEF4444), fontSize: 16)),
                ],
              ),
            ),
          ],
          bottom: progres != null
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progres!.clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE5E7EB),
                        color: warna,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(16), child: isi),
        ),
      ),
    );
  }
}

// Tombol suara bulat 3D
class TombolSuara extends StatelessWidget {
  final String teks;
  final double ukuran;

  const TombolSuara({super.key, required this.teks, this.ukuran = 50});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Suara.ucap(teks),
      child: Container(
        width: ukuran,
        height: ukuran,
        decoration: const BoxDecoration(
          color: Color(0xFF06B6D4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0891B2),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// Dialog ramah anak untuk Scaffolding (Mode Bantuan)
Future<bool> tawarkanBantuan(BuildContext context) async {
  final jawab = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.handshake_rounded, color: Color(0xFF7C3AED), size: 28),
          SizedBox(width: 8),
          Expanded(child: Text('Mau bantuan sedikit?', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
      content: const Text(
        'Jangan cemas! Kami bisa menyederhanakan soal agar kamu bisa menyelesaikannya dengan gembira.',
        style: TextStyle(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Coba Sendiri'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Bantu Aku'),
        ),
      ],
    ),
  );
  return jawab ?? false;
}

// Umpan balik visual bergaya Duolingo Card
void tampilUmpanBalik(BuildContext context, bool benar) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 900),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: benar ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      elevation: 6,
      content: Row(
        children: [
          Icon(
            benar ? Icons.check_circle_rounded : Icons.info_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benar ? 'Luar biasa! Jawabanmu tepat!' : 'Yuk coba lagi, kamu pasti bisa!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

// Segitiga panah untuk popup
class _SegitigaPanahPainter extends CustomPainter {
  final Color warna;
  _SegitigaPanahPainter(this.warna);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = warna;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
