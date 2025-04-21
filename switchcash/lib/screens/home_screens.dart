import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:switchcash/api/currency_api.dart';
import 'package:switchcash/data/history_data.dart';
import 'package:switchcash/data/currency_list.dart';
import 'package:switchcash/data/currency_names.dart';
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
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isNotEmpty) {
      String formattedText = NumberFormat('#,###').format(int.parse(text));
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
    double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    try {
      CurrencyApi api = CurrencyApi();
      Map<String, dynamic> responseData = await api.getCurrencyRates();
      CurrencyModel currencyData = CurrencyModel.fromJson(responseData);

      if (currencyData.rates.containsKey(baseCurrency) &&
          currencyData.rates.containsKey(targetCurrency)) {
        double fromRate = double.parse(currencyData.rates[baseCurrency].toString());
        double toRate = double.parse(currencyData.rates[targetCurrency].toString());

        double amountInUSD = amount / fromRate;
        double convertedAmount = amountInUSD * toRate;

        setState(() {
          result = '$amount $baseCurrency equals ${convertedAmount.toStringAsFixed(2)} $targetCurrency';
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
    final double width = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Cash'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // asal currency
            DropdownMenu<String>(
              initialSelection: _selectedBaseCurrency,
              enableFilter: true,
              requestFocusOnTap: true,
              width: width,
              menuHeight: 250, // Batasi tinggi dropdown
              hintText: _selectedBaseCurrency == null ? "Ketik untuk cari" : null,
              label: const Text('Currency asal'),
              onSelected: (value) {
                setState(() {
                  _selectedBaseCurrency = value;
                });
              },
              dropdownMenuEntries: currencyList
                  .map((currency) => DropdownMenuEntry(value: currency, label: currency))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                currencyNames[_selectedBaseCurrency ?? ''] ?? 'Unknown Currency',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            // target currency
            DropdownMenu<String>(
              initialSelection: _selectedTargetCurrency,
              enableFilter: true,
              requestFocusOnTap: true,
              width: width,
              menuHeight: 250,
              hintText: _selectedTargetCurrency == null ? "Ketik untuk cari" : null,
              label: const Text('Currency tujuan'),
              onSelected: (value) {
                setState(() {
                  _selectedTargetCurrency = value;
                });
              },
              dropdownMenuEntries: currencyList
                  .map((currency) => DropdownMenuEntry(value: currency, label: currency))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                currencyNames[_selectedTargetCurrency ?? ''] ?? 'Unknown Currency',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Masukkan Jumlah',
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
                  const Text(
                    'Result:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
