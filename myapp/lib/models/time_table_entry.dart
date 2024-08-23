//lib/models/time_table_entry.dart
import 'package:hive/hive.dart';

part 'time_table_entry.g.dart';

@HiveType(typeId: 0)
class TimeTableEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String task;

  @HiveField(2)
  final String time;

  @HiveField(3)
  final String duration;

  @HiveField(4)
  final String priority;

  @HiveField(5)
  final DateTime dateTime;

  @HiveField(6)
  final String frequency;

  TimeTableEntry({
    required this.id,
    required this.task,
    required this.time,
    required this.duration,
    required this.priority,
    required this.dateTime,
    required this.frequency,
  });
}