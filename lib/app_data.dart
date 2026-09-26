import 'package:flutter/material.dart' show TimeOfDay;

import 'task.dart';

/// Tiny in-memory store shared across screens via constructor
/// injection (see MyApp — it's created once in State, not rebuilt).
/// Nothing here is persisted: it resets when the app restarts. Swap
/// this out for real storage later without touching the screens,
/// since they only ever call these methods, never touch a list
/// directly.
class AppData {
  AppData()
      : tasks = [
          Task(
            title: 'Submit Assignment',
            date: DateTime.now(),
            time: const TimeOfDay(hour: 8, minute: 0),
          ),
          Task(
            title: 'Team Meeting',
            date: DateTime.now(),
            time: const TimeOfDay(hour: 14, minute: 0),
          ),
          Task(
            title: 'Doctor Appointment',
            date: DateTime.now().add(const Duration(days: 3)),
          ),
          Task(
            title: 'Pay Electricity Bill',
            date: DateTime.now().add(const Duration(days: 5)),
          ),
        ],
        completed = [
          CompletedTask(
            title: 'Buy Groceries',
            date: DateTime.now().subtract(const Duration(days: 7)),
          ),
          CompletedTask(
            title: 'Team Meeting',
            date: DateTime.now().subtract(const Duration(days: 9)),
          ),
        ];

  final List<Task> tasks;
  final List<CompletedTask> completed;

  /// Built-in + uploaded sound names shown as checklist options on
  /// Sound Settings. [selectedSound] is which one is currently active.
  List<String> soundOptions = ['Morning Sunshine'];
  String selectedSound = 'Morning Sunshine';
  Duration defaultSnooze = const Duration(minutes: 5);

  void selectSound(String name) => selectedSound = name;

  /// Called by Sound Settings after a successful file pick. A newly
  /// uploaded sound becomes the selected one — otherwise uploading
  /// would have no visible effect until the user finds it in the list.
  void addCustomSound(String name) {
    if (!soundOptions.contains(name)) soundOptions.add(name);
    selectedSound = name;
  }

  /// Adds [task] as new, or — when [replacing] is an existing task —
  /// overwrites it in place instead.
  void addOrUpdateTask(Task task, {Task? replacing}) {
    if (replacing != null) {
      final i = tasks.indexOf(replacing);
      if (i != -1) {
        tasks[i] = task;
        return;
      }
    }
    tasks.add(task);
  }

  void deleteTask(Task task) => tasks.remove(task);

  /// Moves [task] off the Home list and onto the Completed list.
  /// Nothing calls this yet — it's here for the Alarm Popup's
  /// "Mark as Done" to wire up to next.
  void completeTask(Task task) {
    tasks.remove(task);
    completed.insert(0, CompletedTask(title: task.title, date: DateTime.now()));
  }

  void clearHistory() => completed.clear();
}
