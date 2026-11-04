import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

class LatihanBertahapGame extends StatefulWidget {
  final int tahap;
  final bool bantuan;
  const LatihanBertahapGame({super.key, required this.tahap, this.bantuan = false});

  @override
  State<LatihanBertahapGame> createState() => _LatihanBertahapGameState();
}

class _LatihanBertahapGameState extends State<LatihanBertahapGame> {
  final Random _acak = Random();
  final int _jumlahSoal = 10;

  int _nomor = 1;
  int _benar = 0;
  String _target = '';
  List<String> _opsi = [];
  String? _pilihan;
  bool _sudahDiperiksa = false;

  @override
  void initState() {
    super.initState();
    _buatSoal();
  }

  void _buatSoal() {
    _target = poolVokal[_acak.nextInt(poolVokal.length)];
    final pengecoh = poolVokal.where((h) => h != _target).toList()..shuffle();
    final jumlahPengecoh = widget.bantuan ? 2 : 4;
    _opsi = [_target, ...pengecoh.take(jumlahPengecoh)]..shuffle();
    _pilihan = null;
    _sudahDiperiksa = false;
    Future.delayed(const Duration(milliseconds: 550), () => Suara.ucap(_target));
  }

  void _periksa() {
    final benar = _pilihan == _target;
    setState(() {
      _sudahDiperiksa = true;
      if (benar) _benar++;
    });
    tampilUmpanBalik(context, benar);
  }

  void _lanjut() {
    if (_nomor < _jumlahSoal) {
      setState(() {
        _nomor++;
        _buatSoal();
      });
    } else {
      _tampilSelesai();
    }
  }

  Future<void> _tampilSelesai() async {
    final salah = _jumlahSoal - _benar;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('Selesai!'),
        content: Text('Benar: $_benar\nSalah: $salah', style: const TextStyle(fontSize: 20)),
        actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Lihat hasil'))],
      ),
    );
    if (!mounted) return;
    selesaiGame(context, menang: _benar >= 5, salah: salah, dibantu: widget.bantuan);
  }

  Color _warnaOpsi(String opsi) {
    if (!_sudahDiperiksa) return opsi == _pilihan ? Colors.indigo.shade100 : Colors.white;
    if (opsi == _target) return Colors.green.shade300;
    if (opsi == _pilihan) return Colors.red.shade300;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return LayarGame(
      judul: 'Latihan Bertahap · Tahap ${widget.tahap}',
      warna: Colors.indigo,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: _nomor / _jumlahSoal, minHeight: 8),
          const SizedBox(height: 8),
          Text('Soal $_nomor dari $_jumlahSoal', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text('Dengarkan, lalu pilih huruf yang benar', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Center(child: TombolSuara(teks: _target)),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _opsi.map((opsi) {
              return GestureDetector(
                onTap: _sudahDiperiksa ? null : () => setState(() => _pilihan = opsi),
                child: Container(
                  width: 90,
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _warnaOpsi(opsi),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo, width: 2),
                  ),
                  child: Text(opsi, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          if (!_sudahDiperiksa)
            TombolBesar(teks: 'PERIKSA', onTekan: _pilihan == null ? null : _periksa)
          else
            TombolBesar(teks: 'LANJUT', warna: Colors.green, onTekan: _lanjut),
        ],
      ),
    );
  }
}
