import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepMonitorProvider with ChangeNotifier {
  String _sleepDuration = '0';
  String _lightCondition = 'Unknown';
  double _luxValue = 0.0;
  Map<String, double> _sleepHistory = {};

  String get sleepDuration => _sleepDuration;
  String get lightCondition => _lightCondition;
  double get luxValue => _luxValue;

  Map<String, double> get sleepHistory => _sleepHistory;

  SleepMonitorProvider() {
    loadSleepHistory();
    // resetSleepHistory();
  }

  void updateSleepDuration(String newDuration) {
    _sleepDuration = newDuration;
    notifyListeners();
  }

  void updateLuxValue(double luxValue) {
    _setLightCondition(luxValue);
    _luxValue = luxValue;
    notifyListeners();
  }

  void _setLightCondition(double luxValue) {
    if (luxValue >= 50000) {
      _lightCondition = 'British Summer sunshine';
    } else if (luxValue >= 10000 && luxValue < 50000) {
      _lightCondition = 'Ambient Daylight';
    } else if (luxValue >= 1000 && luxValue < 10000) {
      _lightCondition = 'Overcast daylight';
    } else if (luxValue >= 500 && luxValue < 1000) {
      _lightCondition = 'Well lit office';
    } else if (luxValue >= 400 && luxValue < 500) {
      _lightCondition = 'Sunset & Sunrise';
    } else if (luxValue >= 120 && luxValue < 400) {
      _lightCondition = 'Family living room';
    } else if (luxValue >= 100 && luxValue < 120) {
      _lightCondition = 'Lifts';
    } else if (luxValue >= 15 && luxValue < 100) {
      _lightCondition = 'Street lightning';
    } else if (luxValue >= 1 && luxValue < 15) {
      _lightCondition = 'Moonlight (full moon)';
    } else if (luxValue >= 0.1 && luxValue < 1) {
      _lightCondition = 'Night (No moon)';
    } else {
      _lightCondition = 'Unknown';
    }
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
