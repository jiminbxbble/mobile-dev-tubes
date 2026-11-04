import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import '../games/daftar_game.dart';

// ===============================================
// PETA 5 TAHAP untuk satu level/game
// Di sini juga aturan XP, naik level, lencana, streak dijalankan.
// ===============================================

class StageMapScreen extends StatefulWidget {
  final int level;
  const StageMapScreen({super.key, required this.level});

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  // Posisi zig-zag node: 0, +40, 0, -40, 0
  final List<double> _geserX = [0, 40, 0, -40, 0];

  InfoLevel get _info => daftarLevel[widget.level - 1];

  void _pilihTahap(int tahap) {
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tahap $tahap', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TombolBesar(
              teks: 'MULAI TAHAP $tahap',
              warna: Color(_info.warna),
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

    if (hasil.menang) {
      final tahapBaru = Data.statusTahap(widget.level, tahap) == 'aktif';

      // XP: tahap baru +20, tahap diulang +10, sempurna +5
      final xpDasar = tahapBaru ? 20 : 10;
      Data.xp += xpDasar;
      pesan.add('+$xpDasar XP');
      if (hasil.salah == 0 && !hasil.dibantu) {
        Data.xp += 5;
        pesan.add('Sempurna! +5');
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
      if (tahap == 1 && Data.bukaLencana('level${widget.level}')) pesan.add('🏅 Lencana baru!');
      final streakLama = Data.streak;
      Data.tambahStreak();
      if (Data.streak > streakLama) pesan.add('🔥 Streak ${Data.streak} hari');
      Data.gagalBeruntun[kunci] = 0;
    } else {
      // Gagal tapi main sampai akhir -> XP usaha
      Data.xp += 2;
      pesan.add('+2 XP usaha');
      Data.gagalBeruntun[kunci] = (Data.gagalBeruntun[kunci] ?? 0) + 1;
    }

    await Data.simpan(); // simpan dulu sebelum layar hasil tampil
    if (!mounted) return;
    setState(() {});

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(hasil.menang ? 'Hebat! 🎉' : 'Ayo coba lagi, kamu pasti bisa! 💪'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...pesan.map((p) => Text(p, style: const TextStyle(fontSize: 20))),
            if (naikLevel) ...[
              const SizedBox(height: 12),
              Text('Naik ke Tingkat ${Data.levelSekarang}! 🚀',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warna = Color(_info.warna);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_info.namaGame} · Tingkat ${_info.nomor}'),
        backgroundColor: warna,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Halo, ${Data.nama}! Selesaikan ke-5 tahap ${_info.namaGame} ${_info.ikon}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 5 node tahap zig-zag
          for (int tahap = 1; tahap <= 5; tahap++)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Transform.translate(
                offset: Offset(_geserX[tahap - 1], 0),
                child: Center(child: _nodeTahap(tahap, warna)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _nodeTahap(int tahap, Color warna) {
    final status = Data.statusTahap(widget.level, tahap);
    Color warnaNode = Colors.grey;
    Widget isi = const Icon(Icons.lock, color: Colors.white, size: 32);
    if (status == 'selesai') {
      warnaNode = Colors.green;
      isi = const Icon(Icons.check, color: Colors.white, size: 36);
    } else if (status == 'aktif') {
      warnaNode = warna;
      isi = Text('$tahap', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold));
    }

    return GestureDetector(
      onTap: status == 'kunci' ? null : () => _pilihTahap(tahap),
      child: CircleAvatar(radius: 38, backgroundColor: warnaNode, child: isi),
    );
  }
}
