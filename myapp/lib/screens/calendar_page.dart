//lib/screens/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/time_table_entry.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<TimeTableEntry>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<TimeTableEntry> _getEventsForDay(DateTime day) {
    final box = Hive.box<TimeTableEntry>('timetables');
    final now = DateTime.now();
    return box.values.where((event) {
      // If the day is before today, don't show any events
      if (day.isBefore(DateTime(now.year, now.month, now.day))) {
        return false;
      }
      
      if (event.frequency.toLowerCase().contains('daily')) {
        return true;
      } else if (event.frequency.toLowerCase().contains('weekly')) {
        final weekday = day.weekday;
        final eventWeekdays = event.frequency.toLowerCase().split(',');
        return eventWeekdays.contains(_getWeekdayName(weekday));
      } else {
        // For one-time events, check if it's on or after the current date
        return isSameDay(event.dateTime, day) && 
               !event.dateTime.isBefore(DateTime(now.year, now.month, now.day));
      }
    }).toList();
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'mon';
      case 2: return 'tue';
      case 3: return 'wed';
      case 4: return 'thu';
      case 5: return 'fri';
      case 6: return 'sat';
      case 7: return 'sun';
      default: return '';
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<TimeTableEntry>(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<TimeTableEntry>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () {
                          // Handle event tap
                        },
                        title: Text(event.task),
                        subtitle: Text('${event.time} - ${event.duration}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Priority: ${event.priority}'),
                            Text('Frequency: ${event.frequency}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}