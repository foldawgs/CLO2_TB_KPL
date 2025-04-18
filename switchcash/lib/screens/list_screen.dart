import 'package:flutter/material.dart';
import 'package:switchcash/api/currency_api.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<Map<String, dynamic>> _futureRates;

  @override
  void initState() {
    super.initState();
    _futureRates = CurrencyApi().getCurrencyRates();
  }

  void _refreshRates() {
    setState(() {
      _futureRates = CurrencyApi().getCurrencyRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Currency Rates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRates,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureRates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final response = snapshot.data;

            if (response is Map<String, dynamic> &&
                response.containsKey('rates')) {
              final rates = response['rates'];
              final base = response['base'];
              if (rates is Map<String, dynamic>) {
                final sortedKeys = rates.keys.toList()..sort();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Base Currency: $base',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 16),
                    ...sortedKeys.map((key) {
                      final value = rates[key];
                      return Text('$key: $value',
                          style: const TextStyle(fontSize: 16));
                    }).toList(),
                  ],
                );
              } else {
                return const Center(
                    child: Text("Rates data is not a valid map"));
              }
            } else {
              return const Center(child: Text("Rates data not available"));
            }
          } else {
            return const Center(child: Text("No data found."));
          }
        },
      ),
    );
  }
}
