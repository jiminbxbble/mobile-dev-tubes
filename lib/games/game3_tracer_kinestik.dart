import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 3 - TRACER KINESTIK (GAYA DUOLINGO)
// Menjiplak huruf cermin b, d, p, q.
// Jalur huruf = daftar titik checkpoint di kotak 300x300.
// Jari harus melewati checkpoint berurutan tanpa lepas.
// Bantuan: setelah 3 kesalahan, toleransi dinaikkan dari 30 -> 45.
// Warna: Amber Gold (#F59E0B).
// ===============================================

// Data jalur dari PRD Lampiran B
const Map<String, List<Offset>> jalurHuruf = {
  'b': [
    Offset(110, 60),
    Offset(110, 155),
    Offset(110, 250),
    Offset(110, 195),
    Offset(160, 145),
    Offset(210, 195),
    Offset(160, 250),
    Offset(110, 250)
  ],
  'd': [
    Offset(190, 195),
    Offset(140, 145),
    Offset(90, 195),
    Offset(140, 250),
    Offset(190, 250),
    Offset(190, 60),
    Offset(190, 155),
    Offset(190, 250)
  ],
  'p': [
    Offset(110, 100),
    Offset(110, 195),
    Offset(110, 290),
    Offset(110, 145),
    Offset(160, 100),
    Offset(210, 145),
    Offset(160, 195),
    Offset(110, 195)
  ],
  'q': [
    Offset(190, 145),
    Offset(140, 100),
    Offset(90, 145),
    Offset(140, 190),
    Offset(190, 190),
    Offset(190, 100),
    Offset(190, 195),
    Offset(190, 290)
  ],
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
  double _skala = 1;

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

  double _jarak(Offset jari, Offset titik) => (jari / _skala - titik).distance;

  void _mulai(DragStartDetails d) {
    if (_jarak(d.localPosition, _jalur[_berikutnya - 1]) <= 38) {
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

    _salah++;
    tampilUmpanBalik(context, false);
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
    tampilUmpanBalik(context, true);
    Suara.ucap('Luar biasa!');
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      selesaiGame(
        context,
        menang: true,
        salah: _salah,
        dibantu: _dibantu,
        ringkasan: 'Goresan Huruf "$_huruf" Berhasil!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFFF59E0B);
    final double progres = (_berikutnya - 1) / (_jalur.length - 1);

    return LayarGame(
      judul: 'Tracer Kinestik · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: progres.clamp(0.0, 1.0),
      isi: Column(
        children: [
          // Segmented selector huruf cermin b, d, p, q
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: poolBdpq.map((h) {
                final bool aktif = h == _huruf;
                return GestureDetector(
                  onTap: () => _gantiHuruf(h),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: aktif ? const Color(0xFFEDE9FE) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: aktif ? const Color(0xFF7C3AED) : Colors.transparent, width: 2),
                    ),
                    child: Text(
                      h,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: aktif ? const Color(0xFF7C3AED) : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Petunjuk Goresan
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Jiplak Huruf "$_huruf"',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
              ),
              const SizedBox(width: 8),
              TombolSuara(teks: _huruf, ukuran: 40),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai dari titik hijau 🟢 dan ikuti ke titik oranye 🟠 tanpa melepas jari!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),

          // Area Canvas Menjiplak 3D
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: warnaUtama.withValues(alpha: 0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: hitungWarnaBayangan(warnaUtama).withValues(alpha: 0.25),
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
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
          const SizedBox(height: 12),

          // Tombol Reset Goresan
          TextButton.icon(
            onPressed: () => setState(_ulang),
            icon: const Icon(Icons.refresh_rounded, color: warnaUtama),
            label: const Text('Ulangi Goresan Huruf', style: TextStyle(color: warnaUtama, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

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
      ..color = Colors.grey.shade200
      ..strokeWidth = 32 * skala
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final outlineAbu = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 34 * skala
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final hijau = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 20 * skala
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Templat jalur abu-abu tebal
    for (int i = 0; i < titik.length - 1; i++) {
      canvas.drawLine(titik[i], titik[i + 1], outlineAbu);
      canvas.drawLine(titik[i], titik[i + 1], abu);
    }

    // Segmen yang telah berhasil dilewati (hijau cerah)
    for (int i = 0; i < min(berikutnya, titik.length) - 1; i++) {
      canvas.drawLine(titik[i], titik[i + 1], hijau);
    }

    // Garis aktif dari titik terakhir ke ujung jari
    if (jari != null && berikutnya < titik.length) {
      canvas.drawLine(titik[berikutnya - 1], jari!, hijau..color = const Color(0xFF34D399));
    }

    // Gambar titik checkpoint
    if (berikutnya < titik.length) {
      // Titik jangkar awal (hijau emerald)
      canvas.drawCircle(titik[berikutnya - 1], 15 * skala, Paint()..color = const Color(0xFF10B981));
      canvas.drawCircle(titik[berikutnya - 1], 6 * skala, Paint()..color = Colors.white);

      // Titik target selanjutnya (oranye berdenyut)
      canvas.drawCircle(titik[berikutnya], 16 * skala, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(titik[berikutnya], 7 * skala, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
