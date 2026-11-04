import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 5 - LABIRIN SPASIAL (7x7)
// Gerakkan pemain dengan D-pad menuju huruf target (b/d/p/q).
// Huruf salah -> kembali ke start. Menang: 5 ronde benar.
// Bantuan: setelah 3 huruf salah, kotak target ditandai 3 detik.
// ===============================================

// Membuat daftar kotak jalan dari daftar (x, y)
Set<Point<int>> _kotak(List<List<int>> daftar) => daftar.map((p) => Point(p[0], p[1])).toSet();

class Labirin {
  final Set<Point<int>> jalan;
  final List<Point<int>> posisiHuruf;
  const Labirin(this.jalan, this.posisiHuruf);
}

// 3 tata letak dari PRD Lampiran C. Start selalu di (3,6).
final List<Labirin> daftarLabirin = [
  // Salib
  Labirin(
    _kotak([for (int y = 1; y <= 6; y++) [3, y], for (int x = 1; x <= 5; x++) [x, 3]]),
    [const Point(1, 3), const Point(3, 1), const Point(5, 3)],
  ),
  // Trisula
  Labirin(
    _kotak([
      for (int y = 1; y <= 2; y++) ...[[1, y], [3, y], [5, y]],
      for (int x = 1; x <= 5; x++) [x, 3],
      for (int y = 4; y <= 6; y++) [3, y],
    ]),
    [const Point(1, 1), const Point(3, 1), const Point(5, 1)],
  ),
  // Putaran
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
  Map<Point<int>, String> _huruf = {}; // posisi -> huruf
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
    if (!_labirin.jalan.contains(tujuan)) return; // tembok
    setState(() => _pemain = tujuan);

    final hurufDiSini = _huruf[tujuan];
    if (hurufDiSini == null) return;

    if (hurufDiSini == _target) {
      tampilUmpanBalik(context, true);
      _ronde++;
      if (_ronde >= 5) {
        selesaiGame(context, menang: true, salah: _salah, dibantu: _dibantu);
        return;
      }
      setState(_rondeBaru);
    } else {
      tampilUmpanBalik(context, false);
      _salah++;
      _salahRondeIni++;
      setState(() => _pemain = _start);
      if (_salahRondeIni == 3 && await tawarkanBantuan(context)) {
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
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: jalan ? Colors.cyan.shade50 : Colors.blueGrey.shade700,
        border: target ? Border.all(color: Colors.green, width: 4) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: p == _pemain
          ? const Text('🧒', style: TextStyle(fontSize: 26))
          : (huruf != null
              ? Text(huruf, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black))
              : null),
    );
  }

  Widget _tombolArah(IconData ikon, int dx, int dy) {
    return IconButton.filled(iconSize: 36, icon: Icon(ikon), onPressed: () => _gerak(dx, dy));
  }

  @override
  Widget build(BuildContext context) {
    return LayarGame(
      judul: 'Labirin Spasial · Tahap ${widget.tahap}',
      warna: Colors.cyan.shade700,
      isi: Column(
        children: [
          Text('Ronde ${_ronde + 1} / 5', style: const TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Cari jalan menuju huruf: $_target', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              TombolSuara(teks: _target),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (int y = 0; y < 7; y++)
                  for (int x = 0; x < 7; x++) _kotakGrid(x, y),
              ],
            ),
          ),
          const Spacer(),
          // D-pad 4 arah
          _tombolArah(Icons.arrow_upward, 0, -1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tombolArah(Icons.arrow_back, -1, 0),
              const SizedBox(width: 64),
              _tombolArah(Icons.arrow_forward, 1, 0),
            ],
          ),
          _tombolArah(Icons.arrow_downward, 0, 1),
        ],
      ),
    );
  }
}
