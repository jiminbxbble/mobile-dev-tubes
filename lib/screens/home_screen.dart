import 'package:flutter/material.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import 'settings_screen.dart';
import 'stage_map_screen.dart';

// ===============================================
// BERANDA: profil, streak, XP, lencana, daftar 8 game
// ===============================================

// Nama lencana (id -> nama)
const Map<String, String> namaLencana = {
  'level1': 'Master Vokal',
  'level2': 'Ahli Memori',
  'level3': 'Penjiplak Handal',
  'level4': 'Pahlawan Bicara',
  'level5': 'Penjelajah Labirin',
  'level6': 'Pemecah Gelembung',
  'level7': 'Benteng Ejaan',
  'level8': 'Arsitek Morfem',
  'streak': 'Setia Belajar',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Beri tahu kalau suara bahasa Indonesia belum terpasang di HP
    if (!Suara.indonesiaTersedia) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 8),
            content: Text('Suara bahasa Indonesia belum ada di perangkat ini, jadi logatnya masih Inggris. '
                'Cara memasang ada di README bagian "Suara Indonesia".'),
          ),
        );
      });
    }
  }

  Future<void> _bukaLevel(int level) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => StageMapScreen(level: level)));
    setState(() {}); // refresh XP/streak setelah kembali
  }

  void _ketukGame(InfoLevel info) {
    if (info.nomor > Data.levelSekarang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selesaikan Tingkat ${info.nomor - 1} dulu ya! 🔒')),
      );
      return;
    }
    _bukaLevel(info.nomor);
  }

  void _lihatStreak() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF131F24),
        title: const Text('🔥 Streak', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${Data.streak} hari',
                style: const TextStyle(fontSize: 40, color: Color(0xFFFF9600), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Rekor terpanjang: ${Data.rekorStreak} hari', style: const TextStyle(color: Colors.white70)),
            if (Data.streak == 0 && Data.rekorStreak > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Apinya padam, yuk nyalakan lagi!', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))],
      ),
    );
  }

  void _lihatLencana() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('🏅 Lencana'),
        content: SizedBox(
          width: 300,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            children: namaLencana.entries.map((e) {
              final terbuka = Data.lencana.contains(e.key);
              return Column(
                children: [
                  Text(terbuka ? '🏅' : '🔒', style: const TextStyle(fontSize: 32)),
                  Text(e.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: terbuka ? null : Colors.grey)),
                ],
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelAktif = daftarLevel[Data.levelSekarang - 1];
    final tahapSelesai = Data.tahapSelesai[Data.levelSekarang - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('${Data.avatar}  Halo, ${Data.nama}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Baris info: streak, XP, lencana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: _lihatStreak, child: Text('🔥 ${Data.streak}', style: const TextStyle(fontSize: 20))),
              Text('⭐ ${Data.xp} XP', style: const TextStyle(fontSize: 20)),
              TextButton(
                  onPressed: _lihatLencana,
                  child: Text('🏅 ${Data.lencana.length}', style: const TextStyle(fontSize: 20))),
            ],
          ),
          const SizedBox(height: 12),

          // Kartu level aktif
          Card(
            color: Color(levelAktif.warna),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tingkat ${levelAktif.nomor} · ${levelAktif.namaLevel}',
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                  Text('${levelAktif.ikon} ${levelAktif.namaGame}',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: tahapSelesai / 5,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                    minHeight: 10,
                  ),
                  Text('$tahapSelesai / 5 tahap', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  TombolBesar(
                    teks: 'LANJUT LATIHAN!',
                    warna: Colors.black26,
                    onTekan: () => _bukaLevel(levelAktif.nomor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Peta Belajar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Daftar 8 game
          ...daftarLevel.map((info) {
            final terkunci = info.nomor > Data.levelSekarang;
            final selesai = Data.tahapSelesai[info.nomor - 1];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: terkunci ? Colors.grey : Color(info.warna),
                  child: Text(terkunci ? '🔒' : info.ikon),
                ),
                title: Text(info.namaGame,
                    style: TextStyle(color: terkunci ? Colors.grey : null, fontWeight: FontWeight.bold)),
                subtitle: Text(terkunci ? 'Terbuka di Tingkat ${info.nomor}!' : 'Tingkat ${info.nomor} · $selesai/5 tahap'),
                trailing: selesai == 5 ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () => _ketukGame(info),
              ),
            );
          }),
        ],
      ),
    );
  }
}
