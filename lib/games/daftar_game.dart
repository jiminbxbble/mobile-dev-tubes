import 'package:flutter/material.dart';
import 'game1_latihan_bertahap.dart';
import 'game2_petualangan_huruf.dart';
import 'game3_tracer_kinestik.dart';
import 'game4_bicara_ai.dart';
import 'game5_labirin_spasial.dart';
import 'game6_letuskan_balon.dart';
import 'game7_sight_word_shield.dart';
import 'game8_morpheme_bridge.dart';

// ===============================================
// Menghubungkan nomor level -> layar game.
// Setiap game menerima `tahap` (1-5) dan `bantuan`,
// lalu memanggil selesaiGame(...) saat selesai.
// ===============================================

Widget buatGame(int level, int tahap, bool bantuan) { // widget ini dipanggil dari StageMapScreen untuk menampilkan layar game sesuai level/tahap
  switch (level) {
    case 1:
      return LatihanBertahapGame(tahap: tahap, bantuan: bantuan); // kode ini untuk level 1, game pertama yang bisa gagal
    case 2:
      return PetualanganHurufGame(tahap: tahap); // kode ini untuk level 2, game terakhir yang bisa gagal
    case 3:
      return TracerKinestikGame(tahap: tahap); // kode ini untuk level 3, game terakhir yang bisa gagal
    case 4:
      return BicaraAiGame(tahap: tahap); // kode ini untuk level 4, game terakhir yang bisa gagal
    case 5:
      return LabirinSpasialGame(tahap: tahap); // kode ini untuk level 5, game terakhir yang bisa gagal
    case 6:
      return LetuskanBalonGame(tahap: tahap); // kode ini untuk level 6, game terakhir yang bisa gagal
    case 7:
      return SightWordShieldGame(tahap: tahap, bantuan: bantuan); // kode ini untuk level 7, game terakhir yang bisa gagal
    default:
      return MorphemeBridgeGame(tahap: tahap); // kode ini untuk level 8, game terakhir
  }
}
