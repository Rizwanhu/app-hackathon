extension DateExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  int get daysFromNow {
    final today = DateTime.now().startOfDay;
    return startOfDay.difference(today).inDays;
  }
}

