import 'package:flutter/material.dart';
import '../ui_library/ui.dart';

class History extends StatefulWidget {
  final List<String> historyList;

  const History({super.key, required this.historyList});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late List<String> history;

  @override
  void initState() {
    super.initState();
    history = List.from(widget.historyList); 
  }

  void _deleteHistory(int index) {
    setState(() {
      history.removeAt(index);
    });
  }

  void _clearAllHistory() {
    setState(() {
      history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversion History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllHistory, 
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                'Riwayat Konversi Kosong',
                style: AppTextStyles.body,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.currency_exchange, color: Color.fromARGB(255, 45, 170, 228)),
                    title: Text(
                      history[index],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 235, 81, 70)),
                      onPressed: () => _deleteHistory(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
