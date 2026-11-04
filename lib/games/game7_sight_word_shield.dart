import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 7 - SIGHT WORD SHIELD
// Meteor berisi kata jatuh. Tembak (ketuk) meteor dengan ejaan benar.
// Tembak salah: -10 HP. Meteor benar lolos: -20 HP.
// Menang: skor 5. Kalah: HP habis (game ini bisa gagal).
// Bantuan (dari Peta Tahap setelah gagal 3x): meteor lebih lambat, pengecoh 2.
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

  double get _kecepatan => widget.bantuan ? 0.0042 : 0.006; // per 50 ms

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

  // Membuat kata salah: tukar 2 huruf, hapus 1 huruf, atau ganti 1 huruf
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
      for (int i = 0; i < semua.length; i++) Meteor(semua[i], semua[i] == _target, kolom[i])..y = -_acak.nextDouble() * 0.2,
    ];
    Suara.ucap(_target);
  }

  // Dipanggil tiap 50 ms: meteor turun
  void _jalan() {
    if (_selesai) return;
    setState(() {
      for (final m in _meteor) {
        m.y += _kecepatan;
      }
      // Meteor benar lolos ke bawah -> -20 HP
      final benarLolos = _meteor.any((m) => m.benar && m.y >= 1);
      _meteor.removeWhere((m) => m.y >= 1); // meteor salah lolos tanpa penalti
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
      selesaiGame(context, menang: true, salah: _hp == 100 ? 0 : _salah, dibantu: widget.bantuan);
    } else if (_hp <= 0) {
      _selesai = true;
      _timer?.cancel();
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text('Perisai Hancur! 💥'),
          content: Text('Skor kamu: $_skor', style: const TextStyle(fontSize: 20)),
          actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
      if (mounted) selesaiGame(context, menang: false, salah: _salah);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayarGame(
      judul: 'Sight Word Shield · Tahap ${widget.tahap}',
      warna: Colors.teal,
      isi: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Skor: $_skor / 5', style: const TextStyle(fontSize: 18)),
              Text('🛡️ HP: ${max(_hp, 0)}', style: const TextStyle(fontSize: 18)),
            ],
          ),
          LinearProgressIndicator(value: max(_hp, 0) / 100, color: Colors.teal, minHeight: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tembak: $_target', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              TombolSuara(teks: _target),
            ],
          ),
          // Area langit tempat meteor jatuh
          Expanded(
            child: LayoutBuilder(builder: (context, ukuran) {
              return Container(
                decoration: BoxDecoration(color: const Color(0xFF131F24), borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  children: [
                    for (final m in _meteor)
                      Positioned(
                        left: m.x * ukuran.maxWidth - 45,
                        top: m.y * (ukuran.maxHeight - 60),
                        child: GestureDetector(
                          onTap: () => _tembak(m),
                          child: Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(30)),
                            child: Text(m.kata,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
