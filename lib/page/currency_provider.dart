import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _currencySymbol = '฿';

  String get currencySymbol => _currencySymbol;

  CurrencyProvider() {
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString('selectedCurrency') ?? '฿';
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrency', symbol);
    _currencySymbol = symbol;
    notifyListeners();
  }
}
