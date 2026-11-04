import 'package:flutter/material.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import '../main.dart';
import 'onboarding_screen.dart';
import 'placement_screen.dart';

// ===============================================
// PENGATURAN: tema, ukuran teks, ulang tes, hapus progres
// ===============================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _ubah() async {
    await Data.simpan();
    perbaruiTampilan.value++; // gambar ulang seluruh app
    setState(() {});
  }

  // Konfirmasi 2 langkah sebelum menghapus
  Future<void> _hapusProgres() async {
    final yakin1 = await _tanya('Hapus semua progres?', 'XP, level, dan lencana akan hilang.');
    if (!yakin1) return;
    final yakin2 = await _tanya('Benar-benar yakin?', 'Ini tidak bisa dibatalkan.');
    if (!yakin2) return;

    await Data.hapusSemua();
    perbaruiTampilan.value++;
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  Future<bool> _tanya(String judul, String isi) async {
    final jawab = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus')),
        ],
      ),
    );
    return jawab ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(title: Text('Profil: ${Data.avatar} ${Data.nama}'), subtitle: Text('Total XP: ${Data.xp}')),
          SwitchListTile(
            title: const Text('Mode gelap'),
            value: Data.temaGelap,
            onChanged: (v) {
              Data.temaGelap = v;
              _ubah();
            },
          ),
          const ListTile(title: Text('Ukuran teks')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1.0, label: Text('100%')),
                ButtonSegment(value: 1.15, label: Text('115%')),
                ButtonSegment(value: 1.25, label: Text('125%')),
              ],
              selected: {Data.ukuranTeks},
              onSelectionChanged: (s) {
                Data.ukuranTeks = s.first;
                _ubah();
              },
            ),
          ),
          TextButton(
            onPressed: () {
              Data.temaGelap = false;
              Data.ukuranTeks = 1.0;
              _ubah();
            },
            child: const Text('Reset ke Standar'),
          ),
          const Divider(),
          // Untuk mengecek apakah suara sudah logat Indonesia
          ListTile(
            leading: Icon(Icons.record_voice_over, color: Suara.indonesiaTersedia ? Colors.green : Colors.red),
            title: const Text('Tes Suara'),
            subtitle: Text('Suara: ${Suara.namaSuara}'),
            onTap: () => Suara.ucap('Halo! Ayo belajar membaca bersama. Bunga, nyanyi, makan.'),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Ulangi Tes Penempatan'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacementScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.lock_open, color: Colors.indigo),
            title: const Text('Buka Semua Tingkat (Mode Demo)'),
            subtitle: const Text('Membuka Tingkat 1–8 untuk demonstrasi'),
            onTap: () async {
              Data.aturLevelAwal(8);
              await _ubah();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua tingkat (1-8) berhasil dibuka!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Hapus Progres', style: TextStyle(color: Colors.red)),
            onTap: _hapusProgres,
          ),
        ],
      ),
    );
  }
}
