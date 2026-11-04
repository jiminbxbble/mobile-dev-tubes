import 'package:flutter/material.dart';
import 'suara.dart';

// ===============================================
// KOMPONEN BERSAMA yang dipakai semua game
// ===============================================

// Hasil yang dikirim game ke Peta Tahap saat game selesai
class HasilGame {
  final bool menang;
  final int salah; // jumlah kesalahan
  final bool dibantu; // true kalau pakai mode bantuan
  const HasilGame({required this.menang, this.salah = 0, this.dibantu = false});
}

// Panggil ini dari game ketika permainan selesai.
// Contoh: selesaiGame(context, menang: true, salah: 2);
void selesaiGame(BuildContext context, {required bool menang, int salah = 0, bool dibantu = false}) {
  Navigator.pop(context, HasilGame(menang: menang, salah: salah, dibantu: dibantu));
}

// Kerangka layar game: AppBar berwarna + konfirmasi saat keluar
class LayarGame extends StatelessWidget {
  final String judul;
  final Color warna;
  final Widget isi;

  const LayarGame({super.key, required this.judul, required this.warna, required this.isi});

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final keluar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Keluar dari tahap?'),
        content: const Text('Progres tahap ini tidak disimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Lanjut main')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (keluar == true && context.mounted) Navigator.pop(context); // hasil null = keluar
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sudahPop, _) {
        if (!sudahPop) _konfirmasiKeluar(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(judul),
          backgroundColor: warna,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _konfirmasiKeluar(context),
          ),
        ),
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(16), child: isi),
        ),
      ),
    );
  }
}

// Tombol besar ramah anak
class TombolBesar extends StatelessWidget {
  final String teks;
  final VoidCallback? onTekan;
  final Color warna;

  const TombolBesar({super.key, required this.teks, required this.onTekan, this.warna = const Color(0xFF4F46E5)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: warna,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: onTekan,
        child: Text(teks),
      ),
    );
  }
}

// Tombol speaker untuk membacakan target
class TombolSuara extends StatelessWidget {
  final String teks;
  const TombolSuara({super.key, required this.teks});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      iconSize: 32,
      icon: const Icon(Icons.volume_up),
      onPressed: () => Suara.ucap(teks),
    );
  }
}

// Dialog "Mau dibantu sedikit?" -> true kalau anak pilih Ya
Future<bool> tawarkanBantuan(BuildContext context) async {
  final jawab = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      title: const Text('Mau dibantu sedikit? 🤝'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Tidak')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Ya')),
      ],
    ),
  );
  return jawab ?? false;
}

// Snackbar umpan balik benar/salah
void tampilUmpanBalik(BuildContext context, bool benar) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 700),
      backgroundColor: benar ? Colors.green : Colors.red,
      content: Text(benar ? 'Benar! 🎉' : 'Yuk coba lagi! 💪', style: const TextStyle(fontSize: 18)),
    ),
  );
}
