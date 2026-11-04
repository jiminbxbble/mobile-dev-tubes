import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/penyimpanan.dart';
import 'core/suara.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

// Dipakai untuk memberi tahu app agar menggambar ulang tema/ukuran teks
final ValueNotifier<int> perbaruiTampilan = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Data.muat();
  await Suara.siapkan();
  runApp(const DyleksApp());
}

class DyleksApp extends StatelessWidget {
  const DyleksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: perbaruiTampilan,
      builder: (context, _, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DyLeks',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF4F46E5),
            scaffoldBackgroundColor: const Color(0xFFFAF6EE),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF4F46E5),
          ),
          themeMode: Data.temaGelap ? ThemeMode.dark : ThemeMode.light,
          // Ukuran teks dari Pengaturan berlaku di semua layar
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(Data.ukuranTeks)),
            child: child!,
          ),
          home: Data.sudahDaftar ? const HomeScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}
