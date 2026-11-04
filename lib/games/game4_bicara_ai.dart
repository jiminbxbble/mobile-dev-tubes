import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../core/data_materi.dart';
import '../core/komponen.dart';
import '../core/suara.dart';

// ===============================================
// LEVEL 4 - BICARA AI (latihan pengucapan)
// Anak mengucapkan target lewat mic. Kalau mic tidak bisa,
// anak bisa mengetik manual. Menang: 5 pengucapan benar.
// Bantuan: salah 3x di kata yang sama -> boleh "Lewati kata".
// ===============================================

// Contoh kata supaya bunyi digraf lebih mudah dikenali
const Map<String, String> contohKata = {
  'ng': 'bunga', 'ny': 'nyanyi', 'sy': 'syukur', 'kh': 'khusus',
  'ai': 'pantai', 'au': 'pulau', 'oi': 'koboi', 'ua': 'buah',
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
  int _indeks = 0; // item ke berapa dari pool
  int _benar = 0;
  int _salah = 0;
  int _salahKataIni = 0;
  bool _bolehLewati = false;
  bool _dibantu = false;
  String _terdengar = '';
  String? _hasil; // 'benar' / 'salah' / null

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
      // Mic tidak tersedia -> pakai mode ketik manual
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

  // Benar jika ucapan sama dengan target atau mengandung target
  Future<void> _nilai(String ucapan) async {
    final u = ucapan.toLowerCase().trim();
    final benar = u == _target || u.contains(_target);
    setState(() {
      _terdengar = ucapan;
      _hasil = benar ? 'benar' : 'salah';
    });

    if (benar) {
      _benar++;
      if (_benar >= 5) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) selesaiGame(context, menang: true, salah: _salah, dibantu: _dibantu);
      }
    } else {
      _salah++;
      _salahKataIni++;
      if (_salahKataIni == 3 && !_bolehLewati) {
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
    return LayarGame(
      judul: 'Bicara AI · Tahap ${widget.tahap}',
      warna: Colors.pink,
      isi: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Benar: $_benar / 5', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text(_target, textAlign: TextAlign.center, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold)),
            Text('contoh: ${contohKata[_target]}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
            Center(child: TombolSuara(teks: contohKata[_target] ?? _target)),
            const SizedBox(height: 16),

            // Tombol mic
            if (_micSiap)
              Center(
                child: FloatingActionButton.large(
                  backgroundColor: _sedangDengar ? Colors.red : Colors.pink,
                  onPressed: _sedangDengar || _hasil == 'benar' ? null : _mulaiDengar,
                  child: Icon(_sedangDengar ? Icons.hearing : Icons.mic, size: 48, color: Colors.white),
                ),
              )
            else
              const Text('Mic tidak tersedia, ketik jawabanmu ya.', textAlign: TextAlign.center),
            if (_terdengar.isNotEmpty)
              Text('Terdengar: "$_terdengar"', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // Hasil
            if (_hasil == 'benar') ...[
              const Text('Hebat! Pengucapan Benar 🎉',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Colors.green)),
              const SizedBox(height: 8),
              if (_benar < 5) TombolBesar(teks: 'KATA SELANJUTNYA', warna: Colors.green, onTekan: _kataBerikutnya),
            ],
            if (_hasil == 'salah')
              const Text('Ayo Coba Lagi! 💪', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Colors.red)),
            if (_bolehLewati)
              TextButton(onPressed: _kataBerikutnya, child: const Text('Lewati kata')),

            // Mode ketik manual
            const Divider(height: 32),
            const Text('Mic bermasalah? Ketik manual:'),
            Row(
              children: [
                Expanded(child: TextField(controller: _ketikController)),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _hasil == 'benar' ? null : () => _nilai(_ketikController.text),
                  child: const Text('Periksa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
