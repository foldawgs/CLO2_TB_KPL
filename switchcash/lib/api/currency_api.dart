// lib/services/currency_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApi {
  final http.Client client;

  CurrencyApi({http.Client? client}) : client = client ?? http.Client();

  static const String _apikey = '49c58e15ae044fbe9bea30cae91e81d1';
  static const String _baseUrl = 'https://api.currencyfreaks.com/v2.0/rates/latest';

  Future<Map<String, dynamic>> getCurrencyRates() async {
    final response = await client.get(
      Uri.parse("$_baseUrl?apikey=$_apikey"),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load currency');
    }
  }
}
