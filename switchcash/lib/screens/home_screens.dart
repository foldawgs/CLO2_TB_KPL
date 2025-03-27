import 'package:flutter/material.dart';
import 'package:switchcash/api/currency_api.dart';
import 'package:switchcash/data/history_data.dart';
import 'package:switchcash/models/currecy_model.dart';
import 'package:switchcash/widgets/costum_button.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  _HomeScreensState createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final TextEditingController _baseCurrencyController = TextEditingController();
  final TextEditingController _targetCurrencyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String result = '';
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

  Future<void> _convertCurrency() async {
    if (_baseCurrencyController.text.isEmpty ||
        _targetCurrencyController.text.isEmpty ||
        _amountController.text.isEmpty) {
      setState(() {
        result = 'Please fill in all fields!';
      });
      return;
    }

    String baseCurrency = _baseCurrencyController.text.toUpperCase();
    String targetCurrency = _targetCurrencyController.text.toUpperCase();
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    try {
      CurrencyApi api = CurrencyApi();
      Map<String, dynamic> responseData = await api.getCurrencyRates();
      CurrencyModel currencyData = CurrencyModel.fromJson(responseData);

      if (currencyData.rates.containsKey(baseCurrency) && currencyData.rates.containsKey(targetCurrency)) {
        double fromRate = double.parse(currencyData.rates[baseCurrency].toString());
        double toRate = double.parse(currencyData.rates[targetCurrency].toString());

 
        double amountInUSD = amount / fromRate;
        double convertedAmount = amountInUSD * toRate;

        setState(() {
          result = '$amount $baseCurrency equals $convertedAmount $targetCurrency';
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
    _baseCurrencyController.dispose();
    _targetCurrencyController.dispose();
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
            CustomTextBox(
              hintText: 'Masukan Currency yang akan di convert',
              controller: _baseCurrencyController,
              isPassword: false,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            CustomTextBox(
              hintText: 'Masukan Currency target',
              controller: _targetCurrencyController,
              isPassword: false,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            CustomTextBox(
              hintText: 'Enter amount',
              controller: _amountController,
              isPassword: false,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomButton(
                text: 'Convert',
                onPressed: _convertCurrency,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
