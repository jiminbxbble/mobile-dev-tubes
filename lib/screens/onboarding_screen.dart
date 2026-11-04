import 'package:flutter/material.dart';
import '../core/komponen.dart';
import '../core/penyimpanan.dart';
import 'placement_screen.dart';

// ===============================================
// ONBOARDING: isi nama + pilih avatar (tanpa login)
// ===============================================

const List<String> pilihanAvatar = ['🐱', '🐶', '🐰', '🦊', '🐼', '🐸', '🦁', '🐵'];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _namaController = TextEditingController();
  String _avatar = pilihanAvatar[0];

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
    final namaKosong = _namaController.text.trim().isEmpty;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text('Halo! 👋', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Siapa namamu?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: _namaController,
                maxLength: 20,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Nama kamu'),
                onChanged: (_) => setState(() {}), // supaya tombol aktif/nonaktif
              ),
              const SizedBox(height: 16),
              const Text('Pilih avatar', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: pilihanAvatar.map((a) {
                  final dipilih = a == _avatar;
                  return GestureDetector(
                    onTap: () => setState(() => _avatar = a),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: dipilih ? Colors.indigo : Colors.grey.shade300,
                      child: Text(a, style: const TextStyle(fontSize: 34)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              TombolBesar(teks: 'LANJUT', onTekan: namaKosong ? null : _lanjut),
            ],
          ),
        ),
      ),
    );
  }
}
