import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';
import 'task.dart';

/// The app's data store, shared across screens via constructor injection.
///
/// Everything is saved to the device (SharedPreferences, as one JSON
/// blob) after every change, and every change also re-syncs the
/// scheduled system notifications — so reminders keep ringing after the
/// app is closed. Screens only ever call the methods below.
///
/// [AppData.load] is also used by the notification-action handler, which
/// runs in a separate background isolate while the app is closed.
class AppData {
  AppData._(this._prefs);

  /// In-memory only: nothing is saved, no notifications are scheduled.
  /// For widget tests.
  AppData.memory() : _prefs = null;

  static const String _storageKey = 'memoup_data_v1';

  final SharedPreferences? _prefs;

  final List<Task> tasks = [];
  final List<CompletedTask> completed = [];

  /// Notification Settings. Gates whether reminders ring at all (both the
  /// system notification and the in-app Alarm Popup) and whether they
  /// vibrate.
  bool notificationsEnabled = true;
  bool vibrateOnReminder = true;

  /// Built-in + uploaded sound names shown as checklist options on
  /// Sound Settings. [selectedSound] is which one is currently active.
  List<String> soundOptions = ['Morning Sunshine'];
  String selectedSound = 'Morning Sunshine';
  Duration defaultSnooze = const Duration(minutes: 5);

  int _nextId = 1;

  // Saves are chained so they run one at a time, in order.
  Future<void> _pending = Future.value();

  /// Reads saved data from the device.
  static Future<AppData> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // pick up writes made by another isolate
    final data = AppData._(prefs);
    data._readFrom(prefs);
    return data;
  }

  /// Re-reads the saved data (e.g. after the background handler changed
  /// it while the app was closed or in the background).
  Future<void> reload() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await _pending; // never throw away an unsaved change
    await prefs.reload();
    _readFrom(prefs);
  }

  /// Completes when every change made so far is saved and synced.
  Future<void> whenSaved() => _pending;

  void _readFrom(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    tasks.clear();
    completed.clear();
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      tasks.addAll((json['tasks'] as List<dynamic>? ?? [])
          .map((t) => Task.fromJson(t as Map<String, dynamic>)));
      completed.addAll((json['completed'] as List<dynamic>? ?? [])
          .map((c) => CompletedTask.fromJson(c as Map<String, dynamic>)));
      notificationsEnabled = json['notificationsEnabled'] as bool? ?? true;
      vibrateOnReminder = json['vibrateOnReminder'] as bool? ?? true;
      soundOptions = (json['soundOptions'] as List<dynamic>? ??
              ['Morning Sunshine'])
          .cast<String>()
          .toList();
      selectedSound = json['selectedSound'] as String? ?? 'Morning Sunshine';
      defaultSnooze =
          Duration(minutes: json['snoozeMinutes'] as int? ?? 5);
      _nextId = json['nextId'] as int? ?? 1;
    } catch (e) {
      // A corrupt save shouldn't brick the app — start empty.
      debugPrint('MemoUp: could not read saved data: $e');
      tasks.clear();
      completed.clear();
    }
  }

  Future<void> _persist({List<int> dismissIds = const []}) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'completed': completed.map((c) => c.toJson()).toList(),
        'notificationsEnabled': notificationsEnabled,
        'vibrateOnReminder': vibrateOnReminder,
        'soundOptions': soundOptions,
        'selectedSound': selectedSound,
        'snoozeMinutes': defaultSnooze.inMinutes,
        'nextId': _nextId,
      }),
    );
    for (final id in dismissIds) {
      await NotificationService.dismiss(id);
    }
    await NotificationService.syncAll(this);
  }

  /// Saves + re-syncs notifications. [dismissIds] are tasks whose
  /// already-shown notification should be cleared from the shade.
  void _changed({List<int> dismissIds = const []}) {
    _pending = _pending
        .then((_) => _persist(dismissIds: dismissIds))
        .catchError((Object e) {
      debugPrint('MemoUp: save failed: $e');
    });
  }

  Task? _find(int id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ---- Settings ----

  void updateNotificationSettings({
    required bool enabled,
    required bool vibrate,
  }) {
    notificationsEnabled = enabled;
    vibrateOnReminder = vibrate;
    _changed();
  }

  void setDefaultSnooze(Duration value) {
    defaultSnooze = value;
    _changed();
  }

  void selectSound(String name) {
    selectedSound = name;
    _changed();
  }

  /// Called by Sound Settings after a successful file pick. A newly
  /// uploaded sound becomes the selected one — otherwise uploading
  /// would have no visible effect until the user finds it in the list.
  void addCustomSound(String name) {
    if (!soundOptions.contains(name)) soundOptions.add(name);
    selectedSound = name;
    _changed();
  }

  // ---- Tasks ----

  /// A fresh id for a task that is about to be created.
  int newTaskId() => _nextId++;

  /// Adds [task] as new, or — when [replacing] is an existing task —
  /// overwrites it in place instead. Matches by id, so it still works
  /// after [reload] swapped the list's objects.
  void addOrUpdateTask(Task task, {Task? replacing}) {
    if (replacing != null) {
      final i = tasks.indexWhere((t) => t.id == replacing.id);
      if (i != -1) {
        tasks[i] = task;
        _changed(dismissIds: [task.id]);
        return;
      }
    }
    tasks.add(task);
    _changed();
  }

  void deleteTask(Task task) {
    tasks.removeWhere((t) => t.id == task.id);
    _changed(dismissIds: [task.id]);
  }

  /// Pushes a due [task] back by [defaultSnooze] and re-arms its alarm.
  void snoozeTask(Task task) {
    final live = _find(task.id);
    if (live == null) return;
    final next = DateTime.now().add(defaultSnooze);
    live.date = DateTime(next.year, next.month, next.day);
    live.time = TimeOfDay(hour: next.hour, minute: next.minute);
    _changed(dismissIds: [live.id]);
  }

  /// Moves [task] off the Home list and onto the Completed list.
  void completeTask(Task task) {
    final live = _find(task.id);
    if (live == null) return;
    tasks.removeWhere((t) => t.id == live.id);
    completed.insert(0, CompletedTask(title: live.title, date: DateTime.now()));
    _changed(dismissIds: [live.id]);
  }

  void clearHistory() {
    completed.clear();
    _changed();
  }
}
