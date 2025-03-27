import 'package:flutter/material.dart';
import 'package:switchcash/data/history_data.dart';

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
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(history[index]),
          );
        },
      ),
    );
  }
}
