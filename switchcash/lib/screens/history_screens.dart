import 'package:flutter/material.dart';
import 'package:switchcash/data/history_data.dart';
import 'package:switchcash/styles/app_colors.dart';

class HistoryScreens extends StatefulWidget {
  const HistoryScreens({Key? key}) : super(key: key);

  @override
  _HistoryScreensState createState() => _HistoryScreensState();
}

class _HistoryScreensState extends State<HistoryScreens> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    List<String> storedHistory = await HistoryData.getHistory();
    setState(() {
      history = storedHistory;
    });
  }

  Future<void> _clearHistory() async {
    await HistoryData.clearHistory();
    setState(() {
      history = [];
    });
  }

  Future<void> _removeHistoryAt(int index) async {
    await HistoryData.removeHistoryAt(index);
    await _loadHistory(); // reload updated list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
          )
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No history found.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.cardbackground,
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.currency_exchange,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    title: Text(
                      history[index],
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      onPressed: () => _removeHistoryAt(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
