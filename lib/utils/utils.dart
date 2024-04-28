String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

// formate date for provider yyyy-mm-dd
String formatDateForProvider(DateTime d) {
  return '${d.year}-${d.month}-${d.day}';
}
