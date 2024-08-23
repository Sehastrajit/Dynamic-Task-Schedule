//lib/saved_timetables_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/time_table_entry.dart';
import 'package:myapp/screens/time_table_page.dart';

class SavedTimetablesPage extends StatelessWidget {
  const SavedTimetablesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Time Tables')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TimeTableEntry>('timetables').listenable(),
        builder: (context, Box<TimeTableEntry> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No saved time tables'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final timeTable = box.getAt(index)!;
              return ListTile(
                title: Text(timeTable.task),
                subtitle: Text('${timeTable.time} - ${timeTable.duration}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeTablePage(timeTable: [timeTable]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}