import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:switchcash/api/currency_api.dart';
import 'package:switchcash/data/history_data.dart';
import 'package:switchcash/data/currency_list.dart';
import 'package:switchcash/models/currecy_model.dart';
import 'package:switchcash/widgets/costum_button.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  _HomeScreensState createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final TextEditingController _amountController = TextEditingController();
  String result = '';
  List<String> history = [];

  String? _selectedBaseCurrency;
  String? _selectedTargetCurrency;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _amountController.addListener(_formatAmount);
  }

  Future<void> _loadHistory() async {
    List<String> storedHistory = await HistoryData.getHistory();
    setState(() {
      history = storedHistory;
    });
  }

  void _formatAmount() {
    String text = _amountController.text;
    // Remove any non-numeric characters
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    // If the text is empty or just a number, format it
    if (text.isNotEmpty) {
      String formattedText = NumberFormat('#,###').format(int.parse(text));
      // Only update if the text is different to avoid the cursor jumping
      if (_amountController.text != formattedText) {
        _amountController.value = _amountController.value.copyWith(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    }
  }

  Future<void> _convertCurrency() async {
    if (_selectedBaseCurrency == null ||
        _selectedTargetCurrency == null ||
        _amountController.text.isEmpty) {
      setState(() {
        result = 'Please fill in all fields!';
      });
      return;
    }

    String baseCurrency = _selectedBaseCurrency!;
    String targetCurrency = _selectedTargetCurrency!;
    // Remove formatting and parse the number as it would be sent to the API
    double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    try {
      CurrencyApi api = CurrencyApi();
      Map<String, dynamic> responseData = await api.getCurrencyRates();
      CurrencyModel currencyData = CurrencyModel.fromJson(responseData);

      if (currencyData.rates.containsKey(baseCurrency) &&
          currencyData.rates.containsKey(targetCurrency)) {
        double fromRate =
            double.parse(currencyData.rates[baseCurrency].toString());
        double toRate =
            double.parse(currencyData.rates[targetCurrency].toString());

        double amountInUSD = amount / fromRate;
        double convertedAmount = amountInUSD * toRate;

        setState(() {
          result =
              '$amount $baseCurrency equals $convertedAmount $targetCurrency';
        });

        await _saveToHistory(result);
      } else {
        setState(() {
          result = 'Invalid currency code!';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _saveToHistory(String entry) async {
    await HistoryData.saveHistory(entry);
    List<String> updatedHistory = await HistoryData.getHistory();
    setState(() {
      history = updatedHistory;
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Cash'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Currency asal',
                border: OutlineInputBorder(),
              ),
              value: _selectedBaseCurrency,
              items: currencyList.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBaseCurrency = value;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Currency tujuan',
                border: OutlineInputBorder(),
              ),
              value: _selectedTargetCurrency,
              items: currencyList.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTargetCurrency = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Masukan Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomButton(
                text: 'Convert',
                onPressed: _convertCurrency,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
              children: [
                Text(
                'Result:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                ),
                Text(
                result,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
