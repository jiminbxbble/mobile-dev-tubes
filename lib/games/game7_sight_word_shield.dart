import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 7 - SIGHT WORD SHIELD (GAYA DUOLINGO)
// Meteor kata jatuh dari langit.
// Tembak (ketuk) meteor dengan ejaan yang benar.
// Tembak salah: -10 HP. Meteor benar lolos: -20 HP.
// Menang: skor 5. Kalah: HP habis (game ini bisa gagal).
// Bantuan: kecepatan meteor diperlambat, pengecoh berkurang.
// Warna: Teal Shield (#0D9488).
// ===============================================

class Meteor {
  final String kata;
  final bool benar;
  final double x; // posisi horizontal 0..1
  double y = 0; // posisi vertikal 0..1
  Meteor(this.kata, this.benar, this.x);
}

class SightWordShieldGame extends StatefulWidget {
  final int tahap;
  final bool bantuan;
  const SightWordShieldGame({super.key, required this.tahap, this.bantuan = false});

  @override
  State<SightWordShieldGame> createState() => _SightWordShieldGameState();
}

class _SightWordShieldGameState extends State<SightWordShieldGame> {
  final Random _acak = Random();
  Timer? _timer;

  String _target = '';
  List<Meteor> _meteor = [];
  int _hp = 100;
  int _skor = 0;
  int _salah = 0;
  bool _selesai = false;

  double get _kecepatan => widget.bantuan ? 0.0042 : 0.006;

  @override
  void initState() {
    super.initState();
    _gelombangBaru();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _jalan());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _kataSalah(String kata) {
    while (true) {
      final huruf = kata.split('');
      final i = _acak.nextInt(huruf.length);
      final cara = _acak.nextInt(3);
      if (cara == 0 && huruf.length > 1) {
        final j = (i + 1) % huruf.length;
        final tmp = huruf[i];
        huruf[i] = huruf[j];
        huruf[j] = tmp;
      } else if (cara == 1 && huruf.length > 2) {
        huruf.removeAt(i);
      } else {
        huruf[i] = 'BDPQMNAIUEO'[_acak.nextInt(11)];
      }
      final hasil = huruf.join();
      if (hasil != kata) return hasil;
    }
  }

  void _gelombangBaru() {
    _target = poolKataDasar[_acak.nextInt(poolKataDasar.length)].toUpperCase();
    final jumlahPengecoh = widget.bantuan ? 2 : 3;
    final Set<String> salah = {};
    while (salah.length < jumlahPengecoh) {
      salah.add(_kataSalah(_target));
    }
    final semua = [_target, ...salah]..shuffle();
    final kolom = List.generate(semua.length, (i) => (i + 0.5) / semua.length);
    _meteor = [
      for (int i = 0; i < semua.length; i++)
        Meteor(semua[i], semua[i] == _target, kolom[i])..y = -_acak.nextDouble() * 0.2,
    ];
    Suara.ucap(_target);
  }

  void _jalan() {
    if (_selesai) return;
    setState(() {
      for (final m in _meteor) {
        m.y += _kecepatan;
      }
      final benarLolos = _meteor.any((m) => m.benar && m.y >= 1);
      _meteor.removeWhere((m) => m.y >= 1);
      if (benarLolos) {
        _hp -= 20;
        _salah++;
        _gelombangBaru();
      }
    });
    _cekAkhir();
  }

  void _tembak(Meteor m) {
    if (_selesai) return;
    setState(() {
      if (m.benar) {
        _skor++;
        _gelombangBaru();
      } else {
        _hp -= 10;
        _salah++;
        _meteor.remove(m);
      }
    });
    tampilUmpanBalik(context, m.benar);
    _cekAkhir();
  }

  Future<void> _cekAkhir() async {
    if (_selesai) return;
    if (_skor >= 5) {
      _selesai = true;
      _timer?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      selesaiGame(
        context,
        menang: true,
        salah: _hp == 100 ? 0 : _salah,
        dibantu: widget.bantuan,
        ringkasan: 'Perisai Kokoh Bertahan (HP $_hp%)!',
      );
    } else if (_hp <= 0) {
      _selesai = true;
      _timer?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      selesaiGame(
        context,
        menang: false,
        salah: _salah,
        ringkasan: 'Perisai Jebol (Skor $_skor dari 5)',
      );
    }
  }

  Color _warnaHp(int hp) {
    if (hp > 50) return const Color(0xFF10B981);
    if (hp > 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFF0D9488);
    final double progresSkor = (_skor / 5).clamp(0.0, 1.0);
    final int hpSaatIni = max(_hp, 0);

    return LayarGame(
      judul: 'Sight Word Shield · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: progresSkor,
      isi: Column(
        children: [
          // Baris Status Skor & HP Perisai
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
                Row(
                  children: [
                    const Text('Skor: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('$_skor / 5 🛡️', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: warnaUtama)),
                  ],
                ),
                Row(
                  children: [
                    Text('HP: $hpSaatIni%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _warnaHp(hpSaatIni))),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: hpSaatIni / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          color: _warnaHp(hpSaatIni),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sasaran Kata Ejaan Benar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tembak Ejaan: ', style: TextStyle(fontSize: 18, color: Color(0xFF1E1B2E))),
              Text(
                _target,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: warnaUtama),
              ),
              const SizedBox(width: 6),
              TombolSuara(teks: _target, ukuran: 38),
            ],
          ),
          const SizedBox(height: 12),

          // Area Langit Luar Angkasa Tempat Meteor Jatuh
          Expanded(
            child: LayoutBuilder(builder: (context, ukuran) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blueGrey.shade800, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Grid bintang latar belakang
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: GridView.count(
                            crossAxisCount: 6,
                            children: List.generate(24, (i) => const Center(child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 14)))),
                          ),
                        ),
                      ),
                      // Meteor-meteor yang sedang meluncur jatuh
                      for (final m in _meteor)
                        Positioned(
                          left: (m.x * ukuran.maxWidth - 50).clamp(8.0, ukuran.maxWidth - 108.0),
                          top: m.y * (ukuran.maxHeight - 60),
                          child: GestureDetector(
                            onTap: () => _tembak(m),
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFFDBA74), width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Color(0xFF9A3412), offset: Offset(0, 4), blurRadius: 0),
                                ],
                              ),
                              child: Text(
                                m.kata,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
