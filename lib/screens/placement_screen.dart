import 'package:flutter/material.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import 'home_screen.dart';

// ===============================================
// TES PENEMPATAN: 5 soal -> menentukan level awal (1, 3, atau 6)
// ===============================================

class SoalTes {
  final String pertanyaan;
  final String? didengar; // null = soal visual (tanpa suara)
  final List<String> opsi;
  final String jawaban;
  const SoalTes(this.pertanyaan, this.didengar, this.opsi, this.jawaban);
}

const List<SoalTes> soalTes = [
  SoalTes('Dengarkan, lalu pilih yang benar', 'U', ['A', 'I', 'U', 'E', 'O'], 'U'),
  SoalTes('Dengarkan, lalu pilih yang benar', 'BA', ['BO', 'BI', 'BA', 'BU', 'BE'], 'BA'),
  SoalTes('Dengarkan, lalu pilih yang benar', 'SING', ['SINK', 'SING', 'SHING', 'TING', 'PING'], 'SING'),
  SoalTes('Dengarkan, lalu pilih yang benar', 'NYANYI', ['NANYI', 'NYANYI', 'NANI', 'YANYI', 'MAMI'], 'NYANYI'),
  SoalTes('Pilih ejaan yang benar dari "MAKAN"', null, ['MAKNA', 'MAKAN', 'KAMAN', 'AMKAN', 'MANAK'], 'MAKAN'),
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
      if (_pilihan == soalTes[_nomor].jawaban) _benar++;
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
      builder: (c) => AlertDialog(
        title: const Text('Hasil Tes 🎉'),
        content: Text('Kamu mulai dari Tingkat ${Data.levelSekarang}!', style: const TextStyle(fontSize: 20)),
        actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Ayo main!'))],
      ),
    );
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Color _warnaOpsi(String opsi) {
    if (!_sudahDiperiksa) return opsi == _pilihan ? Colors.indigo.shade100 : Colors.white;
    if (opsi == soalTes[_nomor].jawaban) return Colors.green.shade200;
    if (opsi == _pilihan) return Colors.red.shade200;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final soal = soalTes[_nomor];

    return Scaffold(
      appBar: AppBar(title: Text('Tes Penempatan ${_nomor + 1}/5')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: (_nomor + 1) / 5),
              const SizedBox(height: 24),
              Text(soal.pertanyaan, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              if (soal.didengar != null)
                Center(
                  child: FilledButton.icon(
                    onPressed: () => Suara.ucap(soal.didengar!),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Dengarkan Lagi'),
                  ),
                ),
              const SizedBox(height: 16),
              // Daftar opsi jawaban
              ...soal.opsi.map((opsi) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: _warnaOpsi(opsi),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _sudahDiperiksa ? null : () => setState(() => _pilihan = opsi),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(opsi,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  )),
              const Spacer(),
              if (!_sudahDiperiksa)
                TombolBesar(teks: 'PERIKSA', onTekan: _pilihan == null ? null : _periksa)
              else
                TombolBesar(teks: 'LANJUT', onTekan: _lanjut, warna: Colors.green),
              if (widget.dariOnboarding && _nomor == 0 && !_sudahDiperiksa)
                TextButton(
                  onPressed: () => _selesai(0),
                  child: const Text('Lewati, mulai dari Tingkat 1'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
