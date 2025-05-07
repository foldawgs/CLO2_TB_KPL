import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:switchcash/api/currency_api.dart';
import 'package:switchcash/data/history_data.dart';
import 'package:switchcash/data/currency_list.dart';
import 'package:switchcash/data/currency_names.dart';
import 'package:switchcash/styles/app_colors.dart';
import 'package:switchcash/models/currecy_model.dart';
import 'package:vibration/vibration.dart';

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
    double amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

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

      final formattedAmount = NumberFormat('#,###.##').format(amount);
      final formattedConverted = NumberFormat('#,###.##').format(convertedAmount);

      setState(() {
        result = '$formattedAmount $baseCurrency = $formattedConverted $targetCurrency';
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

  Future<void> _showCurrencyPicker({
    required String label,
    required String? selectedValue,
    required Function(String) onSelected,
  }) async {
    TextEditingController searchController = TextEditingController();
    List<String> filteredList = currencyList;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search $label",
                      
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredList = currencyList
                            .where((item) => item
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final currency = filteredList[index];
                        return ListTile(
                          title: Text(currency),
                          subtitle: Text(
                            currencyNames[currency] ?? 'Unknown Currency',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: selectedValue == currency
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onSelected(currency);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
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
            // Origin of Currency
            GestureDetector(
              onTap: () => _showCurrencyPicker(
                label: "Origin of Currency",
                selectedValue: _selectedBaseCurrency,
                onSelected: (value) {
                  setState(() {
                    _selectedBaseCurrency = value;
                  });
                },
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Origin of Currency",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                child: Text(
                  _selectedBaseCurrency ?? 'Select Origin of Currency',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                currencyNames[_selectedBaseCurrency ?? ''] ??
                    'Unknown Currency',
                style: const TextStyle(fontSize: 14, color: AppColors.black),
              ),
            ),

            // Currency Destination
            GestureDetector(
              onTap: () => _showCurrencyPicker(
                label: "Currency Destination",
                selectedValue: _selectedTargetCurrency,
                onSelected: (value) {
                  setState(() {
                    _selectedTargetCurrency = value;
                  });
                },
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Currency Destination",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.primary)
                  ),
                ),
                child: Text(
                  _selectedTargetCurrency ?? 'Select Currency Destination',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                currencyNames[_selectedTargetCurrency ?? ''] ??
                    'Unknown Currency',
                style: const TextStyle(fontSize: 14, color: AppColors.black),
              ),
            ),

            // Input amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Input Numbers',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: AppColors.primary)
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final player = AudioPlayer();
                  player.play(AssetSource('Clicking_Sound_3.mp3'));
                  Vibration.vibrate(duration: 100);
                  _convertCurrency();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                  const SizedBox(height: 20),
                  Text(
                    result,
                    style: const TextStyle(
                      fontSize: 20,
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
