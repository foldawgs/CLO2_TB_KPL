import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:switchcash/main.dart'; // Pastikan path-nya sesuai

void main() {
  testWidgets('BottomNavigationBar switches screens', (WidgetTester tester) async {
    // Render MainPage
    await tester.pumpWidget(
      MaterialApp(
        home: MainPage(),
      ),
    );

    // Awalnya halaman pertama (HomeScreens)
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.byIcon(Icons.currency_exchange), findsOneWidget);

    // Tap ikon History
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle(); // Tunggu animasi selesai

    // Sekarang seharusnya tampilan HistoryScreens
    expect(find.text('History'), findsWidgets); // Ganti sesuai isi widget kamu

    // Tap ikon Currency Rates
    await tester.tap(find.byIcon(Icons.currency_exchange));
    await tester.pumpAndSettle();

    // Cek tampilan ListScreen
    expect(find.text('Currency Rates'), findsWidgets); // Ganti sesuai isi ListScreen
  });
}
