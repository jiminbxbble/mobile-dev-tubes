import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/komponen_animasi.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 4 - BICARA AI (GAYA DUOLINGO)
// Latihan pengucapan digraf & diftong (ng, ny, sy, ai, au, dll).
// Deteksi suara via Speech-to-Text dengan fallback manual.
// Menang: 5 pengucapan benar.
// Bantuan: setelah 3x salah di kata yang sama -> boleh lewati kata.
// Warna: Coral Rose (#F43F5E).
// ===============================================

const Map<String, String> contohKata = {
  'ng': 'bunga',
  'ny': 'nyanyi',
  'sy': 'syukur',
  'kh': 'khusus',
  'ai': 'pantai',
  'au': 'pulau',
  'oi': 'koboi',
  'ua': 'buah',
};

class BicaraAiGame extends StatefulWidget {
  final int tahap;
  const BicaraAiGame({super.key, required this.tahap});

  @override
  State<BicaraAiGame> createState() => _BicaraAiGameState();
}

class _BicaraAiGameState extends State<BicaraAiGame> {
  final SpeechToText _mic = SpeechToText();
  final TextEditingController _ketikController = TextEditingController();

  bool _micSiap = false;
  bool _sedangDengar = false;
  int _indeks = 0;
  int _benar = 0;
  int _salah = 0;
  int _salahKataIni = 0;
  bool _bolehLewati = false;
  bool _dibantu = false;
  String _terdengar = '';
  String? _hasil;

  String get _target => poolDigraf[_indeks % poolDigraf.length];

  @override
  void initState() {
    super.initState();
    _siapkanMic();
    _bacakanTarget();
  }

  @override
  void dispose() {
    _mic.stop();
    _ketikController.dispose();
    super.dispose();
  }

  Future<void> _siapkanMic() async {
    try {
      final siap = await _mic.initialize();
      if (mounted) setState(() => _micSiap = siap);
    } catch (_) {
      // Fallback ke mode ketik manual
    }
  }

  void _bacakanTarget() {
    Future.delayed(const Duration(milliseconds: 500), () => Suara.ucap(contohKata[_target] ?? _target));
  }

  void _mulaiDengar() {
    setState(() {
      _sedangDengar = true;
      _terdengar = '';
    });
    _mic.listen(
      listenOptions: SpeechListenOptions(localeId: 'id_ID'),
      onResult: (SpeechRecognitionResult r) {
        setState(() => _terdengar = r.recognizedWords);
        if (r.finalResult) {
          setState(() => _sedangDengar = false);
          _nilai(r.recognizedWords);
        }
      },
    );
  }

  Future<void> _nilai(String ucapan) async {
    final u = ucapan.toLowerCase().trim();
    final benar = u == _target || u.contains(_target);
    setState(() {
      _terdengar = ucapan;
      _hasil = benar ? 'benar' : 'salah';
    });
    tampilUmpanBalik(context, benar);

    if (benar) {
      _benar++;
      if (_benar >= 5) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        selesaiGame(
          context,
          menang: true,
          salah: _salah,
          dibantu: _dibantu,
          ringkasan: 'Pelafalan 5 Kata Digraf/Diftong Hebat!',
        );
      }
    } else {
      _salah++;
      _salahKataIni++;
      if (_salahKataIni >= 3 && !_bolehLewati) {
        final mau = await tawarkanBantuan(context);
        if (mau) {
          _dibantu = true;
          setState(() => _bolehLewati = true);
        }
      }
    }
  }

  void _kataBerikutnya() {
    setState(() {
      _indeks++;
      _hasil = null;
      _terdengar = '';
      _salahKataIni = 0;
      _bolehLewati = false;
      _ketikController.clear();
    });
    _bacakanTarget();
  }

  @override
  Widget build(BuildContext context) {
    const Color warnaUtama = Color(0xFFF43F5E);
    final double progres = (_benar / 5).clamp(0.0, 1.0);

    return LayarGame(
      judul: 'Bicara AI · Tahap ${widget.tahap}',
      warna: warnaUtama,
      progres: progres,
      isi: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indikator Kemajuan
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
                  const Text('Kemajuan Pengucapan:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('$_benar / 5 🎤', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warnaUtama)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu Bunyi Target
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: warnaUtama.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: warnaUtama.withValues(alpha: 0.15), offset: const Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _target,
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: warnaUtama),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contoh kata: "${contohKata[_target]}"',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
                  ),
                  const SizedBox(height: 12),
                  TombolSuara(teks: contohKata[_target] ?? _target, ukuran: 50),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Mikrofon 3D Besar
            if (_micSiap)
              Center(
                child: AnimasiDenyut(
                  skalaMaks: _sedangDengar ? 1.15 : 1.0,
                  durasi: const Duration(milliseconds: 700),
                  child: GestureDetector(
                    onTap: _sedangDengar || _hasil == 'benar' ? null : _mulaiDengar,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _sedangDengar ? const Color(0xFFEF4444) : warnaUtama,
                        boxShadow: [
                          BoxShadow(
                            color: _sedangDengar ? const Color(0xFFDC2626) : hitungWarnaBayangan(warnaUtama),
                            offset: const Offset(0, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _sedangDengar ? Icons.hearing_rounded : Icons.mic_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
                child: const Text('Mikrofon tidak terdeteksi di perangkat ini. Gunakan kolom ketik di bawah ya! ⌨️',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.deepOrange)),
              ),

            const SizedBox(height: 12),
            if (_terdengar.isNotEmpty)
              Text(
                'Suara terdengar: "$_terdengar"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B2E)),
              ),
            const SizedBox(height: 16),

            // Umpan balik & Tombol Lanjut
            if (_hasil == 'benar') ...[
              TombolBesar(teks: 'KATA BERIKUTNYA ➔', warna: const Color(0xFF10B981), onTekan: _kataBerikutnya),
            ],
            if (_bolehLewati)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: _kataBerikutnya,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Lewati Kata Ini (Mode Bantuan)'),
                ),
              ),

            // Fallback manual input
            const Divider(height: 36),
            const Text(
              'Opsi Ketik Manual (Jika Suara Kurang Jelas):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ketikController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Ketik huruf / kata...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: warnaUtama,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: _hasil == 'benar' ? null : () => _nilai(_ketikController.text),
                  child: const Text('Cek', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
