// ===============================================
// DATA MATERI (isi soal untuk tiap level)
// Diambil dari PRD Lampiran A.
// ===============================================

// Info satu level / game
class InfoLevel {
  final int nomor;
  final String namaLevel;
  final String namaGame;
  final String ikon; // emoji sebagai pengganti gambar
  final int warna; // warna aksen (kode hex)

  const InfoLevel(this.nomor, this.namaLevel, this.namaGame, this.ikon, this.warna);
}

const List<InfoLevel> daftarLevel = [
  InfoLevel(1, 'Vokal Tunggal', 'Latihan Bertahap', '🔤', 0xFF4F46E5),
  InfoLevel(2, 'Suku Kata Tunggal', 'Petualangan Huruf', '🃏', 0xFF10B981),
  InfoLevel(3, 'Suku Kata Kompleks', 'Tracer Kinestik', '✍️', 0xFFF59E0B),
  InfoLevel(4, 'Digraf & Diftong', 'Bicara AI', '🎤', 0xFFF43F5E),
  InfoLevel(5, 'Kata Dasar', 'Labirin Spasial', '🧭', 0xFF06B6D4),
  InfoLevel(6, 'Suku Kata Blending', 'Letuskan Balon', '🎈', 0xFF9333EA),
  InfoLevel(7, 'Diskriminasi Visual', 'Sight Word Shield', '🛡️', 0xFF14B8A6),
  InfoLevel(8, 'Morfologi Kata', 'Morpheme Bridge', '🌉', 0xFF3B82F6),
];

// Pool materi per level
const List<String> poolVokal = ['A', 'I', 'U', 'E', 'O'];
const List<String> poolSukuKata = ['ba', 'ca', 'da', 'ma', 'sa', 'li', 'ku', 'to'];
const List<String> poolBdpq = ['b', 'd', 'p', 'q'];
const List<String> poolDigraf = ['ng', 'ny', 'sy', 'kh', 'ai', 'au', 'oi', 'ua'];
const List<String> poolKataDasar = ['main', 'baca', 'tulis', 'makan', 'lari', 'sapu', 'buka', 'beli'];

// Pemecahan suku kata untuk Letuskan Balon
const Map<String, List<String>> pecahanSukuKata = {
  'MAIN': ['MA', 'IN'],
  'BACA': ['BA', 'CA'],
  'TULIS': ['TU', 'LIS'],
  'MAKAN': ['MA', 'KAN'],
  'LARI': ['LA', 'RI'],
  'SAPU': ['SA', 'PU'],
  'BUKA': ['BU', 'KA'],
  'BELI': ['BE', 'LI'],
};

const List<String> sukuKataPengecoh = [
  'DA', 'TO', 'PA', 'TA', 'SI', 'LU', 'RO', 'PI', 'NA', 'JA', 'BO', 'NE',
  'KE', 'RE', 'DE', 'PE', 'GE', 'ME', 'TI', 'GA', 'RU', 'KI', 'HA', 'NO',
];

// Morpheme Bridge: kata -> [potongan benar, pengecoh]
class SoalJembatan {
  final String kata;
  final List<String> potongan;
  final List<String> pengecoh;
  const SoalJembatan(this.kata, this.potongan, this.pengecoh);
}

const List<SoalJembatan> poolJembatan = [
  SoalJembatan('menulis', ['me', 'nu', 'lis'], ['ber', 'kan']),
  SoalJembatan('berlari', ['ber', 'la', 'ri'], ['me', 'an']),
  SoalJembatan('membaca', ['mem', 'ba', 'ca'], ['kan', 'ter']),
  SoalJembatan('berjalan', ['ber', 'ja', 'lan'], ['me', 'di']),
  SoalJembatan('bermain', ['ber', 'ma', 'in'], ['an', 'ke']),
  SoalJembatan('memakan', ['me', 'ma', 'kan'], ['ber', 'di']),
  SoalJembatan('terlihat', ['ter', 'li', 'hat'], ['me', 'kan']),
  SoalJembatan('penulisan', ['pe', 'nu', 'li', 'san'], ['ber', 'ter']),
  SoalJembatan('pembaca', ['pem', 'ba', 'ca'], ['an', 'ter']),
  SoalJembatan('dilakukan', ['di', 'la', 'ku', 'kan'], ['me', 'ber']),
  SoalJembatan('perjalanan', ['per', 'ja', 'la', 'nan'], ['me', 'di']),
  SoalJembatan('pembelajaran', ['pem', 'be', 'la', 'jar', 'an'], ['ber', 'ter']),
];
