import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_companion_app/models/health_data.dart';
import 'package:health_companion_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterProvider with ChangeNotifier {
  // make a map to store the last 5 days steps,
  // the key is the date-time and the value is the steps
  final Map<String, int> _stepsMap = {};

  // last step count
  int lastStepCount = 0;

  StepCounterProvider() {
    _loadStepsMap();
  }

  Future<void> _loadStepsMap() async {
    final pref = await SharedPreferences.getInstance();
    final stepsJson = pref.getString('stepsMap');
    if (stepsJson != null) {
      _stepsMap.addAll(Map<String, int>.from(json.decode(stepsJson)));
      notifyListeners();
    }
  }

  Future<void> _saveStepsMap() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('stepsMap', json.encode(_stepsMap));
  }

  Map<String, int> get stepsMap => _stepsMap;

  void addSteps(String date, int steps) {
    // final today = DateTime.now().add(const Duration(days: 2));
    final formattedToday = formatDateForProvider(DateTime.parse(date));

    if (_stepsMap.containsKey(formattedToday)) {
      debugPrint('Steps map: $_stepsMap');
      _stepsMap[formattedToday] = steps;
    } else {
      debugPrint('Steps map: $_stepsMap');
      final List<DateTime> sortedKeys = _stepsMap.keys
          .map((dateString) => DateTime.parse(dateString))
          .toList()
        ..sort((a, b) => b.compareTo(a));
      debugPrint('Sorted keys: $sortedKeys');

      if (sortedKeys.isNotEmpty) {
        final previousDate = sortedKeys.first;
        final previousDateSteps =
            _stepsMap[formatDateForProvider(previousDate)] ?? 0;
        final difference = steps - int.parse(previousDateSteps.toString());
        _stepsMap[formattedToday] = difference;
      } else {
        _stepsMap[formattedToday] = steps;
      }
    }
    _saveStepsMap();
    _stepsMap[date] = steps;
    notifyListeners();
  }

  //get the todays steps
  int get todaySteps {
    final today = DateTime.now();
    final formattedDate = formatDateForProvider(today);
    return _stepsMap[formattedDate] ?? 0;
  }

  //get the toady's steps calories burnt
  double get todayCaloriesBurnt {
    return todaySteps * 0.04;
  }

  //get the last 5 days steps from today get the today's steps and before 4 days steps
  List<int> get last5DaysSteps {
    final List<int> steps = [];
    for (int i = 0; i < 5; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final formattedDate = formatDateForProvider(date);
      steps.add(_stepsMap[formattedDate] ?? 0);
    }
    return steps;
  }

  List<StepCountData> get last5DaysStepCountData {
    final List<StepCountData> data = [];
    // todays index
    for (int i = 0; i < 5; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final formattedDate = formatDateForProvider(date);
      data.add(StepCountData(i, _stepsMap[formattedDate] ?? 0));
    }
    return data;
  }

  // clear the steps map
  void clear() {
    _stepsMap.clear();
    _saveStepsMap();
    notifyListeners();
  }
}
