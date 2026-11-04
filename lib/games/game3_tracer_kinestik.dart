import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 3 - TRACER KINESTIK (menjiplak huruf b d p q)
// Jalur huruf = daftar titik (checkpoint) di kotak 300x300.
// Jari harus melewati checkpoint berurutan.
// Mengangkat jari di tengah = 1 kesalahan goresan.
// Bantuan: setelah 3 kesalahan, toleransi 30 -> 45.
// ===============================================

// Data jalur dari PRD Lampiran B
const Map<String, List<Offset>> jalurHuruf = {
  'b': [Offset(110, 60), Offset(110, 155), Offset(110, 250), Offset(110, 195), Offset(160, 145), Offset(210, 195), Offset(160, 250), Offset(110, 250)],
  'd': [Offset(190, 195), Offset(140, 145), Offset(90, 195), Offset(140, 250), Offset(190, 250), Offset(190, 60), Offset(190, 155), Offset(190, 250)],
  'p': [Offset(110, 100), Offset(110, 195), Offset(110, 290), Offset(110, 145), Offset(160, 100), Offset(210, 145), Offset(160, 195), Offset(110, 195)],
  'q': [Offset(190, 145), Offset(140, 100), Offset(90, 145), Offset(140, 190), Offset(190, 190), Offset(190, 100), Offset(190, 195), Offset(190, 290)],
};

class TracerKinestikGame extends StatefulWidget {
  final int tahap;
  const TracerKinestikGame({super.key, required this.tahap});

  @override
  State<TracerKinestikGame> createState() => _TracerKinestikGameState();
}

class _TracerKinestikGameState extends State<TracerKinestikGame> {
  String _huruf = 'b';
  int _berikutnya = 1; // indeks checkpoint yang harus dicapai berikutnya
  bool _sedangGores = false;
  Offset? _posisiJari;
  int _salah = 0;
  double _toleransi = 30;
  bool _dibantu = false;
  bool _bantuanDitawarkan = false;
  double _skala = 1; // ukuran layar / 300

  List<Offset> get _jalur => jalurHuruf[_huruf]!;

  void _gantiHuruf(String h) {
    setState(() {
      _huruf = h;
      _ulang();
    });
    Suara.ucap(h);
  }

  void _ulang() {
    _berikutnya = 1;
    _sedangGores = false;
    _posisiJari = null;
  }

  // Jarak dalam satuan kotak 300x300
  double _jarak(Offset jari, Offset titik) => (jari / _skala - titik).distance;

  void _mulai(DragStartDetails d) {
    // Goresan hanya boleh mulai dekat titik jangkar (checkpoint terakhir)
    if (_jarak(d.localPosition, _jalur[_berikutnya - 1]) <= 35) {
      setState(() {
        _sedangGores = true;
        _posisiJari = d.localPosition;
      });
    }
  }

  void _gerak(DragUpdateDetails d) {
    if (!_sedangGores) return;
    setState(() {
      _posisiJari = d.localPosition;
      if (_jarak(d.localPosition, _jalur[_berikutnya]) <= _toleransi) {
        _berikutnya++;
      }
    });
    if (_berikutnya >= _jalur.length) _menang();
  }

  Future<void> _angkat(DragEndDetails d) async {
    if (!_sedangGores) return;
    setState(() {
      _sedangGores = false;
      _posisiJari = null;
    });
    if (_berikutnya >= _jalur.length) return;

    // Jari diangkat sebelum selesai = kesalahan goresan
    _salah++;
    if (_salah >= 3 && !_bantuanDitawarkan) {
      _bantuanDitawarkan = true;
      final mau = await tawarkanBantuan(context);
      if (mau) {
        _dibantu = true;
        _toleransi = 45;
      }
    }
  }

  Future<void> _menang() async {
    _sedangGores = false;
    Suara.ucap('Hebat!');
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) selesaiGame(context, menang: true, salah: _salah, dibantu: _dibantu);
  }

  @override
  Widget build(BuildContext context) {
    return LayarGame(
      judul: 'Tracer Kinestik · Tahap ${widget.tahap}',
      warna: Colors.amber.shade700,
      isi: Column(
        children: [
          // Tab pilih huruf
          SegmentedButton<String>(
            segments: poolBdpq.map((h) => ButtonSegment(value: h, label: Text(h, style: const TextStyle(fontSize: 22)))).toList(),
            selected: {_huruf},
            onSelectionChanged: (s) => _gantiHuruf(s.first),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Jiplak huruf "$_huruf"  ', style: const TextStyle(fontSize: 18)),
              TombolSuara(teks: _huruf),
            ],
          ),
          Text('Mulai dari titik hijau. Kesalahan: $_salah'),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(builder: (context, ukuran) {
                  _skala = ukuran.maxWidth / 300;
                  return GestureDetector(
                    onPanStart: _mulai,
                    onPanUpdate: _gerak,
                    onPanEnd: _angkat,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: CustomPaint(
                        painter: _PelukisJalur(_jalur, _berikutnya, _skala, _posisiJari),
                        size: Size.infinite,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(_ulang),
            icon: const Icon(Icons.refresh),
            label: const Text('Ulangi goresan'),
          ),
        ],
      ),
    );
  }
}

// Menggambar templat huruf, bagian yang sudah dilewati, dan titik target
class _PelukisJalur extends CustomPainter {
  final List<Offset> jalur;
  final int berikutnya;
  final double skala;
  final Offset? jari;

  _PelukisJalur(this.jalur, this.berikutnya, this.skala, this.jari);

  @override
  void paint(Canvas canvas, Size size) {
    final titik = jalur.map((p) => p * skala).toList();

    final abu = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 28 * skala
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final hijau = Paint()
      ..color = Colors.green
      ..strokeWidth = 16 * skala
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Templat abu-abu
    for (int i = 0; i < titik.length - 1; i++) {
      canvas.drawLine(titik[i], titik[i + 1], abu);
    }
    // Segmen yang sudah selesai (hijau)
    for (int i = 0; i < min(berikutnya, titik.length) - 1; i++) {
      canvas.drawLine(titik[i], titik[i + 1], hijau);
    }
    // Garis dari jangkar ke jari
    if (jari != null && berikutnya < titik.length) {
      canvas.drawLine(titik[berikutnya - 1], jari!, hijau..color = Colors.green.shade200);
    }
    if (berikutnya < titik.length) {
      // Titik jangkar (hijau) dan target berikutnya (oranye)
      canvas.drawCircle(titik[berikutnya - 1], 14 * skala, Paint()..color = Colors.green);
      canvas.drawCircle(titik[berikutnya], 14 * skala, Paint()..color = Colors.orange);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
