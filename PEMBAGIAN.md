# Pembagian Tugas & File Tubes DyLeks Mobile

Pembagian tugas kelompok yang seimbang dan profesional untuk ujian COTS UTS PPB:

| Anggota | File yang Dipegang | Tanggung Jawab & Deskripsi Fitur |
| :--- | :--- | :--- |
| **Thoriq (Lead)** | `lib/main.dart`<br>`lib/core/data_materi.dart`<br>`lib/core/penyimpanan.dart`<br>`lib/core/suara.dart`<br>`lib/core/komponen.dart`<br>`lib/screens/home_screen.dart`<br>`lib/screens/stage_map_screen.dart`<br>`lib/games/daftar_game.dart` | **Arsitektur Inti, Framework & Hub Navigasi**:<br>• Konfigurasi tema global ungu & TextScaler disleksia<br>• Local state persistence SharedPreferences (XP, streak, lencana)<br>• Text-to-Speech adaptif bahasa Indonesia & kamus fonetik<br>• Desain sistem tombol 3D taktil & safe back navigation (PopScope)<br>• Layar Beranda utama (kartu level aktif & kapsul stat)<br>• Layar Peta 5 Tahap zig-zag & sistem kenaikan level<br>• Router penghubung seluruh game (`buatGame`) |
| **Raisha** | `lib/screens/onboarding_screen.dart`<br>`lib/games/game1_latihan_bertahap.dart`<br>`lib/games/game2_petualangan_huruf.dart` | **Onboarding & Fondasi Membaca Awal**:<br>• Layar registrasi nama & pemilihan avatar 3D tanpa login<br>• Level 1: Kuis vokal dengar-pilih (A, I, U, E, O)<br>• Level 2: Kartu memori suku kata (cocokkan pasangan kartu) |
| **Annisa** | `lib/screens/settings_screen.dart`<br>`lib/games/game3_tracer_kinestik.dart`<br>`lib/games/game4_bicara_ai.dart` | **Aksesibilitas & Kognisi Kinestik/Suara**:<br>• Layar pengaturan mode gelap, skala font disleksia, & mode demo<br>• Level 3: Menjiplak huruf cermin b/d/p/q di kanvas taktil<br>• Level 4: Pengucapan digraf/diftong dengan Speech-to-Text |
| **Rafikah** | `lib/screens/placement_screen.dart`<br>`lib/games/game5_labirin_spasial.dart`<br>`lib/games/game6_letuskan_balon.dart`<br>`lib/games/game7_sight_word_shield.dart`<br>`lib/games/game8_morpheme_bridge.dart` | **Kalibrasi Penempatan & Minigame Lanjutan**:<br>• Layar tes penempatan (penentu start level 1, 3, atau 6)<br>• Level 5: Labirin spasial 7x7 dengan D-pad 3D<br>• Level 6: Susun suku kata dengan meletuskan balon 3D<br>• Level 7: Sight Word Shield (tembak meteor ejaan benar)<br>• Level 8: Jembatan morfem kata berimbuhan |

---

## Urutan Push Git (Bebas Konflik)

1. **Thoriq** push fondasi `main.dart`, `core/`, `home_screen.dart`, `stage_map_screen.dart`, `daftar_game.dart`, dokumentasi, dan test ke branch `Thoriq`, lalu merge ke `main`.
2. **Raisha** push file miliknya ke branch `Raissha`, lalu merge ke `main`.
3. **Annisa** push file miliknya ke branch `annisa`, lalu merge ke `main`.
4. **Rafikah** push file miliknya ke branch `Rafiqah`, lalu merge ke `main`.
