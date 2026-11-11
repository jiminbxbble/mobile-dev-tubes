import 'dart:math';
import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 1 - LATIHAN BERTAHAP (GAYA DUOLINGO)
// 10 soal dengar-pilih (vokal A I U E O).
// Lulus jika benar >= 5 dari 10.
// Mode bantuan: pilihan jawaban 5 -> 3.
// Warna: Ungu Duolingo (#7C3AED).
// ===============================================

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
    // Ambil pengecoh selain target, lalu acak
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
      final salah = _jumlahSoal - _benar;
      final bool menang = _benar >= 5;
      selesaiGame(
        context,
        menang: menang,
        salah: salah,
        dibantu: widget.bantuan,
        ringkasan: 'Skor Vokal: $_benar dari $_jumlahSoal Benar',
      );
    }
  }

  Color _warnaLatarOpsi(String opsi) {
    if (!_sudahDiperiksa) return opsi == _pilihan ? const Color(0xFFEDE9FE) : Colors.white;
    if (opsi == _target) return const Color(0xFFD1FAE5); // Hijau lembut
    if (opsi == _pilihan) return const Color(0xFFFEE2E2); // Merah lembut
    return Colors.white;
  }

  Color _warnaGarisOpsi(String opsi) {
    if (!_sudahDiperiksa) return opsi == _pilihan ? const Color(0xFF7C3AED) : Colors.grey.shade300;
    if (opsi == _target) return const Color(0xFF10B981);
    if (opsi == _pilihan) return const Color(0xFFEF4444);
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFF7C3AED);

    return LayarGame(
      judul: 'Latihan Bertahap · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: _nomor / _jumlahSoal,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Soal $_nomor dari $_jumlahSoal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dengarkan bunyinya, lalu pilih huruf yang benar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
          ),
          const SizedBox(height: 16),
          Center(
            child: AnimasiDenyut(
              skalaMaks: 1.08,
              child: TombolSuara(teks: _target, ukuran: 62),
            ),
          ),
          const SizedBox(height: 24),

          // Opsi Jawaban Huruf 3D Taktil
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: _opsi.map((opsi) {
                  final bool terpilih = opsi == _pilihan;
                  return GestureDetector(
                    onTap: _sudahDiperiksa ? null : () => setState(() => _pilihan = opsi),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 90,
                      height: 90,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _warnaLatarOpsi(opsi),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _warnaGarisOpsi(opsi), width: terpilih ? 3 : 2),
                        boxShadow: [
                          BoxShadow(
                            color: terpilih
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.25)
                                : Colors.grey.shade300,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        opsi,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: terpilih ? warnaUtama : const Color(0xFF1E1B2E),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Tombol Periksa / Lanjut
          if (!_sudahDiperiksa)
            TombolBesar(
              teks: 'PERIKSA JAWABAN',
              warna: warnaUtama,
              onTekan: _pilihan == null ? null : _periksa,
            )
          else
            TombolBesar(
              teks: _nomor < _jumlahSoal ? 'LANJUTKAN ➔' : 'SELESAIKAN TAHAP ✨',
              warna: const Color(0xFF10B981),
              onTekan: _lanjut,
            ),
        ],
      ),
    );
  }
}
