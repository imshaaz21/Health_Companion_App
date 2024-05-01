class EmotionalTestResult {
  final DateTime testDate;
  final double score;
  final String mood;

  EmotionalTestResult({
    required this.testDate,
    required this.score,
    required this.mood,
  });

  @override
  String toString() {
    return 'EmotionalTestResult(testDate: $testDate, score: $score, mood: $mood)';
  }
}
