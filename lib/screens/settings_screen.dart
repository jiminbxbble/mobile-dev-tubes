import 'package:flutter/material.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/penyimpanan.dart';
import '../core/suara.dart';
import '../main.dart';
import 'onboarding_screen.dart';
import 'placement_screen.dart';

// ===============================================
// PENGATURAN & PROFIL GAMIFIKASI (GAYA DUOLINGO AAA)
// Showcase Profil, Ganti Maskot/Nama, Tema & Skala Font,
// Diagnostik Suara Fonetik, & Mode Demo Ujian UTS.
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

  void _dialogUbahProfil() {
    final namaCtrl = TextEditingController(text: Data.nama);
    String avatarDipilih = Data.avatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(c).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: Color(0xFF7C3AED), size: 24),
                  SizedBox(width: 8),
                  Text('Ubah Profil Belajar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E))),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Nama Panggilan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: namaCtrl,
                maxLength: 20,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFFAF8FD),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Pilih Sahabat Belajarmu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: daftarMaskot.map((m) {
                  final bool terpilih = m.id == avatarDipilih;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setModalState(() => avatarDipilih = m.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          decoration: BoxDecoration(
                            color: terpilih ? m.warna.withValues(alpha: 0.12) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: terpilih ? m.warna : Colors.grey.shade300, width: terpilih ? 2.5 : 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: terpilih ? hitungWarnaBayangan(m.warna).withValues(alpha: 0.3) : Colors.grey.shade200,
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: terpilih ? m.warna : Colors.grey.shade300, width: 2),
                                ),
                                child: ClipOval(child: Image.asset(m.pathGambar, fit: BoxFit.cover)),
                              ),
                              const SizedBox(height: 6),
                              Text(m.nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: terpilih ? m.warna : const Color(0xFF1E1B2E))),
                              const SizedBox(height: 2),
                              Text(m.sifat, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Tombol3D(
                teks: 'SIMPAN PERUBAHAN',
                ikon: Icons.check_circle_rounded,
                warna: const Color(0xFF10B981),
                onTekan: () async {
                  final namaBaru = namaCtrl.text.trim();
                  if (namaBaru.isNotEmpty) {
                    Data.nama = namaBaru;
                  }
                  Data.avatar = avatarDipilih;
                  await _ubah();
                  if (!c.mounted) return;
                  Navigator.pop(c);
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _kartuSkalaFont({required double nilai, required String simbol, required String label, required String deskripsi}) {
    final bool aktif = (Data.ukuranTeks - nilai).abs() < 0.05;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          Data.ukuranTeks = nilai;
          _ubah();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: aktif ? const Color(0xFFEDE9FE) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: aktif ? const Color(0xFF7C3AED) : Colors.grey.shade300,
              width: aktif ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: aktif ? const Color(0xFFDDD6FE) : Colors.grey.shade200,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                simbol,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: aktif ? const Color(0xFF7C3AED) : const Color(0xFF1E1B2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: aktif ? const Color(0xFF7C3AED) : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                deskripsi,
                style: TextStyle(
                  fontSize: 10,
                  color: aktif ? const Color(0xFF5B21B6) : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          // 1. KARTU PROFIL PENGGUNA DUOLINGO 3D
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFFDDD6FE), offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar Maskot dalam Bingkai 3D
                    AnimasiMelayang(
                      amplitudo: 4,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF7C3AED), width: 3),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFFDDD6FE), offset: Offset(0, 3), blurRadius: 0),
                          ],
                        ),
                        child: ClipOval(
                          child: bangunAvatarWidget(Data.avatar, ukuran: 66),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Data.nama.isNotEmpty ? Data.nama : 'Pahlawan Membaca',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E1B2E)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFF7C3AED)),
                                const SizedBox(width: 4),
                                Text(
                                  'Tingkat ${Data.levelSekarang} · Fondasi Membaca',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _dialogUbahProfil,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEDE9FE),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF7C3AED), size: 20),
                      tooltip: 'Ubah Profil',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ringkasan Statistik Gamifikasi
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // XP
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${Data.xp}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1B2E))),
                              Text('Total XP', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      // Streak
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEA580C), size: 22),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${Data.streak}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1B2E))),
                              Text('Hari Streak', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      // Lencana
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: Color(0xFF7C3AED), size: 22),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${Data.lencana.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1B2E))),
                              Text('Lencana', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 2. KARTU AKSESIBILITAS DISLEKSIA 3D
          _judulBagian('Aksesibilitas & Tampilan Disleksia', Icons.visibility_rounded),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle Mode Gelap
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Data.temaGelap ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: const Color(0xFF7C3AED),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mode Gelap (Anti-Silau)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Mengurangi ketegangan visual pada mata anak disleksia', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Switch(
                      value: Data.temaGelap,
                      activeTrackColor: const Color(0xFF7C3AED),
                      activeThumbColor: Colors.white,
                      onChanged: (v) {
                        Data.temaGelap = v;
                        _ubah();
                      },
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Skala Font Disleksia
                const Text(
                  'Ukuran Teks Ramah Disleksia',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Skala huruf proporsional untuk mempermudah diskriminasi bentuk huruf:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _kartuSkalaFont(nilai: 1.0, simbol: 'A', label: '100%', deskripsi: 'Standar'),
                    const SizedBox(width: 8),
                    _kartuSkalaFont(nilai: 1.15, simbol: 'A+', label: '115%', deskripsi: 'Besar'),
                    const SizedBox(width: 8),
                    _kartuSkalaFont(nilai: 1.25, simbol: 'A++', label: '125%', deskripsi: 'Ekstra'),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Data.temaGelap = false;
                      Data.ukuranTeks = 1.0;
                      _ubah();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF7C3AED)),
                    label: const Text('Kembalikan ke Ukuran Standar', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 3. KARTU DIAGNOSTIK SUARA TTS 3D
          _judulBagian('Diagnostik Suara & Pelafalan Fonem', Icons.record_voice_over_rounded),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFFCFFAFE), offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.record_voice_over_rounded, color: Color(0xFF0891B2), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Uji Text-To-Speech (TTS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Mesin: ${Suara.namaSuara}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Suara.indonesiaTersedia ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Suara.indonesiaTersedia ? Icons.check_circle_rounded : Icons.info_rounded,
                            size: 14,
                            color: Suara.indonesiaTersedia ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Suara.indonesiaTersedia ? 'Aktif' : 'Logat Asing',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Suara.indonesiaTersedia ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Gelembung Kalimat Contoh TTS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFEFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: const Text(
                    '"Halo! Ayo belajar membaca bersama DyLeks. Bunga, nyanyi, makan."',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF0E7490), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Uji Suara 3D
                Tombol3D(
                  teks: 'PUTAR CONTOH SUARA TTS',
                  ikon: Icons.volume_up_rounded,
                  warna: const Color(0xFF06B6D4),
                  onTekan: () => Suara.ucap('Halo! Ayo belajar membaca bersama DyLeks. Bunga, nyanyi, makan.'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),

                // Ulangi Tes Penempatan
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFF7C3AED), size: 22),
                  ),
                  title: const Text('Ulangi Tes Penempatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Mengkalibrasi ulang level awal membaca', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacementScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 4. KARTU MODE DEMO UTS (EMAS JUARA 3D)
          _judulBagian('Mode Demonstrasi Ujian UTS', Icons.military_tech_rounded),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buka Semua Tingkat 1–8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E))),
                          Text('Fitur khusus demonstrasi penilaian Dosen Penguji UTS', style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Tombol3D(
                  teks: 'BUKA SEMUA TINGKAT SEKARANG',
                  ikon: Icons.rocket_launch_rounded,
                  warna: const Color(0xFFF59E0B),
                  onTekan: () async {
                    Data.aturLevelAwal(8);
                    await _ubah();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: const Color(0xFF10B981),
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Mode Demo Aktif: Seluruh Tingkat 1–8 Terbuka!', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 5. KARTU HAPUS PROGRES (ZONA AMAN)
          _judulBagian('Manajemen Data Belajar', Icons.manage_accounts_rounded),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.red.shade100, offset: const Offset(0, 3), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hapus Semua Progres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEF4444))),
                      Text('Kembalikan aplikasi ke awal seperti baru diunduh', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _hapusProgres,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Reset', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _judulBagian(String judul, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(ikon, size: 18, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 6),
          Text(
            judul,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1B2E),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
