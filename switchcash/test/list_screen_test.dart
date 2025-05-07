import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// import 'package:switchcash/screens/list_screen.dart';
import 'package:switchcash/api/currency_api.dart';
import 'mock_currency_api.mocks.dart';

void main() {
  testWidgets('Search filters the currency list', (WidgetTester tester) async {
    final mockApi = MockCurrencyApi();

    // Mock data
    when(mockApi.getCurrencyRates()).thenAnswer(
      (_) async => {
        'base': 'USD',
        'date': '2023-10-10',
        'rates': {
          'IDR': '15000',
          'EUR': '0.93',
          'JPY': '110.0',
          'INR': '75.0',
        }
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ListScreenWrapper(mockApi: mockApi),
      ),
    );

    // Tunggu future selesai
    await tester.pumpAndSettle();

    // Pastikan item tampil sebelum search
    expect(find.text('IDR'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);

    // Masukkan pencarian
    await tester.enterText(find.byType(TextField), 'JP');
    await tester.pumpAndSettle();

    // Hanya JPY yang muncul
    expect(find.text('JPY'), findsOneWidget);
    expect(find.text('IDR'), findsNothing);
    expect(find.text('EUR'), findsNothing);
  });
}

// Wrapper untuk inject mock API
class ListScreenWrapper extends StatelessWidget {
  final CurrencyApi mockApi;

  const ListScreenWrapper({super.key, required this.mockApi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _TestableListScreen(mockApi: mockApi),
      ),
    );
  }
}

// Widget testable dengan API yang bisa di-inject
class _TestableListScreen extends StatefulWidget {
  final CurrencyApi mockApi;
  const _TestableListScreen({required this.mockApi});

  @override
  State<_TestableListScreen> createState() => _TestableListScreenState();
}

class _TestableListScreenState extends State<_TestableListScreen> {
  late Future<Map<String, dynamic>> _futureRates;
  String _searchQuery = '';
  int _visibleItemCount = 50;

  @override
  void initState() {
    super.initState();
    _futureRates = widget.mockApi.getCurrencyRates();
  }

  // void _loadMore() {
  //   setState(() {
  //     _visibleItemCount += 50;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureRates,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final data = snapshot.data!;
        final rates = Map<String, dynamic>.from(data['rates']);
        final sortedKeys = rates.keys.toList()..sort();
        final filteredKeys = sortedKeys
            .where((key) => key.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
        final visibleKeys = filteredKeys.take(_visibleItemCount).toList();

        return Column(
          children: [
            TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _visibleItemCount = 50;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: visibleKeys.length,
                itemBuilder: (context, index) {
                  final key = visibleKeys[index];
                  return ListTile(title: Text(key));
                },
              ),
            )
          ],
        );
      },
    );
  }
}
