import 'package:flutter/material.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/penyimpanan.dart';
import 'placement_screen.dart';

// ===============================================
// 3 MASKOT RESMI NANO BANANA (DYLEKS MOBILE)
// ===============================================
class DataMaskot {
  final String id;
  final String nama;
  final String sifat;
  final String pathGambar;
  final Color warna;

  const DataMaskot({
    required this.id,
    required this.nama,
    required this.sifat,
    required this.pathGambar,
    required this.warna,
  });
}

const List<DataMaskot> daftarMaskot = [
  DataMaskot(
    id: 'leko',
    nama: 'Leko',
    sifat: 'Cerdas (Fonem)',
    pathGambar: 'assets/images/avatar_leko.jpg',
    warna: Color(0xFF7C3AED),
  ),
  DataMaskot(
    id: 'milo',
    nama: 'Milo',
    sifat: 'Ceria (Tantangan)',
    pathGambar: 'assets/images/avatar_milo.jpg',
    warna: Color(0xFFF59E0B),
  ),
  DataMaskot(
    id: 'kiko',
    nama: 'Kiko',
    sifat: 'Sabar (Latihan)',
    pathGambar: 'assets/images/avatar_kiko.jpg',
    warna: Color(0xFF10B981),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _namaController = TextEditingController();
  String _avatar = daftarMaskot[0].id;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _lanjut() async {
    Data.nama = _namaController.text.trim();
    Data.avatar = _avatar;
    await Data.simpan();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PlacementScreen(dariOnboarding: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool namaKosong = _namaController.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header Maskot / Logo Animasi Nano Banana
              Center(
                child: AnimasiMelayang(
                  amplitudo: 6,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7C3AED), width: 3),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFDDD6FE), offset: Offset(0, 4), blurRadius: 0),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/leko_reading.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang di DyLeks!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Belajar membaca jadi seru dan mudah!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 28),

              // Kartu Pengisian Nama
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade100.withValues(alpha: 0.5),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Siapa namamu?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _namaController,
                      maxLength: 20,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFAF8FD),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.purple.shade200, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                        ),
                        hintText: 'Ketik nama kamu di sini...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pilih Karakter Maskot 3D Nano Banana
              const Text(
                'Pilih Sahabat Belajarmu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih teman yang akan menyemangatimu membaca!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              Row(
                children: daftarMaskot.map((m) {
                  final bool dipilih = m.id == _avatar;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () => setState(() => _avatar = m.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: dipilih ? m.warna.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dipilih ? m.warna : const Color(0xFFE5E7EB),
                              width: dipilih ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: dipilih ? hitungWarnaBayangan(m.warna).withValues(alpha: 0.4) : Colors.grey.shade200,
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: dipilih ? m.warna : Colors.grey.shade300,
                                    width: dipilih ? 2.5 : 1.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(m.pathGambar, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: dipilih ? m.warna : const Color(0xFF1E1B2E),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: m.warna.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  m.sifat,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: m.warna,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Tombol Mulai Petualangan
              TombolBesar(
                teks: 'MULAI PETUALANGAN!',
                warna: const Color(0xFF7C3AED),
                onTekan: namaKosong ? null : _lanjut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
