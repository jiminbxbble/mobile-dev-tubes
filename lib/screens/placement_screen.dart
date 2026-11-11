import 'package:flutter/material.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import 'home_screen.dart';

// ===============================================
// TES PENEMPATAN (GAYA KUIS DUOLINGO)
// 5 soal penentu tingkat awal (1, 3, atau 6).
// ===============================================

class SoalTes {
  final String pertanyaan;
  final String? didengar; // null = soal visual (tanpa suara)
  final List<String> opsi;
  final String jawaban;
  const SoalTes(this.pertanyaan, this.didengar, this.opsi, this.jawaban);
}

const List<SoalTes> soalTes = [
  SoalTes('Dengarkan bunyinya, lalu pilih huruf yang benar!', 'U', ['A', 'I', 'U', 'E', 'O'], 'U'),
  SoalTes('Dengarkan suku katanya, lalu pilih yang tepat!', 'BA', ['BO', 'BI', 'BA', 'BU', 'BE'], 'BA'),
  SoalTes('Dengarkan bunyinya, temukan kata yang sesuai!', 'SING', ['SINK', 'SING', 'SHING', 'TING', 'PING'], 'SING'),
  SoalTes('Dengarkan baik-baik, pilih kata yang tepat!', 'NYANYI', ['NANYI', 'NYANYI', 'NANI', 'YANYI', 'MAMI'], 'NYANYI'),
  SoalTes('Pilih ejaan yang benar untuk kata "MAKAN"', null, ['MAKNA', 'MAKAN', 'KAMAN', 'AMKAN', 'MANAK'], 'MAKAN'),
];

class PlacementScreen extends StatefulWidget {
  final bool dariOnboarding;
  const PlacementScreen({super.key, this.dariOnboarding = false});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  int _nomor = 0; // soal ke berapa (0-4)
  int _benar = 0;
  String? _pilihan;
  bool _sudahDiperiksa = false;

  @override
  void initState() {
    super.initState();
    _bacakanSoal();
  }

  void _bacakanSoal() {
    final teks = soalTes[_nomor].didengar;
    if (teks != null) {
      Future.delayed(const Duration(milliseconds: 600), () => Suara.ucap(teks));
    }
  }

  void _periksa() {
    setState(() {
      _sudahDiperiksa = true;
      if (_pilihan == soalTes[_nomor].jawaban) {
        _benar++;
        tampilUmpanBalik(context, true);
      } else {
        tampilUmpanBalik(context, false);
      }
    });
  }

  void _lanjut() {
    if (_nomor < soalTes.length - 1) {
      setState(() {
        _nomor++;
        _pilihan = null;
        _sudahDiperiksa = false;
      });
      _bacakanSoal();
    } else {
      _selesai(_benar);
    }
  }

  // 5 benar -> Tingkat 6, 3-4 benar -> Tingkat 3, 0-2 -> Tingkat 1
  Future<void> _selesai(int skor) async {
    int level = 1;
    if (skor == 5) {
      level = 6;
    } else if (skor >= 3) {
      level = 3;
    }
    Data.aturLevelAwal(level);
    await Data.simpan();
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🏆', style: TextStyle(fontSize: 32)),
            SizedBox(width: 8),
            Text('Hasil Tes Penempatan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Text('✨', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 14),
            Text(
              'Jawaban Benar: $skor / ${soalTes.length}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu mulai di Tingkat ${Data.levelSekarang}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Materi telah disesuaikan agar kamu bisa belajar dengan nyaman!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          Tombol3D(
            teks: 'AYO MAIN! 🚀',
            warna: const Color(0xFF10B981),
            onTekan: () => Navigator.pop(c),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final soal = soalTes[_nomor];
    final bool bisaPeriksa = _pilihan != null && !_sudahDiperiksa;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FD),
      appBar: AppBar(
        title: Text(
          'Tes Penempatan · Soal ${_nomor + 1} dari 5',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1B2E)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_nomor + 1) / 5,
                minHeight: 8,
                backgroundColor: Colors.purple.shade50,
                color: const Color(0xFF7C3AED),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                soal.pertanyaan,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
              ),
              const SizedBox(height: 16),
              if (soal.didengar != null)
                Center(
                  child: TombolSuara(teks: soal.didengar!, ukuran: 56),
                ),
              const SizedBox(height: 20),

              // Daftar Opsi Jawaban 3D
              Expanded(
                child: ListView(
                  children: soal.opsi.map((opsi) {
                    final bool terpilih = opsi == _pilihan;
                    StatusKartu status = StatusKartu.normal;
                    if (!_sudahDiperiksa) {
                      status = terpilih ? StatusKartu.terpilih : StatusKartu.normal;
                    } else {
                      if (opsi == soal.jawaban) {
                        status = StatusKartu.benar;
                      } else if (terpilih) {
                        status = StatusKartu.salah;
                      }
                    }

                    return KartuTaktil(
                      teks: opsi,
                      status: status,
                      ukuranFont: 24,
                      onTekan: _sudahDiperiksa ? null : () => setState(() => _pilihan = opsi),
                    );
                  }).toList(),
                ),
              ),

              // Tombol Aksi Bawah
              if (!_sudahDiperiksa)
                TombolBesar(
                  teks: 'PERIKSA JAWABAN',
                  warna: const Color(0xFF7C3AED),
                  onTekan: bisaPeriksa ? _periksa : null,
                )
              else
                TombolBesar(
                  teks: _nomor < 4 ? 'SOAL BERIKUTNYA ➔' : 'LIHAT HASIL PENEMPATAN 🏆',
                  warna: const Color(0xFF10B981),
                  onTekan: _lanjut,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
