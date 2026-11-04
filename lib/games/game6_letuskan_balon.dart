import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 6 - LETUSKAN BALON
// Kata dipecah jadi suku kata (MAKAN -> MA | KAN).
// Ketuk balon suku kata sesuai urutan. Salah -> urutan mulai lagi.
// Menang: membentuk 5 kata.
// Bantuan: setelah 6 ketukan salah, balon target lebih banyak.
// ===============================================

class LetuskanBalonGame extends StatefulWidget {
  final int tahap;
  const LetuskanBalonGame({super.key, required this.tahap});

  @override
  State<LetuskanBalonGame> createState() => _LetuskanBalonGameState();
}

class _LetuskanBalonGameState extends State<LetuskanBalonGame> {
  final Random _acak = Random();
  final List<Color> _warnaBalon = [Colors.red, Colors.orange, Colors.purple, Colors.blue, Colors.pink, Colors.teal];

  late List<String> _daftarKata;
  int _kataKe = 0;
  int _terisi = 0; // berapa suku kata sudah benar
  List<String> _balon = [];
  int _salah = 0;
  int _salahPercobaan = 0;
  bool _dibantu = false;
  bool _bantuanDitawarkan = false;

  String get _kata => _daftarKata[_kataKe % _daftarKata.length];
  List<String> get _suku => pecahanSukuKata[_kata]!;

  @override
  void initState() {
    super.initState();
    _daftarKata = pecahanSukuKata.keys.toList()..shuffle();
    _isiBalon();
    Suara.ucap(_kata);
  }

  // 6 balon: sebagian besar suku kata yang dicari, 1 suku kata lain dari kata itu, sisanya pengecoh
  void _isiBalon() {
    final dicari = _suku[_terisi];
    final jumlahTarget = _dibantu ? 4 : 3;
    final lain = _suku.where((s) => s != dicari).toList();
    final pengecoh = (List.of(sukuKataPengecoh)..shuffle()).where((s) => !_suku.contains(s)).toList();

    _balon = [
      for (int i = 0; i < jumlahTarget; i++) dicari,
      if (lain.isNotEmpty) lain[_acak.nextInt(lain.length)],
    ];
    _balon.addAll(pengecoh.take(6 - _balon.length));
    _balon.shuffle();
  }

  Future<void> _letuskan(String suku) async {
    if (suku == _suku[_terisi]) {
      Suara.ucap(suku);
      setState(() => _terisi++);
      if (_terisi == _suku.length) {
        // Kata selesai
        tampilUmpanBalik(context, true);
        _kataKe++;
        if (_kataKe >= 5) {
          selesaiGame(context, menang: true, salah: _salah, dibantu: _dibantu);
          return;
        }
        setState(() => _terisi = 0);
        Suara.ucap(_kata);
      }
    } else {
      // Salah -> urutan kembali ke awal
      tampilUmpanBalik(context, false);
      _salah++;
      _salahPercobaan++;
      setState(() => _terisi = 0);
      if (_salahPercobaan >= 6 && !_bantuanDitawarkan) {
        _bantuanDitawarkan = true;
        _dibantu = await tawarkanBantuan(context);
      }
    }
    if (mounted) setState(_isiBalon);
  }

  @override
  Widget build(BuildContext context) {
    return LayarGame(
      judul: 'Letuskan Balon · Tahap ${widget.tahap}',
      warna: Colors.purple,
      isi: Column(
        children: [
          Text('Kata ${_kataKe + 1} / 5', style: const TextStyle(fontSize: 16)),
          const Text('BENTUK KATA', style: TextStyle(fontSize: 16, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_kata, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              TombolSuara(teks: _kata),
            ],
          ),
          // Indikator suku kata yang sudah terisi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _suku.length; i++)
                Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: i < _terisi ? Colors.green : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(i < _terisi ? _suku[i] : '?', style: const TextStyle(fontSize: 22, color: Colors.black)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Balon-balon
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (int i = 0; i < _balon.length; i++)
                  GestureDetector(
                    onTap: () => _letuskan(_balon[i]),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 110,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _warnaBalon[i % _warnaBalon.length],
                            borderRadius: const BorderRadius.all(Radius.elliptical(90, 110)),
                          ),
                          child: Text(_balon[i],
                              style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        Container(width: 2, height: 20, color: Colors.grey), // tali balon
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
