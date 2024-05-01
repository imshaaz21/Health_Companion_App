import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:health_companion_app/models/emotional_test_data.dart';
import 'package:health_companion_app/utils/utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionalDetectorProvider with ChangeNotifier {
  List<EmotionalTestResult> _testResults = [];

  List<EmotionalTestResult> get testResults => _testResults;

  EmotionalDetectorProvider() {
    loadTestResults();
  }

  Future<void> loadTestResults() async {
    final pref = await SharedPreferences.getInstance();
    final testResultsJson = pref.getStringList('emotionalTestResults') ?? [];
    _testResults = testResultsJson.map((json) {
      final Map<String, dynamic> data = jsonDecode(json);
      return EmotionalTestResult(
        testDate: DateTime.parse(data['testDate']),
        score: data['score'],
        mood: data['mood'],
      );
    }).toList();

    // Add dummy data if there are less than 5 test results
    // if (_testResults.length < 5) {
    //   // Add 5 dummy data entries
    //   for (int i = 0; i < 5 - _testResults.length; i++) {
    //     _testResults.add(EmotionalTestResult(
    //       testDate: DateTime.now().subtract(Duration(days: i + 1)),
    //       score: 0.88,
    //       mood: 'Neutral',
    //     ));
    //   }
    // }

    debugPrint('EmotionalDetectorProvider loaded data : $_testResults');
    notifyListeners();
  }

  Future<void> addTestResult(String result) async {
    late EmotionalTestResult emotionalTestResult;
    if (double.parse(result) < 0.5) {
      emotionalTestResult = EmotionalTestResult(
        testDate: DateTime.now(),
        score: double.parse(result),
        mood: 'Sad',
      );
    } else if (double.parse(result) < 0.7) {
      emotionalTestResult = EmotionalTestResult(
        testDate: DateTime.now(),
        score: double.parse(result),
        mood: 'Neutral',
      );
    } else {
      emotionalTestResult = EmotionalTestResult(
        testDate: DateTime.now(),
        score: double.parse(result),
        mood: 'Happy',
      );
    }
    _testResults.add(emotionalTestResult);
    debugPrint('EmotionalDetectorProvider added data : $emotionalTestResult');
    await _saveTestResults();
    notifyListeners();
  }

  double getLatestTestScore() {
    if (_testResults.isNotEmpty) {
      return double.parse(_testResults.last.score.toString()) * 100;
    } else {
      return 0.0;
    }
  }

  String? getLatestTestDate() {
    if (_testResults.isNotEmpty) {
      return formatDateForProvider(_testResults.last.testDate);
    } else {
      return null;
    }
  }

  String? getLatestMood() {
    if (_testResults.isNotEmpty) {
      return _testResults.last.mood;
    } else {
      return null;
    }
  }

  Future<void> resetTestResults() async {
    _testResults.clear();
    await _saveTestResults();
    notifyListeners();
  }

  Future<void> _saveTestResults() async {
    final pref = await SharedPreferences.getInstance();
    final testResultsJson = _testResults.map((result) {
      return jsonEncode({
        'testDate': result.testDate.toIso8601String(),
        'score': result.score,
        'mood': result.mood,
      });
    }).toList();
    await pref.setStringList('emotionalTestResults', testResultsJson);
  }
}
