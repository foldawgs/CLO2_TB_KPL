import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:switchcash/api/currency_api.dart';

import 'currency_api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('CurrencyApi', () {
    late CurrencyApi api;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      api = CurrencyApi(client: mockClient);
    });

    test('returns currency rates when the call completes successfully', () async {
      final mockResponse = {
        "date": "2025-05-07",
        "base": "USD",
        "rates": {
          "IDR": "16000.00",
          "EUR": "0.92",
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      final result = await api.getCurrencyRates();

      expect(result['base'], 'USD');
      expect(result['rates']['IDR'], '16000.00');
      expect(result['rates']['EUR'], '0.92');
    });

    test('throws exception when API returns error', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Internal Server Error', 500),
      );

      expect(() async => await api.getCurrencyRates(), throwsException);
    });
  });
}
