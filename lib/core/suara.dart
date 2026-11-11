import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart'; //gunanya untuk Text To Speech (TTS) bahasa Indonesia

// ===============================================
// SUARA (Text To Speech bahasa Indonesia)
// Cara pakai: Suara.ucap('ba');
//
// Supaya logatnya Indonesia (bukan Inggris), kita CARI suara (voice)
// berbahasa Indonesia di perangkat, lalu memakainya.
// Kalau perangkat tidak punya suara Indonesia, suaranya pasti logat Inggris
// -> lihat pesan di Pengaturan > "Tes Suara".
// cara pakai: Suara.siapkan() dipanggil sekali saat app dibuka, lalu Suara.ucap(teks) dipanggil kapan saja.
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
  static bool _apakahIndonesia(Map suara) { // gunnya untuk memeriksa apakah suara yang tersedia di perangkat adalah bahasa Indonesia
    final locale = '${suara['locale']}'.toLowerCase().replaceAll('_', '-'); // gunanya untuk mengubah locale dari format "id_ID" menjadi "id-ID" supaya lebih mudah dibandingkan
    final nama = '${suara['name']}'.toLowerCase(); // gunanya untuk memeriksa nama suara, misal "Google Bahasa Indonesia" atau "Microsoft Gadis"
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

  // Panggil ini untuk mengucapkan teks. Teks akan diubah ke huruf kecil dan dipangkas spasi.
  // Kalau ada kata yang perlu pelafalan khusus, tambahkan di _pelafalan
  static Future<void> ucap(String teks) async { // dipanggil dari game untuk mengucapkan teks, misal ucap('ba') atau ucap('main')
    final kata = teks.toLowerCase().trim();
    try {
      await _tts.stop();
      await _tts.speak(_pelafalan[kata] ?? kata);
    } catch (_) {}
  }
}
