import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ===============================================
// SUARA (Text To Speech bahasa Indonesia)
// Cara pakai: Suara.ucap('ba');
//
// Supaya logatnya Indonesia (bukan Inggris), kita CARI suara (voice)
// berbahasa Indonesia di perangkat, lalu memakainya.
// Kalau perangkat tidak punya suara Indonesia, suaranya pasti logat Inggris
// -> lihat pesan di Pengaturan > "Tes Suara".
// ===============================================

class Suara {
  static final FlutterTts _tts = FlutterTts();

  static bool indonesiaTersedia = false;
  static String namaSuara = '(belum dicek)'; // ditampilkan di Pengaturan

  // Cara baca huruf/digraf supaya bunyinya benar dalam bahasa Indonesia
  static const Map<String, String> _pelafalan = {
    'b': 'be', 'd': 'de', 'p': 'pe', 'q': 'ki',
    'ng': 'eng', 'ny': 'nya', 'sy': 'sya', 'kh': 'kha',
  };

  // true kalau locale/nama suara menunjukkan bahasa Indonesia
  static bool _apakahIndonesia(Map suara) {
    final locale = '${suara['locale']}'.toLowerCase().replaceAll('_', '-');
    final nama = '${suara['name']}'.toLowerCase();
    return locale.startsWith('id') || // id-ID (standar baru)
        locale.startsWith('in-') || // in-ID (kode lama Android)
        nama.contains('indonesia') || // "Google Bahasa Indonesia", "Microsoft Gadis"
        nama.contains('gadis') ||
        nama.contains('andika') ||
        nama.startsWith('id-id');
  }

  static Future<void> siapkan() async {
    // 1. Android: pakai mesin Google TTS kalau ada
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final mesin = await _tts.getEngines;
        if (mesin is List && mesin.contains('com.google.android.tts')) {
          await _tts.setEngine('com.google.android.tts');
        }
      } catch (_) {}
    }

    // 2. Cari suara Indonesia dari daftar suara di perangkat
    try {
      final daftar = await _tts.getVoices;
      if (daftar is List) {
        final indo = daftar.whereType<Map>().where(_apakahIndonesia).toList();
        if (indo.isNotEmpty) {
          final v = indo.first;
          await _tts.setLanguage('${v['locale']}');
          await _tts.setVoice({'name': '${v['name']}', 'locale': '${v['locale']}'});
          indonesiaTersedia = true;
          namaSuara = '${v['name']} (${v['locale']})';
        }
      }
    } catch (_) {}

    // 3. Kalau tidak ketemu voice-nya, coba set bahasa saja
    if (!indonesiaTersedia) {
      for (final kode in ['id-ID', 'in-ID', 'id']) {
        try {
          final hasil = await _tts.setLanguage(kode);
          if (hasil == 1 || hasil == true) {
            final ada = await _tts.isLanguageAvailable(kode);
            if (ada == true) {
              indonesiaTersedia = true;
              namaSuara = 'bahasa $kode';
              break;
            }
          }
        } catch (_) {}
      }
    }
    if (!indonesiaTersedia) namaSuara = 'TIDAK ADA suara Indonesia di perangkat ini';
    debugPrint('[Suara] $namaSuara');

    try {
      await _tts.setSpeechRate(kIsWeb ? 0.8 : 0.4); // pelan supaya jelas untuk anak
      await _tts.setPitch(1.1);
    } catch (_) {}
  }

  static Future<void> ucap(String teks) async {
    final kata = teks.toLowerCase().trim();
    try {
      await _tts.stop();
      await _tts.speak(_pelafalan[kata] ?? kata);
    } catch (_) {}
  }
}
