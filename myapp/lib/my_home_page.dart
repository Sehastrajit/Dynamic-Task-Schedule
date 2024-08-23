//lib/my_home_page.dart
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/time_table_entry.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Table Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter your prompt...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _generateContent(_textController.text),
              child: const Text('Generate Time Table'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateContent(String userPrompt) async {
    const systemPrompt = """
    You are an AI assistant that creates daily schedules. Your task is to generate a structured timetable based on the user's input, even if it's vague. Follow these guidelines:

    1. Create a timetable with entries in the format: time-taskname-duration-priority-frequency
    2. Use 24-hour time format (e.g., 09:00, 14:30)
    3. Durations should be in minutes or hours (e.g., 30min, 1h)
    4. Priority should be Low, Medium, or High
    5. Frequency should be Daily, Weekly, or Once, followed by specific days if applicable
    6. If the user's input is too vague, make reasonable assumptions
    7. Always provide at least 5 entries for a day
    8. Ensure the schedule covers a typical day (e.g., 07:00 to 22:00)
    9. If the input specifies a particular day or frequency, adjust the timetable accordingly
    10. If the input is completely unrelated to scheduling, respond with "INVALID_INPUT"

    Example output:
    07:00-Wake up and morning routine-30min-High-Daily
    07:30-Breakfast-30min-Medium-Daily
    08:00-Commute to work-45min-Medium-Weekly Mon,Tue,Wed,Thu,Fri
    08:45-Start work-3h30min-High-Weekly Mon,Tue,Wed,Thu,Fri
    12:15-Lunch break-45min-Medium-Daily
    """;

    final prompt = "$systemPrompt\n\nUser input: $userPrompt\n\nGenerate a timetable:";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'YOUR API KEY HERE',
    );
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      final rawContent = response.text;
      if (rawContent != null && !rawContent.contains('INVALID_INPUT')) {
        final timeTable = _parseTimeTable(rawContent);
        _saveTimeTable(timeTable);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Time table generated and saved successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid input. Please provide schedule-related information.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error generating time table. Please try again.')),
        );
      }
    }
  }

  List<Map<String, String>> _parseTimeTable(String content) {
    final rows = content.split('\n');
    return rows.where((row) => row.trim().isNotEmpty).map((row) {
      final cells = row.split('-');
      if (cells.length >= 5) {
        return {
          'time': cells[0].trim(),
          'task': cells[1].trim(),
          'duration': cells[2].trim(),
          'priority': cells[3].trim(),
          'frequency': cells[4].trim(),
        };
      } else {
        return {
          'time': cells.isNotEmpty ? cells[0].trim() : 'N/A',
          'task': cells.length > 1 ? cells[1].trim() : 'Unspecified Task',
          'duration': cells.length > 2 ? cells[2].trim() : '30min',
          'priority': cells.length > 3 ? cells[3].trim() : 'Medium',
          'frequency': cells.length > 4 ? cells[4].trim() : 'Daily',
        };
      }
    }).toList();
  }

  void _saveTimeTable(List<Map<String, String>> timeTable) {
    final box = Hive.box<TimeTableEntry>('timetables');
    final now = DateTime.now();
    for (final entry in timeTable) {
      final timeTableEntry = TimeTableEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        task: entry['task'] ?? '',
        time: entry['time'] ?? '',
        duration: entry['duration'] ?? '',
        priority: entry['priority'] ?? '',
        frequency: entry['frequency'] ?? '',
        dateTime: DateTime(now.year, now.month, now.day, 
          int.parse(entry['time']?.split(':')[0] ?? '0'), 
          int.parse(entry['time']?.split(':')[1] ?? '0')),
      );
      box.add(timeTableEntry);
    }
  }
}