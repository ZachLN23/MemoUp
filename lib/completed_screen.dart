import 'package:flutter/material.dart';

import 'app_data.dart';
import 'constants/spacing.dart';
import 'sound_settings_screen.dart';
import 'widgets/back_button.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/completed_list_item.dart';
import 'widgets/primary_button.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key, required this.appData});

  final AppData appData;

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  void _clearHistory() {
    setState(() => widget.appData.clearHistory());
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SoundSettingsScreen(appData: widget.appData),
        ),
      );
    }
    // index == 1 (Completed) — already here.
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completed = widget.appData.completed;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kSpacingStandard),
              Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: kSpacingStandard),
                  Text('Completed', style: textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: kSpacingStandard),
              Expanded(
                child: completed.isEmpty
                    ? Center(
                        child: Text(
                          'Nothing completed yet',
                          style: textTheme.labelSmall,
                        ),
                      )
                    : ListView(
                        children: [
                          for (final item in completed)
                            CompletedListItem(
                              label: item.title,
                              date: _formatDate(item.date),
                            ),
                        ],
                      ),
              ),
              if (completed.isNotEmpty) ...[
                PrimaryButton(label: 'Clear History', onPressed: _clearHistory),
                const SizedBox(height: kSpacingStandard),
              ],
              BottomNavBar(currentIndex: 1, onTap: _handleNavTap),
              const SizedBox(height: kSpacingTight),
            ],
          ),
        ),
      ),
    );
  }
}
