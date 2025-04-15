import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../ui_library/ui.dart';
import 'history.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _controller = TextEditingController();
  double _result = 0.0;
  List<String> historyList = []; 
  String _selectedCurrency = "USD"; // Default mata uang tujuan
  final List<String> currencies = ["USD", "KRW", "EUR"]; // Pilihan mata uang tujuan

  void _convert() async {
    final input = double.tryParse(_controller.text);
    if (input != null) {
      final rate = await getExchangeRate("IDR", _selectedCurrency);
      setState(() {
        _result = input / rate;
        _addToHistory(input, _result, _selectedCurrency);
      });
    }
  }

  void _addToHistory(double amount, double convertedAmount, String targetCurrency) {
    setState(() {
      historyList.add("$amount IDR → $convertedAmount $targetCurrency");
    });
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => History(historyList: historyList), // Kirim hasil konversi ke HistoryScreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history), 
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter amount (IDR)",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Convert to $_selectedCurrency",
              onPressed: _convert,
            ),
            const SizedBox(height: 30),
            Text(
              "Result: $_result $_selectedCurrency",
              style: AppTextStyles.result,
            ),
          ],
        ),
      ),
    );
  }
}
