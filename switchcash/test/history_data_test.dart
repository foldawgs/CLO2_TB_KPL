import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switchcash/data/history_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryData', () {
    setUp(() {
      // Set initial mock SharedPreferences data kosong
      SharedPreferences.setMockInitialValues({});
    });

    test('saveHistory should add entry to SharedPreferences', () async {
      await HistoryData.saveHistory('USD to IDR: 100 -> 150000');
      final history = await HistoryData.getHistory();
      expect(history.length, 1);
      expect(history[0], 'USD to IDR: 100 -> 150000');
    });

    test('getHistory should return empty list if no data saved', () async {
      final history = await HistoryData.getHistory();
      expect(history, []);
    });

    test('clearHistory should remove all saved entries', () async {
      await HistoryData.saveHistory('Entry 1');
      await HistoryData.clearHistory();
      final history = await HistoryData.getHistory();
      expect(history, []);
    });

    test('removeHistoryAt should remove entry at specific index', () async {
      await HistoryData.saveHistory('Entry 1');
      await HistoryData.saveHistory('Entry 2');
      await HistoryData.saveHistory('Entry 3');

      await HistoryData.removeHistoryAt(1);

      final history = await HistoryData.getHistory();
      expect(history.length, 2);
      expect(history.contains('Entry 2'), false);
      expect(history[0], 'Entry 1');
      expect(history[1], 'Entry 3');
    });

    test('removeHistoryAt with invalid index should do nothing', () async {
      await HistoryData.saveHistory('Entry 1');

      await HistoryData.removeHistoryAt(10); // Index out of range

      final history = await HistoryData.getHistory();
      expect(history.length, 1);
    });
  });
}
