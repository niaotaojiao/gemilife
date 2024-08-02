import 'package:flutter/material.dart';
import 'package:gemilife/home/services/event.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime today;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<Event> Function(DateTime) getEventsForTheDay;

  const CalendarWidget({
    super.key,
    required this.today,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.getEventsForTheDay,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: today,
      firstDay: DateTime.utc(2002, 4, 30),
      lastDay: DateTime.utc(2100, 4, 30),
      rowHeight: 43,
      headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      calendarStyle: const CalendarStyle(
        weekendTextStyle: TextStyle(
          color: Colors.red,
        ),
      ),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      selectedDayPredicate: (day) => isSameDay(day, today),
      eventLoader: getEventsForTheDay,
    );
  }
}
