import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import 'app_data.dart';
import 'completed_screen.dart';
import 'constants/spacing.dart';
import 'sound_settings_screen.dart';
import 'task.dart';
import 'task_detail_screen.dart';
import 'widgets/alarm_popup.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/primary_button.dart';
import 'widgets/task_card.dart';

/// The Home screen: "Today's Reminders" and "Upcoming" task lists,
/// a full-width "+" button to add a task, and the bottom nav bar.
///
/// Reads and writes [appData] directly rather than holding its own
/// list — Task Detail and Completed do the same, so all three stay
/// in sync without any state-management package.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appData});

  final AppData appData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _alarmTimer;
  bool _showingAlarm = false;

  @override
  void initState() {
    super.initState();
    // Check once as soon as Home is visible, then keep checking while
    // it's open — this is what stands in for a real OS-level alarm.
    // Nothing fires while the app is closed; see the note in
    // _checkForDueTask below.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForDueTask());
    _alarmTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkForDueTask(),
    );
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  /// Looks for the first task whose date+time has already arrived and
  /// pops the Alarm Popup for it.
  ///
  /// This only runs while Home is on screen and the app is in the
  /// foreground — it is not a real OS notification/alarm (that needs a
  /// package like flutter_local_notifications plus Android/iOS
  /// permission setup, which this project doesn't have yet). Treat this
  /// as the in-app stand-in for that, not the real thing.
  void _checkForDueTask() {
    if (_showingAlarm || !widget.appData.notificationsEnabled) return;
    final now = DateTime.now();
    for (final task in widget.appData.tasks) {
      final date = task.date;
      final time = task.time;
      if (date == null || time == null) continue;
      final due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
            setState(() {
              final snoozed = DateTime.now().add(widget.appData.defaultSnooze);
              task.date = snoozed;
              task.time = TimeOfDay.fromDateTime(snoozed);
            });
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
    setState(() {}); // appData was mutated in place — just re-render.
  }

  Future<void> _openCompleted() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompletedScreen(appData: widget.appData),
      ),
    );
    setState(() {});
  }

  Future<void> _openSoundSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SoundSettingsScreen(appData: widget.appData),
      ),
    );
    setState(() {});
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
