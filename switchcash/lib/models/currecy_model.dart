import 'package:flutter/material.dart';

class CurrencyModel {
  final String base;
  final Map<String, dynamic> rates;

  CurrencyModel({required this.base, required this.rates});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      base: json['base'],
      rates: json['rates'],
    );
  }
}