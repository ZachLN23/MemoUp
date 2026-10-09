import 'package:flutter/material.dart' show TimeOfDay;

/// A single subtask checkbox row inside a [Task].
class Subtask {
  Subtask({required this.title, this.isDone = false});

  String title;
  bool isDone;

  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
        title: json['title'] as String? ?? '',
        isDone: json['isDone'] as bool? ?? false,
      );
}

/// A task on the Home list.
///
/// "Today's Reminders" vs "Upcoming" is derived from [date] via
/// [isToday] rather than stored separately, so editing a task's date
/// moves it between sections automatically.
///
/// [id] is stable for the life of the task. It is also the id of the
/// task's scheduled system notification, so it must stay a positive
/// 31-bit int (AppData hands them out from a counter).
class Task {
  Task({
    required this.id,
    required this.title,
    this.date,
    this.time,
    List<Subtask>? subtasks,
  }) : subtasks = subtasks ?? [];

  final int id;
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

  /// The exact moment this task is due, or null if it has no date or
  /// no time (a task needs both to ring).
  DateTime? get dueAt {
    final d = date;
    final t = time;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date?.toIso8601String(),
        'hour': time?.hour,
        'minute': time?.minute,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final hour = json['hour'] as int?;
    final minute = json['minute'] as int?;
    final dateText = json['date'] as String?;
    return Task(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      date: dateText == null ? null : DateTime.tryParse(dateText),
      time: (hour == null || minute == null)
          ? null
          : TimeOfDay(hour: hour, minute: minute),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((s) => Subtask.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single row on the Completed screen.
class CompletedTask {
  CompletedTask({required this.title, required this.date});

  final String title;
  final DateTime date;

  Map<String, dynamic> toJson() =>
      {'title': title, 'date': date.toIso8601String()};

  factory CompletedTask.fromJson(Map<String, dynamic> json) => CompletedTask(
        title: json['title'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
      );
}
