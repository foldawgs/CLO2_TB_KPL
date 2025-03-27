import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApi {
  static const String _apikey = '49c58e15ae044fbe9bea30cae91e81d1'; 
  static const String _baseUrl = 'https://api.currencyfreaks.com/v2.0/rates/latest';


  Future<Map<String, dynamic>> getCurrencyRates() async {
    final response = await http.get(
      Uri.parse("$_baseUrl?apikey=$_apikey"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load currency');
    }
  }
}