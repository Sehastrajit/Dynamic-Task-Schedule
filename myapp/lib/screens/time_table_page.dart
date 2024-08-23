//lib/screens/time_table_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/time_table_entry.dart';

class TimeTablePage extends StatefulWidget {
  final List<TimeTableEntry> timeTable;

  const TimeTablePage({Key? key, required this.timeTable}) : super(key: key);

  @override
  TimeTablePageState createState() => TimeTablePageState();
}

class TimeTablePageState extends State<TimeTablePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Table')),
      body: ListView.builder(
        itemCount: widget.timeTable.length,
        itemBuilder: (context, index) {
          final item = widget.timeTable[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(item.task),
              subtitle: Text('${item.time} - Duration: ${item.duration}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Priority: ${item.priority}'),
                  IconButton(
                    icon: const Icon(Icons.alarm_add),
                    onPressed: () => _showAlarmDialog(context, item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAlarmDialog(BuildContext context, TimeTableEntry item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Alarm'),
          content: Text('Do you want to set an alarm for "${item.task}" at ${item.time}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Set Alarm'),
              onPressed: () {
                // TODO: Implement alarm setting functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alarm set for ${item.task} at ${item.time}')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}