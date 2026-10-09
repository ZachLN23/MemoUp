import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app_data.dart';
import 'task.dart';

const String _channelVibrate = 'memoup_reminders_vibrate';
const String _channelQuiet = 'memoup_reminders_quiet';
const String _actionSnooze = 'snooze';
const String _actionDone = 'done';

/// Runs when the user taps Snooze / Mark as Done on a reminder while the
/// app is closed or in the background. It runs in its own isolate, so it
/// loads the saved data itself instead of sharing the running app's.
///
/// Must be a top-level function with this pragma, or release builds
/// strip it and the buttons silently do nothing.
@pragma('vm:entry-point')
Future<void> notificationActionBackground(NotificationResponse response) async {
  await NotificationService.handleAction(response);
}

/// Real, OS-level reminders: every task that has a date + time gets a
/// scheduled system notification, so it rings even when MemoUp is closed
/// (and survives a phone reboot).
///
/// Android only. On web there is no way to wake a closed page, so every
/// method here quietly does nothing there — the in-app popup still works
/// while the page is open.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// The running app's own data, set by main(). Null inside the
  /// background isolate, which is how [handleAction] knows which it's in.
  static AppData? liveData;

  /// Home sets this so it can refresh + show the popup when the user
  /// taps a notification or action while the app is open.
  static Future<void> Function()? onChangedExternally;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  static Future<void> init() async {
    if (!_supported || _ready) return;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: _onForegroundResponse,
        onDidReceiveBackgroundNotificationResponse:
            notificationActionBackground,
      );
      // A channel's sound/vibration can't change after it's created, so
      // there is one channel per vibrate setting.
      await _android?.createNotificationChannel(const AndroidNotificationChannel(
        _channelVibrate,
        'Reminders',
        description: 'Task reminders from MemoUp',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ));
      await _android?.createNotificationChannel(const AndroidNotificationChannel(
        _channelQuiet,
        'Reminders (no vibration)',
        description: 'Task reminders from MemoUp, without vibration',
        importance: Importance.max,
        enableVibration: false,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ));
      _ready = true;
    } catch (e) {
      debugPrint('MemoUp: notification setup failed: $e');
    }
  }

  /// Asks for the permissions a closed-app reminder needs. Safe to call
  /// repeatedly; Android only shows each prompt when it's still needed.
  static Future<void> requestPermissions() async {
    if (!_supported) return;
    await init();
    try {
      await _android?.requestNotificationsPermission();
      final canExact = await _android?.canScheduleExactNotifications() ?? true;
      if (!canExact) await _android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('MemoUp: permission request failed: $e');
    }
  }

  /// Makes the scheduled notifications match [data]: every future-due
  /// task gets (or keeps) exactly one, and alarms for tasks that were
  /// edited, deleted or switched off are removed. Notifications that have
  /// already fired are left alone so their buttons keep working.
  static Future<void> syncAll(AppData data) async {
    if (!_supported) return;
    await init();
    if (!_ready) return;
    try {
      final now = DateTime.now();
      final wanted = <int, Task>{};
      if (data.notificationsEnabled) {
        for (final task in data.tasks) {
          final due = task.dueAt;
          if (due != null && due.isAfter(now)) wanted[task.id] = task;
        }
      }

      for (final p in await _plugin.pendingNotificationRequests()) {
        if (!wanted.containsKey(p.id)) await _plugin.cancel(p.id);
      }

      final canExact = await _android?.canScheduleExactNotifications() ?? false;
      for (final task in wanted.values) {
        await _plugin.zonedSchedule(
          task.id,
          task.title,
          'Reminder from MemoUp',
          // An absolute instant, so the phone's time zone can't skew it.
          tz.TZDateTime.from(task.dueAt!, tz.UTC),
          _details(vibrate: data.vibrateOnReminder),
          androidScheduleMode: canExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: task.id.toString(),
        );
      }
    } catch (e) {
      debugPrint('MemoUp: could not schedule reminders: $e');
    }
  }

  /// Clears a task's pending alarm and any copy already in the shade.
  static Future<void> dismiss(int taskId) async {
    if (!_supported) return;
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancel(taskId);
    } catch (e) {
      debugPrint('MemoUp: could not dismiss notification: $e');
    }
  }

  static NotificationDetails _details({required bool vibrate}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        vibrate ? _channelVibrate : _channelQuiet,
        vibrate ? 'Reminders' : 'Reminders (no vibration)',
        channelDescription: 'Task reminders from MemoUp',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        // Pops over the screen / lock screen when the phone allows it.
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        actions: const [
          AndroidNotificationAction(
            _actionSnooze,
            'Snooze',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            _actionDone,
            'Mark as Done',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    );
  }

  /// Notification (or its buttons) tapped while the app was running.
  static Future<void> _onForegroundResponse(NotificationResponse r) async {
    await handleAction(r);
    await onChangedExternally?.call();
  }

  /// Applies Snooze / Mark as Done. A plain tap on the notification body
  /// does nothing here: it opens the app, and Home then shows the popup
  /// for whatever task is due.
  static Future<void> handleAction(NotificationResponse response) async {
    final action = response.actionId;
    if (action != _actionSnooze && action != _actionDone) return;
    final id = int.tryParse(response.payload ?? '');
    if (id == null) return;

    final data = liveData ?? await AppData.load();
    Task? task;
    for (final t in data.tasks) {
      if (t.id == id) task = t;
    }
    if (task == null) return;

    if (action == _actionSnooze) {
      data.snoozeTask(task);
    } else {
      data.completeTask(task);
    }
    await data.whenSaved(); // don't let the isolate die mid-save
  }
}
