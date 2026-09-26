import 'package:flutter/material.dart' show TimeOfDay;

/// A single subtask checkbox row inside a [Task].
class Subtask {
  Subtask({required this.title, this.isDone = false});

  String title;
  bool isDone;
}

/// A task on the Home list.
///
/// "Today's Reminders" vs "Upcoming" is derived from [date] via
/// [isToday] rather than stored separately, so editing a task's date
/// moves it between sections automatically.
class Task {
  Task({
    required this.title,
    this.date,
    this.time,
    List<Subtask>? subtasks,
  }) : subtasks = subtasks ?? [];

  String title;
  DateTime? date;
  TimeOfDay? time;
  List<Subtask> subtasks;

  bool get isToday {
    final d = date;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

/// A single row on the Completed screen.
class CompletedTask {
  CompletedTask({required this.title, required this.date});

  final String title;
  final DateTime date;
}
