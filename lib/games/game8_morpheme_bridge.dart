import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 8 - MORPHEME BRIDGE (GAYA DUOLINGO)
// Susun potongan kata berimbuhan (me|nu|lis) untuk membangun jembatan.
// Salah -> jembatan dikosongkan & ubin diacak ulang.
// Menang: 5 kata.
// Bantuan: salah 3x di kata yang sama -> pengecoh hilang + ubin benar ditandai.
// Warna: Indigo Blue (#4F46E5).
// ===============================================

class MorphemeBridgeGame extends StatefulWidget {
  final int tahap;
  const MorphemeBridgeGame({super.key, required this.tahap});

  @override
  State<MorphemeBridgeGame> createState() => _MorphemeBridgeGameState();
}

class _MorphemeBridgeGameState extends State<MorphemeBridgeGame> {
  late List<SoalJembatan> _soal;
  int _kataKe = 0;
  List<String> _ubin = [];
  List<bool> _dipakai = [];
  int _terisi = 0;
  int _salah = 0;
  int _salahKataIni = 0;
  bool _bantuanAktif = false;
  bool _dibantu = false;

  SoalJembatan get _sekarang => _soal[_kataKe % _soal.length];

  @override
  void initState() {
    super.initState();
    _soal = List.of(poolJembatan)..shuffle();
    _siapkanKata();
  }

  void _siapkanKata() {
    _terisi = 0;
    _ubin = [..._sekarang.potongan, if (!_bantuanAktif) ..._sekarang.pengecoh]..shuffle();
    _dipakai = List.filled(_ubin.length, false);
  }

  Future<void> _ketukUbin(int i) async {
    if (_dipakai[i]) return;

    if (_ubin[i] == _sekarang.potongan[_terisi]) {
      setState(() {
        _dipakai[i] = true;
        _terisi++;
      });
      if (_terisi == _sekarang.potongan.length) {
        // Jembatan kata selesai terbentuk
        Suara.ucap(_sekarang.kata);
        tampilUmpanBalik(context, true);
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        _kataKe++;
        if (_kataKe >= 5) {
          selesaiGame(
            context,
            menang: true,
            salah: _salah,
            dibantu: _dibantu,
            ringkasan: '5 Jembatan Kata Berimbuhan Berhasil!',
          );
          return;
        }
        if (_kataKe % _soal.length == 0) _soal.shuffle();
        setState(() {
          _salahKataIni = 0;
          _bantuanAktif = false;
          _siapkanKata();
        });
        Suara.ucap(_sekarang.kata);
      }
    } else {
      tampilUmpanBalik(context, false);
      _salah++;
      _salahKataIni++;
      if (_salahKataIni >= 3 && await tawarkanBantuan(context)) {
        _bantuanAktif = true;
        _dibantu = true;
      }
      setState(_siapkanKata);
    }
  }



  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFF4F46E5);
    final potongan = _sekarang.potongan;
    final berikutnya = _terisi < potongan.length ? potongan[_terisi] : '';
    final double progres = (_kataKe / 5).clamp(0.0, 1.0);

    return LayarGame(
      judul: 'Morpheme Bridge · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: progres,
      isi: Column(
        children: [
          // Status Kata
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
                const Text('Jembatan Dibangun:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${_kataKe + 1} / 5', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaUtama)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kata Berimbuhan
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _sekarang.kata,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
              ),
              const SizedBox(width: 8),
              TombolSuara(teks: _sekarang.kata, ukuran: 40),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Susun potongan kata secara berurutan untuk membangun jembatan:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Slot Jembatan 3D (Balok Kayu & Batu)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blueGrey.shade200, width: 2),
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < potongan.length; i++)
                      Container(
                        width: 74,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < _terisi ? const Color(0xFF10B981) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: i < _terisi ? const Color(0xFF059669) : Colors.grey.shade400,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: i < _terisi ? const Color(0xFF059669) : Colors.grey.shade300,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          i < _terisi ? potongan[i] : '?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: i < _terisi ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.horizontal_rule_rounded, color: Colors.blueGrey),
                    SizedBox(width: 6),
                    Text('Jalur Balok Jembatan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13)),
                    SizedBox(width: 6),
                    Icon(Icons.horizontal_rule_rounded, color: Colors.blueGrey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Pilih balok morfem berikutnya:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
          ),
          const SizedBox(height: 16),

          // Ubin-ubin Morfem 3D
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < _ubin.length; i++)
                    if (!_dipakai[i])
                      GestureDetector(
                        onTap: () => _ketukUbin(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          decoration: BoxDecoration(
                            color: (_bantuanAktif && _ubin[i] == berikutnya)
                                ? const Color(0xFFFEF3C7) // Emas bantuan
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: (_bantuanAktif && _ubin[i] == berikutnya)
                                  ? const Color(0xFFF59E0B)
                                  : warnaUtama,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_bantuanAktif && _ubin[i] == berikutnya)
                                    ? const Color(0xFFD97706)
                                    : hitungWarnaBayangan(warnaUtama),
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            _ubin[i],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: (_bantuanAktif && _ubin[i] == berikutnya)
                                  ? const Color(0xFFB45309)
                                  : warnaUtama,
                            ),
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
