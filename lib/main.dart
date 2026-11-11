import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/penyimpanan.dart';
import 'core/suara.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

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
          title: 'DyLeks Mobile',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Nunito',
            colorSchemeSeed: const Color(0xFF7C3AED), // Royal Violet Duolingo
            scaffoldBackgroundColor: const Color(0xFFFAF8FD),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
              ),
              color: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0xFF1E1B2E),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Nunito',
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF7C3AED),
            scaffoldBackgroundColor: const Color(0xFF13111C),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFF2E2744), width: 2),
              ),
              color: const Color(0xFF1E1B2E),
            ),
          ),
          themeMode: Data.temaGelap ? ThemeMode.dark : ThemeMode.light,
          // BUNGKUS DENGAN FRAME SMARTPHONE RESPONSIVE
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final scaledChild = MediaQuery(
              data: mediaQuery.copyWith(textScaler: TextScaler.linear(Data.ukuranTeks)),
              child: child!,
            );

            // Jika dibuka di browser desktop (lebar > 500px), bungkus dalam Frame Smartphone Modern
            if (mediaQuery.size.width > 500) {
              return Container(
                color: const Color(0xFF110D24), // Background desktop gelap elegan
                alignment: Alignment.center,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430, maxHeight: 890),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Data.temaGelap ? const Color(0xFF13111C) : const Color(0xFFFAF8FD),
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(color: const Color(0xFF31285E), width: 6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            offset: Offset(0, 20),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: scaledChild,
                    ),
                  ),
                ),
              );
            }
            return scaledChild;
          },
          home: Data.sudahDaftar ? const HomeScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}
