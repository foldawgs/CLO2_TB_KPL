import 'package:flutter/material.dart';
import 'package:switchcash/api/currency_api.dart';
import 'package:switchcash/styles/app_colors.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<Map<String, dynamic>> _futureRates;
  String _searchQuery = '';
  int _visibleItemCount = 50;

  @override
  void initState() {
    super.initState();
    _futureRates = CurrencyApi().getCurrencyRates();
  }

  void _refreshRates() {
    setState(() {
      _futureRates = CurrencyApi().getCurrencyRates();
      _visibleItemCount = 50;
    });
  }

  void _loadMore() {
    setState(() {
      _visibleItemCount += 50;
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureRates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final base = data['base'];
            final date = data['date'];
            final rates = Map<String, dynamic>.from(data['rates']);
            final sortedKeys = rates.keys.toList()..sort();

            final filteredKeys = sortedKeys
                .where((key) =>
                    key.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            final visibleKeys = filteredKeys.take(_visibleItemCount).toList();
            final hasMore = _visibleItemCount < filteredKeys.length;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Date: $date', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Base Currency: $base',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Currency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _visibleItemCount = 50;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visibleKeys.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < visibleKeys.length) {
                          final key = visibleKeys[index];
                          final value = rates[key];
                          final formattedValue =
                              double.tryParse(value.toString())
                                      ?.toStringAsFixed(4) ??
                                  value.toString();
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(
                                  Icons.monetization_on_outlined,
                                  color: AppColors.primary),
                              title: Text(key),
                              trailing: Text(
                                formattedValue,
                                style: const TextStyle(
                                  fontSize: 15, // Bikin angka lebih gede
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: _loadMore,
                                child: const Text('Load More'),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("No data found."));
          }
        },
      ),
    );
  }
}
