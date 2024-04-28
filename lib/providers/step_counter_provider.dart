import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_companion_app/models/health_data.dart';
import 'package:health_companion_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterProvider with ChangeNotifier {
  // make a map to store the last 5 days steps,
  // the key is the date-time and the value is the steps
  final Map<String, int> _stepsMap = {
    '2024-04-24': 400,
    '2024-04-25': 400,
    '2024-04-26': 400,
    '2024-04-27': 200
  };

  StepCounterProvider() {
    // _loadStepsMap();
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
    _stepsMap[date] = steps;
    // _saveStepsMap();
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

  // return a list of StepCountData for the last 5 days
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
