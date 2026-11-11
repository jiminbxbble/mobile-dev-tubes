import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/penyimpanan.dart';
import '../games/daftar_game.dart';

// ===============================================
// PETA 5 TAHAP ZIG-ZAG (GAYA DUOLINGO STEPPING PATH)
// Node batu 3D, tag 'MULAI!', mahkota bintang,
// serta aturan kalkulasi XP, streak, dan naik level.
// ===============================================

class StageMapScreen extends StatefulWidget {
  final int level;
  const StageMapScreen({super.key, required this.level});

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  // Posisi pergeseran horizontal zig-zag node: 0, +48, 0, -48, 0
  final List<double> _geserX = [0, 48, 0, -48, 0];

  InfoLevel get _info => daftarLevel[widget.level - 1];

  /// Dipanggil saat anak menekan node tahap di peta
  void _pilihTahap(int tahap) {
    final status = Data.statusTahap(widget.level, tahap);
    if (status == 'terkunci') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF1E1B2E),
          content: Text('Tahap $tahap masih terkunci. Selesaikan tahap sebelumnya dulu ya!',
              style: const TextStyle(fontSize: 16)),
        ),
      );
      return;
    }

    final Color warnaGame = Color(_info.warna);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_info.ikon, color: warnaGame, size: 30),
                const SizedBox(width: 10),
                Text(
                  'Tahap $tahap',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              status == 'selesai'
                  ? 'Tahap ini sudah selesai. Kamu bisa mengulang untuk melatih ingatan! (+10 XP)'
                  : 'Selesaikan tantangan ini untuk membuka tahap berikutnya! (+20 XP)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            Tombol3D(
              teks: status == 'selesai' ? 'ULANGI TAHAP $tahap' : 'MULAI TAHAP $tahap',
              ikon: status == 'selesai' ? Icons.replay_rounded : Icons.play_arrow_rounded,
              warna: warnaGame,
              onTekan: () {
                Navigator.pop(c);
                _mainTahap(tahap);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mainTahap(int tahap) async {
    final kunci = '${widget.level}-$tahap';

    // Mode bantuan untuk game yang bisa gagal: setelah gagal 3x berturut-turut
    bool bantuan = false;
    if ((Data.gagalBeruntun[kunci] ?? 0) >= 3) {
      bantuan = await tawarkanBantuan(context);
    }
    if (!mounted) return;

    final hasil = await Navigator.push<HasilGame>(
      context,
      MaterialPageRoute(builder: (_) => buatGame(widget.level, tahap, bantuan)),
    );
    if (hasil == null || !mounted) return; // anak keluar di tengah tahap

    await _prosesHasil(tahap, kunci, hasil);
  }

  Future<void> _prosesHasil(int tahap, String kunci, HasilGame hasil) async {
    final List<String> pesan = [];
    bool naikLevel = false;

    if (hasil.ringkasan != null && hasil.ringkasan!.isNotEmpty) {
      pesan.add(hasil.ringkasan!);
    }

    if (hasil.menang) {
      final tahapBaru = Data.statusTahap(widget.level, tahap) == 'aktif';

      // XP: tahap baru +20, tahap diulang +10, sempurna +5
      final xpDasar = tahapBaru ? 20 : 10;
      Data.xp += xpDasar;
      pesan.add('+$xpDasar XP Selesai');
      if (hasil.salah == 0 && !hasil.dibantu) {
        Data.xp += 5;
        pesan.add('Sempurna! +5 Bonus XP');
      }

      // Progres tahap & naik level
      if (tahapBaru) {
        Data.tahapSelesai[widget.level - 1]++;
        if (Data.tahapSelesai[widget.level - 1] == 5 &&
            widget.level == Data.levelSekarang &&
            Data.levelSekarang < 8) {
          Data.levelSekarang++;
          naikLevel = true;
        }
      }

      // Lencana: selesai tahap 1 di game ini
      if (tahap == 1 && Data.bukaLencana('level${widget.level}')) {
        pesan.add('Lencana Baru Terbuka!');
      }
      final streakLama = Data.streak;
      Data.tambahStreak();
      if (Data.streak > streakLama) {
        pesan.add('Streak Bertambah Menjadi ${Data.streak} Hari!');
      }
      Data.gagalBeruntun[kunci] = 0;
    } else {
      // Gagal tapi main sampai akhir -> XP usaha
      Data.xp += 2;
      pesan.add('+2 XP Semangat Usaha!');
      Data.gagalBeruntun[kunci] = (Data.gagalBeruntun[kunci] ?? 0) + 1;
    }

    await Data.simpan(); // simpan dulu sebelum layar hasil tampil
    if (!mounted) return;
    setState(() {});

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              hasil.menang ? Icons.emoji_events_rounded : Icons.auto_awesome_rounded,
              color: hasil.menang ? const Color(0xFFF59E0B) : const Color(0xFF7C3AED),
              size: 32,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasil.menang ? 'Hebat Sekali!' : 'Terus Semangat!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimasiRayakan(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  hasil.menang ? 'assets/images/leko_cheer.jpg' : 'assets/images/leko_reading.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...pesan.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                )),
            if (naikLevel) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded, color: Color(0xFF7C3AED), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Selamat! Kamu naik ke Tingkat ${Data.levelSekarang}!',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          Tombol3D(
            teks: 'LANJUTKAN',
            ikon: Icons.arrow_forward_rounded,
            warna: const Color(0xFF10B981),
            onTekan: () => Navigator.pop(c),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color warnaGame = Color(_info.warna);
    final int selesaiCount = Data.tahapSelesai[widget.level - 1];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_info.namaGame} · Tingkat ${_info.nomor}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1B2E)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                KapsulStat(ikon: Icons.star_rounded, label: '${Data.xp}', warnaAksen: const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Banner Tingkat di atas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: warnaGame,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: hitungWarnaBayangan(warnaGame),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_info.ikon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _info.namaLevel,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Peta 5 Tahap Petualangan',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$selesaiCount dari 5 tahap diselesaikan',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 5 NODE TAHAP ZIG-ZAG ALA BATU LONCATAN DUOLINGO
          for (int tahap = 1; tahap <= 5; tahap++) ...[
            Builder(builder: (context) {
              final status = Data.statusTahap(widget.level, tahap);
              final double pergeseran = _geserX[tahap - 1];

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Transform.translate(
                  offset: Offset(pergeseran, 0),
                  child: Center(
                    child: BatuLoncatan3D(
                      nomor: tahap,
                      ikonData: _info.ikon,
                      status: status,
                      warna: warnaGame,
                      onTekan: () => _pilihTahap(tahap),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
