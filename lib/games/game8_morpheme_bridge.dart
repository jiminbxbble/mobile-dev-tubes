import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 8 - MORPHEME BRIDGE
// Susun potongan kata berimbuhan (me|nu|lis) untuk membangun jembatan.
// Salah -> jembatan dikosongkan & ubin diacak ulang.
// Menang: 5 kata.
// Bantuan: salah 3x di kata yang sama -> pengecoh hilang + ubin benar ditandai.
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
        // Jembatan selesai
        Suara.ucap(_sekarang.kata);
        tampilUmpanBalik(context, true);
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        _kataKe++;
        if (_kataKe >= 5) {
          selesaiGame(context, menang: true, salah: _salah, dibantu: _dibantu);
          return;
        }
        if (_kataKe % _soal.length == 0) _soal.shuffle(); // semua kata selesai -> acak ulang
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
      if (_salahKataIni == 3 && await tawarkanBantuan(context)) {
        _bantuanAktif = true;
        _dibantu = true;
      }
      setState(_siapkanKata);
    }
  }

  @override
  Widget build(BuildContext context) {
    final potongan = _sekarang.potongan;
    final berikutnya = _terisi < potongan.length ? potongan[_terisi] : '';

    return LayarGame(
      judul: 'Morpheme Bridge · Tahap ${widget.tahap}',
      warna: Colors.blue,
      isi: Column(
        children: [
          Text('Kata ${_kataKe + 1} / 5', style: const TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_sekarang.kata, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              TombolSuara(teks: _sekarang.kata),
            ],
          ),
          const SizedBox(height: 24),
          // Slot jembatan
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < potongan.length; i++)
                Container(
                  margin: const EdgeInsets.all(2),
                  width: 64,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i < _terisi ? Colors.green : Colors.brown.shade200,
                    border: Border.all(color: Colors.brown, width: 2),
                  ),
                  child: Text(i < _terisi ? potongan[i] : '', style: const TextStyle(fontSize: 20, color: Colors.white)),
                ),
            ],
          ),
          const Text('🌉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 24),
          // Ubin pilihan
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < _ubin.length; i++)
                if (!_dipakai[i])
                  ActionChip(
                    label: Text(_ubin[i], style: const TextStyle(fontSize: 22)),
                    padding: const EdgeInsets.all(12),
                    // Mode bantuan: ubin benar berikutnya ditandai
                    backgroundColor: _bantuanAktif && _ubin[i] == berikutnya ? Colors.yellow : null,
                    onPressed: () => _ketukUbin(i),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
