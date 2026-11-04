import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dyleks_mobile/core/penyimpanan.dart';
import 'package:dyleks_mobile/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Data.muat();
  });

  testWidgets('Onboarding muncul dan tombol nonaktif jika nama kosong', (tester) async {
    await tester.pumpWidget(const DyleksApp());
    expect(find.text('Siapa namamu?'), findsOneWidget);

    final tombol = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(tombol.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Raka');
    await tester.pump();
    final tombol2 = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(tombol2.onPressed, isNotNull);
  });

  test('Streak hanya bertambah 1x per hari', () {
    Data.tambahStreak();
    Data.tambahStreak();
    expect(Data.streak, 1);
  });

  test('Tes penempatan tidak menurunkan level', () {
    Data.aturLevelAwal(6);
    Data.aturLevelAwal(3);
    expect(Data.levelSekarang, 6);
    expect(Data.tahapSelesai[4], 5);
  });
}
