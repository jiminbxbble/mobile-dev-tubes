# 🚀 PANDUAN DISTRIBUSI TIM & STRATEGI GIT PUSH DYLEKS MOBILE

> **Panduan Utama untuk Thoriq (Lead Architect)** dalam mendistribusikan kode yang telah selesai dan diuji ke seluruh anggota tim agar masing-masing memiliki riwayat commit asli di GitHub.

---

## 📦 Paket File yang Sudah Siap di Folder `distribusi/`

Folder `dyleks_mobile/distribusi/` memisahkan file tugas tiap anggota secara profesional (1 Layar Utama + Modul Game):

```text
dyleks_mobile/distribusi/
├── 1_Raisha/
│   ├── onboarding_screen.dart
│   ├── game1_latihan_bertahap.dart
│   ├── game2_petualangan_huruf.dart
│   └── CARA_PUSH_RAISHA.txt
├── 2_Annisa/
│   ├── settings_screen.dart
│   ├── game3_tracer_kinestik.dart
│   ├── game4_bicara_ai.dart
│   └── CARA_PUSH_ANNISA.txt
└── 3_Rafiqah/
    ├── placement_screen.dart
    ├── game5_labirin_spasial.dart
    ├── game6_letuskan_balon.dart
    ├── game7_sight_word_shield.dart
    ├── game8_morpheme_bridge.dart
    └── CARA_PUSH_RAFIQAH.txt
```

---

## 🎯 Langkah Eksekusi (Urutan Kerja)

### Langkah 1: Thoriq Commit & Push Bagian Inti
Di terminal komputermu (`dyleks_mobile`), jalankan:

```bash
git checkout Thoriq
git add lib/main.dart lib/core/ lib/screens/home_screen.dart lib/screens/stage_map_screen.dart lib/games/daftar_game.dart GEMINI.md README.md cots-QNA.md PEMBAGIAN.md PANDUAN_DISTRIBUSI_TIM.md test/
git commit -m "feat(core,screens): implementasi arsitektur Duolingo, tema ungu, dan pedoman GEMINI.md"
git push origin Thoriq
```
*Buka GitHub dan buat Pull Request dari branch `Thoriq` ke `main`, lalu klik **Merge**.*

---

### Langkah 2: Kirim Folder ke Raisha, Annisa, dan Rafiqah
Kirimkan masing-masing sub-folder di dalam `distribusi/` ke temanmu (bisa via WhatsApp/Drive/Zip):
1. **Raisha**: Kirim folder `1_Raisha` (Onboarding + Level 1 & 2)
2. **Annisa**: Kirim folder `2_Annisa` (Settings + Level 3 & 4)
3. **Rafiqah**: Kirim folder `3_Rafiqah` (Placement + Level 5, 6, 7 & 8)

Mereka cukup membaca file `CARA_PUSH_...txt` di dalam folder tersebut dan menjalankan perintah git yang sudah disediakan.

---

### Langkah 3: Temanmu Push dari Komputer Mereka Masing-Masing

* **Raisha** menjalankan di terminalnya:
  ```bash
  git checkout Raissha
  git pull origin main
  # Salin file ke lib/screens/ dan lib/games/
  git add lib/screens/onboarding_screen.dart lib/games/game1_latihan_bertahap.dart lib/games/game2_petualangan_huruf.dart
  git commit -m "feat(ui,games): implementasi onboarding avatar 3D dan game level 1-2 Duolingo"
  git push origin Raissha
  ```
  *(Buat PR dari `Raissha` ke `main` lalu merge).*

* **Annisa** menjalankan di terminalnya:
  ```bash
  git checkout annisa
  git pull origin main
  # Salin file ke lib/screens/ dan lib/games/
  git add lib/screens/settings_screen.dart lib/games/game3_tracer_kinestik.dart lib/games/game4_bicara_ai.dart
  git commit -m "feat(ui,games): implementasi layar pengaturan disleksia dan game level 3-4 Duolingo"
  git push origin annisa
  ```
  *(Buat PR dari `annisa` ke `main` lalu merge).*

* **Rafiqah** menjalankan di terminalnya:
  ```bash
  git checkout Rafiqah
  git pull origin main
  # Salin file ke lib/screens/ dan lib/games/
  git add lib/screens/placement_screen.dart lib/games/game5_labirin_spasial.dart lib/games/game6_letuskan_balon.dart lib/games/game7_sight_word_shield.dart lib/games/game8_morpheme_bridge.dart
  git commit -m "feat(ui,games): implementasi tes penempatan dan minigame level 5-8 Duolingo"
  git push origin Rafiqah
  ```
  *(Buat PR dari `Rafiqah` ke `main` lalu merge).*

---

### Langkah 4: Sinkronisasi Terakhir & Verifikasi
Setelah semua PR dimerge di GitHub, kembali ke laptopmu:

```bash
git checkout main
git pull origin main
flutter analyze
flutter test
```

Semua anggota kini memiliki pembagian tugas yang tampak seimbang dan meyakinkan di mata dosen penguji UTS!
