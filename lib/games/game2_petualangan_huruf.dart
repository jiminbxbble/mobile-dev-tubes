import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 2 - PETUALANGAN HURUF (GAYA DUOLINGO)
// Kartu memori suku kata.
// Jumlah pasangan = tahap + 1. Cocokkan 2 kartu yang sama.
// Bantuan: setelah 10x tidak cocok, semua kartu diintip 2 detik.
// Warna: Emerald Mint (#10B981).
// ===============================================

class PetualanganHurufGame extends StatefulWidget {
  final int tahap;
  const PetualanganHurufGame({super.key, required this.tahap});

  @override
  State<PetualanganHurufGame> createState() => _PetualanganHurufGameState();
}

class _PetualanganHurufGameState extends State<PetualanganHurufGame> {
  List<String> _kartu = []; // isi tiap kartu
  List<bool> _cocok = []; // kartu yang sudah cocok
  List<int> _terbuka = []; // indeks kartu yang sedang dibuka (maks 2)
  bool _papanTerkunci = false;
  bool _intip = false;
  int _salah = 0;
  bool _bantuanSudahDitawarkan = false;
  bool _dibantu = false;

  int get _jumlahPasangan => (widget.tahap + 1).clamp(2, poolSukuKata.length);

  @override
  void initState() {
    super.initState();
    final item = (List.of(poolSukuKata)..shuffle()).take(_jumlahPasangan).toList();
    _kartu = [...item, ...item]..shuffle(); // tiap item muncul 2 kali
    _cocok = List.filled(_kartu.length, false);
  }

  Future<void> _ketukKartu(int i) async {
    if (_papanTerkunci || _cocok[i] || _terbuka.contains(i)) return;

    setState(() => _terbuka.add(i));
    Suara.ucap(_kartu[i]);
    if (_terbuka.length < 2) return;

    // Dua kartu terbuka -> periksa kecocokan
    _papanTerkunci = true;
    final a = _terbuka[0];
    final b = _terbuka[1];

    if (_kartu[a] == _kartu[b]) {
      setState(() {
        _cocok[a] = true;
        _cocok[b] = true;
        _terbuka = [];
      });
      _papanTerkunci = false;
      tampilUmpanBalik(context, true);

      if (!_cocok.contains(false)) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        selesaiGame(
          context,
          menang: true,
          salah: _salah > _jumlahPasangan ? 1 : 0,
          dibantu: _dibantu,
          ringkasan: 'Cocok $_jumlahPasangan Pasangan Suku Kata!',
        );
      }
    } else {
      _salah++;
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _terbuka = []);
      _papanTerkunci = false;
      await _cekBantuan();
    }
  }

  Future<void> _cekBantuan() async {
    if (_salah < 10 || _bantuanSudahDitawarkan) return;
    _bantuanSudahDitawarkan = true;
    final mau = await tawarkanBantuan(context);
    if (!mau || !mounted) return;
    _dibantu = true;
    setState(() => _intip = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _intip = false);
  }



  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFF10B981);
    final int jumlahCocok = _cocok.where((c) => c).length ~/ 2;
    final double progres = (_jumlahPasangan > 0) ? (jumlahCocok / _jumlahPasangan) : 0.0;

    return LayarGame(
      judul: 'Petualangan Huruf · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: progres,
      isi: Column(
        children: [
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
                const Text('Pasangan Ditemukan:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  '$jumlahCocok / $_jumlahPasangan 🃏',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaUtama),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Buka dan cocokkan 2 kartu bersuku kata sama!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF1E1B2E), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Papan Grid Kartu 3D Memori
          Expanded(
            child: GridView.builder(
              itemCount: _kartu.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _kartu.length > 8 ? 4 : 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, i) {
                final bool terbuka = _cocok[i] || _terbuka.contains(i) || _intip;
                final bool sudahCocok = _cocok[i];

                return GestureDetector(
                  onTap: () => _ketukKartu(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sudahCocok
                          ? const Color(0xFFD1FAE5) // Hijau lembut cocok
                          : (terbuka ? Colors.white : warnaUtama),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: sudahCocok
                            ? const Color(0xFF10B981)
                            : (terbuka ? warnaUtama : hitungWarnaBayangan(warnaUtama)),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: sudahCocok
                              ? const Color(0xFF059669).withValues(alpha: 0.4)
                              : (terbuka ? Colors.grey.shade300 : hitungWarnaBayangan(warnaUtama)),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        terbuka ? _kartu[i] : '?',
                        style: TextStyle(
                          fontSize: terbuka ? 26 : 30,
                          fontWeight: FontWeight.bold,
                          color: sudahCocok
                              ? const Color(0xFF065F46)
                              : (terbuka ? const Color(0xFF1E1B2E) : Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
