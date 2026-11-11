import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 6 - LETUSKAN BALON (GAYA DUOLINGO)
// Kata dipecah menjadi suku kata (MAKAN -> MA | KAN).
// Ketuk balon suku kata 3D sesuai urutan yang tepat.
// Menang: berhasil menyusun 5 kata.
// Bantuan: setelah 6x salah, balon target dimunculkan lebih banyak.
// Warna: Purple Violet (#9333EA).
// ===============================================

class LetuskanBalonGame extends StatefulWidget {
  final int tahap;
  const LetuskanBalonGame({super.key, required this.tahap});

  @override
  State<LetuskanBalonGame> createState() => _LetuskanBalonGameState();
}

class _LetuskanBalonGameState extends State<LetuskanBalonGame> {
  final Random _acak = Random();
  final List<Color> _warnaBalon = [
    const Color(0xFFEF4444), // Coral Red
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF7C3AED), // Royal Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF10B981), // Emerald
    const Color(0xFFEC4899), // Pink
  ];

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
        tampilUmpanBalik(context, true);
        _kataKe++;
        if (_kataKe >= 5) {
          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;
          selesaiGame(
            context,
            menang: true,
            salah: _salah,
            dibantu: _dibantu,
            ringkasan: '5 Kata Suku Kata Berhasil Dirangkai!',
          );
          return;
        }
        setState(() => _terisi = 0);
        Suara.ucap(_kata);
      }
    } else {
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
    const Color warnaUtama = Color(0xFF9333EA);
    final double progres = ((_kataKe * _suku.length + _terisi) / (5 * _suku.length)).clamp(0.0, 1.0);

    return LayarGame(
      judul: 'Letuskan Balon · Tahap ${widget.tahap}',
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
                const Text('Kata Disusun:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${_kataKe + 1} / 5', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaUtama)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kata Target
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_kata, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E))),
              const SizedBox(width: 8),
              TombolSuara(teks: _kata, ukuran: 42),
            ],
          ),
          const SizedBox(height: 10),

          // Slot Puzzle Suku Kata 3D
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _suku.length; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: i < _terisi ? const Color(0xFF10B981) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: i < _terisi ? const Color(0xFF059669) : Colors.purple.shade200,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: i < _terisi ? const Color(0xFF059669) : Colors.purple.shade100,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    i < _terisi ? _suku[i] : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: i < _terisi ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ketuk balon suku kata selanjutnya: "${_suku[_terisi]}"',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
          ),
          const SizedBox(height: 16),

          // Area Balon-balon 3D Mengambang
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 14,
                children: [
                  for (int i = 0; i < _balon.length; i++)
                    AnimasiMelayang(
                      amplitudo: 5.0 + (i % 3) * 2.0,
                      durasi: Duration(milliseconds: 1800 + (i % 4) * 300),
                      child: GestureDetector(
                        onTap: () => _letuskan(_balon[i]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90,
                              height: 105,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _warnaBalon[i % _warnaBalon.length],
                                borderRadius: const BorderRadius.all(Radius.elliptical(90, 105)),
                                border: Border.all(
                                  color: hitungWarnaBayangan(_warnaBalon[i % _warnaBalon.length]),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: hitungWarnaBayangan(_warnaBalon[i % _warnaBalon.length]),
                                    offset: const Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Kilau pantulan cahaya di balon
                                  Positioned(
                                    top: 12,
                                    left: 18,
                                    child: Container(
                                      width: 14,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        borderRadius: const BorderRadius.all(Radius.elliptical(14, 8)),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _balon[i],
                                    style: const TextStyle(
                                      fontSize: 26,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tali balon
                            Container(
                              width: 2.5,
                              height: 18,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
