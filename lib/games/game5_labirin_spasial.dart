import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 5 - LABIRIN SPASIAL (GAYA DUOLINGO)
// Navigasi spasial 7x7 dengan D-pad 3D.
// Menuju huruf target (b/d/p/q) untuk melatih kognisi arah.
// Menang: 5 ronde benar.
// Bantuan: setelah 3x salah, kotak target ditandai 3 detik.
// Warna: Electric Cyan (#06B6D4).
// ===============================================

Set<Point<int>> _kotak(List<List<int>> daftar) => daftar.map((p) => Point(p[0], p[1])).toSet();

class Labirin {
  final Set<Point<int>> jalan;
  final List<Point<int>> posisiHuruf;
  const Labirin(this.jalan, this.posisiHuruf);
}

// 3 tata letak labirin dari PRD Lampiran C. Titik start di (3,6).
final List<Labirin> daftarLabirin = [
  // Tata Letak Salib
  Labirin(
    _kotak([for (int y = 1; y <= 6; y++) [3, y], for (int x = 1; x <= 5; x++) [x, 3]]),
    [const Point(1, 3), const Point(3, 1), const Point(5, 3)],
  ),
  // Tata Letak Trisula
  Labirin(
    _kotak([
      for (int y = 1; y <= 2; y++) ...[[1, y], [3, y], [5, y]],
      for (int x = 1; x <= 5; x++) [x, 3],
      for (int y = 4; y <= 6; y++) [3, y],
    ]),
    [const Point(1, 1), const Point(3, 1), const Point(5, 1)],
  ),
  // Tata Letak Putaran
  Labirin(
    _kotak([
      for (int x = 1; x <= 5; x++) [x, 1],
      for (int y = 1; y <= 5; y++) ...[[1, y], [5, y]],
      for (int x = 1; x <= 5; x++) [x, 5],
      [3, 3], [3, 4], [3, 6],
    ]),
    [const Point(1, 1), const Point(3, 3), const Point(5, 1)],
  ),
];

class LabirinSpasialGame extends StatefulWidget {
  final int tahap;
  const LabirinSpasialGame({super.key, required this.tahap});

  @override
  State<LabirinSpasialGame> createState() => _LabirinSpasialGameState();
}

class _LabirinSpasialGameState extends State<LabirinSpasialGame> {
  final Random _acak = Random();
  static const Point<int> _start = Point(3, 6);

  late Labirin _labirin;
  Map<Point<int>, String> _huruf = {};
  String _target = '';
  Point<int> _pemain = _start;
  int _ronde = 0;
  int _salah = 0;
  int _salahRondeIni = 0;
  bool _tandaiTarget = false;
  bool _dibantu = false;

  @override
  void initState() {
    super.initState();
    _rondeBaru();
  }

  void _rondeBaru() {
    _labirin = daftarLabirin[_acak.nextInt(daftarLabirin.length)];
    final hurufAcak = (List.of(poolBdpq)..shuffle()).take(3).toList();
    _huruf = {
      for (int i = 0; i < 3; i++) _labirin.posisiHuruf[i]: hurufAcak[i],
    };
    _target = hurufAcak[_acak.nextInt(3)];
    _pemain = _start;
    _salahRondeIni = 0;
    Suara.ucap(_target);
  }

  Future<void> _gerak(int dx, int dy) async {
    final tujuan = Point(_pemain.x + dx, _pemain.y + dy);
    if (!_labirin.jalan.contains(tujuan)) return; // Tembok tidak bisa dilewati
    setState(() => _pemain = tujuan);

    final hurufDiSini = _huruf[tujuan];
    if (hurufDiSini == null) return;

    if (hurufDiSini == _target) {
      tampilUmpanBalik(context, true);
      _ronde++;
      if (_ronde >= 5) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        selesaiGame(
          context,
          menang: true,
          salah: _salah,
          dibantu: _dibantu,
          ringkasan: '5 Labirin Spasial Huruf Selesai!',
        );
        return;
      }
      setState(_rondeBaru);
    } else {
      tampilUmpanBalik(context, false);
      _salah++;
      _salahRondeIni++;
      setState(() => _pemain = _start);
      if (_salahRondeIni >= 3 && await tawarkanBantuan(context)) {
        _dibantu = true;
        setState(() => _tandaiTarget = true);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) setState(() => _tandaiTarget = false);
      }
    }
  }

  Widget _kotakGrid(int x, int y) {
    final p = Point(x, y);
    final jalan = _labirin.jalan.contains(p);
    final huruf = _huruf[p];
    final target = _tandaiTarget && huruf == _target;

    return Container(
      margin: const EdgeInsets.all(1.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: jalan ? const Color(0xFFE0F2FE) : const Color(0xFF1E293B),
        border: target
            ? Border.all(color: const Color(0xFF10B981), width: 3.5)
            : (jalan ? Border.all(color: Colors.blue.shade100, width: 1) : null),
        borderRadius: BorderRadius.circular(8),
      ),
      child: p == _pemain
          ? Text(Data.avatar.isNotEmpty ? Data.avatar : '🧒', style: const TextStyle(fontSize: 22))
          : (huruf != null
              ? Text(
                  huruf,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: target ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                  ),
                )
              : null),
    );
  }

  Widget _tombolDpad(IconData ikon, int dx, int dy) {
    return GestureDetector(
      onTap: () => _gerak(dx, dy),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF06B6D4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0xFF0891B2), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Icon(ikon, color: Colors.white, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFF06B6D4);
    final double progres = (_ronde / 5).clamp(0.0, 1.0);

    return LayarGame(
      judul: 'Labirin Spasial · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: progres,
      isi: Column(
        children: [
          // Baris Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ronde Labirin:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${_ronde + 1} / 5 🧭', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaUtama)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Huruf Target
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Arahkan ke huruf "$_target"  ',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
              ),
              TombolSuara(teks: _target, ukuran: 42),
            ],
          ),
          const SizedBox(height: 10),

          // Grid Labirin 7x7
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4),
                ],
              ),
              child: GridView.count(
                crossAxisCount: 7,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int y = 0; y < 7; y++)
                    for (int x = 0; x < 7; x++) _kotakGrid(x, y),
                ],
              ),
            ),
          ),
          const Spacer(),

          // D-pad Pengontrol 3D
          _tombolDpad(Icons.arrow_upward_rounded, 0, -1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tombolDpad(Icons.arrow_back_rounded, -1, 0),
              const SizedBox(width: 52),
              _tombolDpad(Icons.arrow_forward_rounded, 1, 0),
            ],
          ),
          const SizedBox(height: 6),
          _tombolDpad(Icons.arrow_downward_rounded, 0, 1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
