// import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryData {
  static const String historyKey = 'currency_conversion_history';


  static Future<void> saveHistory(String entry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(historyKey) ?? [];
    history.add(entry); 
    await prefs.setStringList(historyKey, history); 
  }


  static Future<List<String>> getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(historyKey) ?? []; 
  }


  static Future<void> clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey); 
  }

  static Future<void> removeHistoryAt(int index) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList(historyKey) ?? [];
  if (index >= 0 && index < history.length) {
    history.removeAt(index);
    await prefs.setStringList(historyKey, history);
  }
}
}
