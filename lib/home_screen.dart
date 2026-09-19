import 'package:flutter/material.dart';

import 'constants/spacing.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/primary_button.dart';
import 'widgets/task_card.dart';

/// A task on the home list. Kept minimal for now — Task Detail (the
/// next screen) will likely want more fields (date, time, subtasks).
class Task {
  Task({required this.title, required this.isUrgent});

  final String title;
  final bool isUrgent;
}

/// The Home screen: "Today's Reminders" and "Upcoming" task lists,
/// a full-width "+" button to add a task, and the bottom nav bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // Placeholder data until Task Detail exists to create real tasks.
  final List<Task> _todaysReminders = [
    Task(title: '8:00 AM  Submit Assignment', isUrgent: true),
    Task(title: '2:00 PM  Team Meeting', isUrgent: true),
  ];

  final List<Task> _upcoming = [
    Task(title: 'Doctor Appointment', isUrgent: false),
    Task(title: 'Pay Electricity Bill', isUrgent: false),
  ];

  void _onEditTask(Task task) {
    // Wire this to Task Detail once that screen exists.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit "${task.title}" — Task Detail not wired yet')),
    );
  }

  void _onAddTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add task — Task Detail not wired yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    for (final task in _todaysReminders)
                      TaskCard(
                        title: task.title,
                        isUrgent: task.isUrgent,
                        onEdit: () => _onEditTask(task),
                      ),
                    const SizedBox(height: kSpacingStandard),
                    Text('Upcoming', style: textTheme.headlineSmall),
                    const SizedBox(height: kSpacingTight),
                    for (final task in _upcoming)
                      TaskCard(
                        title: task.title,
                        isUrgent: task.isUrgent,
                        onEdit: () => _onEditTask(task),
                      ),
                  ],
                ),
              ),
              PrimaryButton(label: '', icon: Icons.add, onPressed: _onAddTask),
              const SizedBox(height: kSpacingStandard),
              BottomNavBar(
                currentIndex: _navIndex,
                onTap: (i) => setState(() => _navIndex = i),
              ),
              const SizedBox(height: kSpacingTight),
            ],
          ),
        ),
      ),
    );
  }
}
