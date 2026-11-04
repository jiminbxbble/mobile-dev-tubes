import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

class PetualanganHurufGame extends StatefulWidget {
  final int tahap;
  const PetualanganHurufGame({super.key, required this.tahap});

  @override
  State<PetualanganHurufGame> createState() => _PetualanganHurufGameState();
}

class _PetualanganHurufGameState extends State<PetualanganHurufGame> {
  List<String> _kartu = [];
  List<bool> _cocok = []; 
  List<int> _terbuka = []; 
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
    _kartu = [...item, ...item]..shuffle(); 
    _cocok = List.filled(_kartu.length, false);
  }

  Future<void> _ketukKartu(int i) async {
    if (_papanTerkunci || _cocok[i] || _terbuka.contains(i)) return;

    setState(() => _terbuka.add(i));
    Suara.ucap(_kartu[i]);
    if (_terbuka.length < 2) return;

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
      if (!_cocok.contains(false)) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) selesaiGame(context, menang: true, salah: _salah > _jumlahPasangan ? 1 : 0, dibantu: _dibantu);
      }
    } else {
      _salah++;
      await Future.delayed(const Duration(milliseconds: 500));
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
    final jumlahCocok = _cocok.where((c) => c).length ~/ 2;

    return LayarGame(
      judul: 'Petualangan Huruf · Tahap ${widget.tahap}',
      warna: Colors.green,
      isi: Column(
        children: [
          Text('Pasangan: $jumlahCocok / $_jumlahPasangan', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: _kartu.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, i) {
                final kelihatan = _cocok[i] || _terbuka.contains(i) || _intip;
                return GestureDetector(
                  onTap: () => _ketukKartu(i),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _cocok[i] ? Colors.green.shade300 : (kelihatan ? Colors.white : Colors.green),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade800, width: 2),
                    ),
                    child: Text(
                      kelihatan ? _kartu[i] : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kelihatan ? Colors.black : Colors.white,
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
