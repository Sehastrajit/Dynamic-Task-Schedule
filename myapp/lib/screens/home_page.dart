//lib/screens/home_page.dart
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
  bool _showTextBox = false;
  String _currentAction = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleTextBox(String action) {
    setState(() {
      _showTextBox = !_showTextBox;
      _currentAction = action;
      if (!_showTextBox) {
        _textController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOVA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'NOVA',
                  style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _toggleTextBox('generate'),
                      child: const Text('NEW', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _toggleTextBox('modify'),
                      child: const Text('MODIFY', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              if (_showTextBox) ...[
                const SizedBox(height: 32),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: _currentAction == 'generate'
                        ? 'Enter your prompt to generate a new timetable...'
                        : 'Enter your prompt to modify the existing timetable...',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_currentAction == 'generate') {
                      _generateContent(_textController.text);
                    } else {
                      _modifyTimeTable(_textController.text);
                    }
                    _toggleTextBox('');
                  },
                  child: Text(_currentAction == 'generate' ? 'Generate' : 'Modify'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
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
    11. Only generate events for today and future dates, not past dates
    12. If no specific date is mentioned, assume the schedule starts from today
    13. For study-related tasks, strictly adhere to the specified duration. If the user requests 3 hours of study, ensure it's exactly 3 hours per day, week, or month as specified. Do not exceed this duration unless explicitly stated by the user.
    14. For non-study tasks, you can be more flexible with the duration based on typical time requirements for those activities.

    Example output:
    07:00-Wake up and morning routine-30min-High-Daily
    07:30-Breakfast-30min-Medium-Daily
    08:00-Commute to work-45min-Medium-Weekly Mon,Tue,Wed,Thu,Fri
    09:00-Study session-3h-High-Daily
    12:00-Lunch break-1h-Medium-Daily
    13:00-Work/Classes-4h-High-Weekly Mon,Tue,Wed,Thu,Fri
    17:00-Exercise-1h-Medium-Daily
    18:00-Dinner-1h-Medium-Daily
    19:00-Free time/Hobbies-2h-Low-Daily
    21:00-Evening routine-1h-Medium-Daily
    22:00-Sleep-8h-High-Daily
    """;

    final prompt = "$systemPrompt\n\nUser input: $userPrompt\n\nGenerate a timetable:";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyACHQG5LqAaMxvLdaxVCWn1_nGqBTRMNys',
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
      final entryDateTime = _parseDateTime(entry['time'] ?? '');
      // Only save entries that are today or in the future
      if (!entryDateTime.isBefore(DateTime(now.year, now.month, now.day))) {
        final timeTableEntry = TimeTableEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          task: entry['task'] ?? '',
          time: entry['time'] ?? '',
          duration: entry['duration'] ?? '',
          priority: entry['priority'] ?? '',
          frequency: entry['frequency'] ?? '',
          dateTime: entryDateTime,
        );
        box.add(timeTableEntry);
      }
    }
  }

  DateTime _parseDateTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    return DateTime(now.year, now.month, now.day, 
      int.parse(parts[0]), 
      int.parse(parts[1]));
  }

  Future<void> _modifyTimeTable(String modificationPrompt) async {
    const systemPrompt = """
    You are an AI assistant that modifies existing schedules. Your task is to update a timetable based on the user's modification request. Follow these guidelines:

    1. Interpret the user's request and identify which entries to modify.
    2. Provide modifications in the format: action-time-taskname-duration-priority-frequency
    3. Actions can be: add, remove, update
    4. Use 24-hour time format (e.g., 09:00, 14:30)
    5. Durations should be in minutes or hours (e.g., 30min, 1h)
    6. Priority should be Low, Medium, or High
    7. Frequency should be Daily, Weekly, or Once, followed by specific days if applicable
    8. If the request is unclear, ask for clarification
    9. For study-related tasks, strictly adhere to the specified duration. If the user requests a change to study time, ensure it's exactly as specified per day, week, or month. Do not exceed this duration unless explicitly stated by the user.
    10. For non-study tasks, you can be more flexible with the duration based on typical time requirements for those activities.

    Example output:
    update-09:00-Study session-2h-High-Daily
    add-18:00-Evening workout-1h-High-Daily
    remove-12:15-Lunch break
    """;

    final prompt = "$systemPrompt\n\nCurrent timetable:\n${_getCurrentTimetable()}\n\nModification request: $modificationPrompt\n\nProvide modifications:";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'YOUR API KEY HERE',
    );
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      final rawContent = response.text;
      if (rawContent != null) {
        final modifications = _parseModifications(rawContent);
        _updateTimetable(modifications);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid modification request. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error modifying time table. Please try again.')),
        );
      }
    }
  }

  String _getCurrentTimetable() {
    final box = Hive.box<TimeTableEntry>('timetables');
    return box.values.map((entry) => 
      "${entry.time}-${entry.task}-${entry.duration}-${entry.priority}-${entry.frequency}"
    ).join('\n');
  }

  List<Map<String, String>> _parseModifications(String content) {
    final rows = content.split('\n');
    return rows.where((row) => row.trim().isNotEmpty).map((row) {
      final cells = row.split('-');
      if (cells.length >= 2) {
        return {
          'action': cells[0].trim(),
          'time': cells[1].trim(),
          'task': cells.length > 2 ? cells[2].trim() : '',
          'duration': cells.length > 3 ? cells[3].trim() : '',
          'priority': cells.length > 4 ? cells[4].trim() : '',
          'frequency': cells.length > 5 ? cells[5].trim() : '',
        };
      } else {
        return {'action': 'invalid'};
      }
    }).toList();
  }

  void _updateTimetable(List<Map<String, String>> modifications) {
    for (final mod in modifications) {
      final action = mod['action'];
      final time = mod['time'];

      switch (action) {
        case 'add':
          _addEntry(mod);
          break;
        case 'remove':
          _removeEntry(time);
          break;
        case 'update':
          _updateEntry(time, mod);
          break;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time table updated successfully!')),
      );
    }
  }

  void _addEntry(Map<String, String> entry) {
    final box = Hive.box<TimeTableEntry>('timetables');
    final newEntry = TimeTableEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: entry['task'] ?? '',
      time: entry['time'] ?? '',
      duration: entry['duration'] ?? '',
      priority: entry['priority'] ?? '',
      frequency: entry['frequency'] ?? '',
      dateTime: _parseDateTime(entry['time'] ?? ''),
    );
    box.add(newEntry);
  }

  void _removeEntry(String? time) {
    if (time == null) return;
    final box = Hive.box<TimeTableEntry>('timetables');
    final entryToRemove = box.values.cast<TimeTableEntry?>().firstWhere(
      (entry) => entry?.time == time,
      orElse: () => null,
    );
    if (entryToRemove != null) {
      box.delete(entryToRemove.key);
    }
  }

  void _updateEntry(String? time, Map<String, String> updatedInfo) {
    if (time == null) return;
    final box = Hive.box<TimeTableEntry>('timetables');
    final entryToUpdate = box.values.cast<TimeTableEntry?>().firstWhere(
      (entry) => entry?.time == time,
      orElse: () => null,
    );
    if (entryToUpdate != null) {
      final updatedEntry = TimeTableEntry(
        id: entryToUpdate.id,
        task: updatedInfo['task'] ?? entryToUpdate.task,
        time: updatedInfo['time'] ?? entryToUpdate.time,
        duration: updatedInfo['duration'] ?? entryToUpdate.duration,
        priority: updatedInfo['priority'] ?? entryToUpdate.priority,
        frequency: updatedInfo['frequency'] ?? entryToUpdate.frequency,
        dateTime: _parseDateTime(updatedInfo['time'] ?? entryToUpdate.time),
      );
      box.put(entryToUpdate.key, updatedEntry);
    }
  }
}