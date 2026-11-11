import 'package:flutter/material.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import '../main.dart';
import 'onboarding_screen.dart';
import 'placement_screen.dart';

// ===============================================
// PENGATURAN (GAYA DUOLINGO & KELENGKAPAN DEMO UTS)
// Tema, Ukuran Font Disleksia, Diagnostik Suara,
// dan Mode Demo Buka Semua Tingkat.
// ===============================================

class SettingsScreen extends StatefulWidget {
  final bool tampilkanAppBar;
  const SettingsScreen({super.key, this.tampilkanAppBar = true});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(isi),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return jawab ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FD),
      appBar: widget.tampilkanAppBar
          ? AppBar(
              title: const Text('Pengaturan & Aksesibilitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // KARTU PROFIL PENGGUNA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.purple.shade50, offset: const Offset(0, 3), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: bangunAvatarWidget(Data.avatar, ukuran: 48),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Data.nama,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total XP: ${Data.xp} XP · Tingkat ${Data.levelSekarang}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KARTU AKSESIBILITAS DISLEKSIA
          _judulBagian('Aksesibilitas & Tampilan'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Mengurangi kelelahan mata di ruang minim cahaya'),
                  activeTrackColor: const Color(0xFF7C3AED),
                  activeThumbColor: Colors.white,
                  value: Data.temaGelap,
                  onChanged: (v) {
                    Data.temaGelap = v;
                    _ubah();
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ukuran Teks (Skala Kognitif Disleksia)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Membantu anak disleksia membedakan bentuk huruf dengan jelas.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<double>(
                          segments: const [
                            ButtonSegment(value: 1.0, label: Text('100% (Normal)')),
                            ButtonSegment(value: 1.15, label: Text('115% (Besar)')),
                            ButtonSegment(value: 1.25, label: Text('125% (Ekstra)')),
                          ],
                          selected: {Data.ukuranTeks},
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: const Color(0xFFEDE9FE),
                            selectedForegroundColor: const Color(0xFF7C3AED),
                          ),
                          onSelectionChanged: (s) {
                            Data.ukuranTeks = s.first;
                            _ubah();
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Data.temaGelap = false;
                            Data.ukuranTeks = 1.0;
                            _ubah();
                          },
                          child: const Text('Kembalikan ke Setelan Normal', style: TextStyle(color: Color(0xFF7C3AED))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KARTU DIAGNOSTIK SUARA TTS
          _judulBagian('Diagnostik Suara & Fonetik'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Suara.indonesiaTersedia ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      color: Suara.indonesiaTersedia ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                  title: const Text('Uji Text-To-Speech (TTS)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Mesin: ${Suara.namaSuara} (${Suara.indonesiaTersedia ? "Bahasa Indonesia Aktif" : "Masih Logat Asing"})'),
                  trailing: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF06B6D4), size: 36),
                  onTap: () => Suara.ucap('Halo! Ayo belajar membaca bersama DyLeks. Bunga, nyanyi, makan.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_rounded, color: Color(0xFF7C3AED)),
                  title: const Text('Ulangi Tes Penempatan', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Mengkalibrasi ulang level awal membaca'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacementScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KARTU MODE DEMO UTS (PENTING UNTUK PENGUJIAN DOSEN)
          _judulBagian('Mode Demonstrasi Ujian UTS'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 1.5),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_open_rounded, color: Color(0xFFF59E0B)),
              ),
              title: const Text('Buka Semua Tingkat (Mode Demo Dosen)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Membuka langsung seluruh Tingkat 1–8 untuk presentasi UTS'),
              onTap: () async {
                Data.aturLevelAwal(8);
                await _ubah();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: const Color(0xFF10B981),
                    content: const Text('Mode Demo Aktif: Seluruh Tingkat 1–8 berhasil dibuka!',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // KARTU HAPUS PROGRES
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade200, width: 1.5),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444)),
              title: const Text('Hapus Semua Progres', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              subtitle: const Text('Mengosongkan XP, streak, dan kembali ke onboarding'),
              onTap: _hapusProgres,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _judulBagian(String judul) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        judul,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
