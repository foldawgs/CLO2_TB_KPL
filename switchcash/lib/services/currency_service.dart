Future<double> getExchangeRate(String from, String to) async {
  await Future.delayed(const Duration(seconds: 1)); 
  return 15500.0; // simulasi IDR -> USD rate
}
