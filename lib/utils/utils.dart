String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}


String formatDateForProvider(DateTime d) {
  String formattedMonth = d.month < 10 ? '0${d.month}' : '${d.month}';
  String formattedDay = d.day < 10 ? '0${d.day}' : '${d.day}';
  return '${d.year}-$formattedMonth-$formattedDay';
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitHours = twoDigits(duration.inHours.remainder(24));
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitHours H : $twoDigitMinutes min : $twoDigitSeconds s';
}

String getWeekDayAbbreviation(int weekDay) {
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
