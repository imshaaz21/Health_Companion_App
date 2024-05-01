import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepMonitorProvider with ChangeNotifier {
  String _sleepDuration = '0';
  Map<String, double> _sleepHistory = {};

  String get sleepDuration => _sleepDuration;
  Map<String, double> get sleepHistory => _sleepHistory;

  SleepMonitorProvider() {
    loadSleepHistory();
  }

  void updateSleepDuration(String newDuration) {
    _sleepDuration = newDuration;
    notifyListeners();
  }

  Future<void> loadSleepHistory() async {
    final pref = await SharedPreferences.getInstance();
    final sleepHistory = pref.getStringList('sleepHistory') ?? [];

    if (sleepHistory.length < 2) {
      final today = DateTime.now();
      for (int i = 0; i < 4; i++) {
        final date = today.subtract(Duration(days: i + 1));
        final weekDay = _getWeekDayAbbreviation(date.weekday);
        _sleepHistory[weekDay] = 2 * (i + 1);
      }
    } else {
      _sleepHistory = {
        for (var item in sleepHistory)
          item.substring(0, 3): double.parse(item.substring(3))
      };
    }
    notifyListeners();
  }

  Future<void> addSleepData(double sleepDuration) async {
    final weekDay = _getWeekDayAbbreviation(DateTime.now().weekday);
    _sleepHistory[weekDay] = (_sleepHistory[weekDay] ?? 0) + sleepDuration;
    if (_sleepHistory.length > 5) {
      final oldestEntryKey = _sleepHistory.keys.first;
      _sleepHistory.remove(oldestEntryKey);
    }
    await _saveSleepHistory();
    debugPrint('Sleep history: $_sleepHistory');
    notifyListeners();
  }

  String _getWeekDayAbbreviation(int weekDay) {
    switch (weekDay) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Future<void> _saveSleepHistory() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setStringList(
      'sleepHistory',
      _sleepHistory.entries
          .map((entry) => '${entry.key}${entry.value.toStringAsFixed(2)}')
          .toList(),
    );
  }

  String get todaysSleepHours {
    final weekDay = _getWeekDayAbbreviation(DateTime.now().weekday);
    final todaySleepDuration = _sleepHistory[weekDay] ?? 0;
    return (todaySleepDuration / 3600).toStringAsFixed(2);
  }

  String get todaysSleepDurationFormatted {
    final weekDay = _getWeekDayAbbreviation(DateTime.now().weekday);
    final todaySleepDurationSeconds = _sleepHistory[weekDay] ?? 0;

    final hours = todaySleepDurationSeconds ~/ 3600;
    final minutes = (todaySleepDurationSeconds % 3600) ~/ 60;

    return '$hours hours $minutes mins';
  }

  Future<void> resetSleepHistory() async {
    _sleepHistory.clear();
    await _saveSleepHistory();
    notifyListeners();
  }
}
