import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import 'app_data.dart';
import 'completed_screen.dart';
import 'constants/spacing.dart';
import 'notification_service.dart';
import 'sound_settings_screen.dart';
import 'task.dart';
import 'task_detail_screen.dart';
import 'widgets/alarm_popup.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/primary_button.dart';
import 'widgets/task_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appData});

  final AppData appData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _dueTimer;
  bool _showingAlarm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.onChangedExternally = _reloadAndCheck;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.requestPermissions();
      _refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.onChangedExternally = null;
    _dueTimer?.cancel();
    super.dispose();
  }

  /// Coming back to the app (e.g. after tapping a reminder, or after the
  /// notification's Snooze/Done buttons changed the saved data): re-read
  /// the data and pop the alarm for anything that came due meanwhile.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reloadAndCheck();
  }

  Future<void> _reloadAndCheck() async {
    if (_showingAlarm) return;
    await widget.appData.reload();
    if (!mounted) return;
    _refresh();
  }

  /// Re-render, re-arm the timer, and pop the alarm if something is due.
  void _refresh() {
    setState(() {});
    _armTimer();
    _checkForDueTask();
  }

  /// The soonest due time that is still in the future, if any.
  DateTime? _nextDueTime() {
    final now = DateTime.now();
    DateTime? best;
    for (final task in widget.appData.tasks) {
      final due = task.dueAt;
      if (due == null || !due.isAfter(now)) continue;
      if (best == null || due.isBefore(best)) best = due;
    }
    return best;
  }

  /// Sleeps until the next task is due, then checks — no polling, so the
  /// popup appears the moment a reminder's time arrives. (Capped at an
  /// hour and re-armed, so a very distant task can't overflow a timer.)
  void _armTimer() {
    _dueTimer?.cancel();
    if (!widget.appData.notificationsEnabled) return;
    final next = _nextDueTime();
    if (next == null) return;
    var wait = next.difference(DateTime.now());
    if (wait > const Duration(hours: 1)) wait = const Duration(hours: 1);
    _dueTimer = Timer(wait + const Duration(milliseconds: 250), () {
      _checkForDueTask();
      _armTimer();
    });
  }

  /// Looks for the first task whose date+time has already arrived and
  /// pops the Alarm Popup for it.
  ///
  /// This is the in-app half of a reminder. The other half is the real
  /// system notification scheduled by NotificationService, which is what
  /// rings when the app is closed; tapping it opens the app, and this
  /// check then shows the popup.
  void _checkForDueTask() {
    if (_showingAlarm || !widget.appData.notificationsEnabled) return;
    final now = DateTime.now();
    for (final task in widget.appData.tasks) {
      final due = task.dueAt;
      if (due == null) continue;
      if (!due.isAfter(now)) {
        _showAlarm(task);
        return; // one at a time — the next check picks up any others.
      }
    }
  }

  Future<void> _showAlarm(Task task) async {
    _showingAlarm = true;
    if (widget.appData.vibrateOnReminder) {
      HapticFeedback.vibrate();
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Snooze or Mark as Done — not tap-away.
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AlarmPopup(
          title: task.title,
          subtitle: task.time!.format(dialogContext),
          onSnooze: () {
            setState(() => widget.appData.snoozeTask(task));
            Navigator.of(dialogContext).pop();
          },
          onDone: () {
            setState(() => widget.appData.completeTask(task));
            Navigator.of(dialogContext).pop();
          },
        ),
      ),
    );

    _showingAlarm = false;
    if (!mounted) return;
    _armTimer();
    _checkForDueTask(); // chain straight into any other overdue task
  }

  Future<void> _openTaskDetail({Task? task}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          appData: widget.appData,
          initialTask: task,
        ),
      ),
    );
    if (mounted) _refresh(); // appData was mutated in place — re-render + re-arm.
  }

  Future<void> _openCompleted() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompletedScreen(appData: widget.appData),
      ),
    );
    if (mounted) _refresh();
  }

  Future<void> _openSoundSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SoundSettingsScreen(appData: widget.appData),
      ),
    );
    if (mounted) _refresh();
  }

  void _handleNavTap(int index) {
    if (index == 1) {
      _openCompleted();
    } else if (index == 2) {
      _openSoundSettings();
    }
    // index == 0 (Home) — already here.
  }

  String _cardTitle(Task task) {
    if (task.time != null) {
      return '${task.time!.format(context)}  ${task.title}';
    }
    return task.title;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tasks = widget.appData.tasks;
    final todays = tasks.where((t) => t.isToday).toList();
    final upcoming = tasks.where((t) => !t.isToday).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kSpacingStandard),
              Text('MemoUp', style: textTheme.headlineSmall),
              const SizedBox(height: kSpacingStandard),
              Expanded(
                child: ListView(
                  children: [
                    Text("Today's Reminders", style: textTheme.headlineSmall),
                    const SizedBox(height: kSpacingTight),
                    if (todays.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: kSpacingStandard),
                        child: Text('Nothing due today', style: textTheme.labelSmall),
                      ),
                    for (final task in todays)
                      TaskCard(
                        title: _cardTitle(task),
                        isUrgent: true,
                        onEdit: () => _openTaskDetail(task: task),
                      ),
                    const SizedBox(height: kSpacingStandard),
                    Text('Upcoming', style: textTheme.headlineSmall),
                    const SizedBox(height: kSpacingTight),
                    if (upcoming.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: kSpacingStandard),
                        child: Text('Nothing upcoming', style: textTheme.labelSmall),
                      ),
                    for (final task in upcoming)
                      TaskCard(
                        title: _cardTitle(task),
                        isUrgent: false,
                        onEdit: () => _openTaskDetail(task: task),
                      ),
                  ],
                ),
              ),
              PrimaryButton(label: '', icon: Icons.add, onPressed: () => _openTaskDetail()),
              const SizedBox(height: kSpacingStandard),
              BottomNavBar(
                currentIndex: 0,
                onTap: _handleNavTap,
              ),
              const SizedBox(height: kSpacingTight),
            ],
          ),
        ),
      ),
    );
  }
}
