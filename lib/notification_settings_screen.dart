import 'package:flutter/material.dart';

import 'app_data.dart';
import 'constants/spacing.dart';
import 'widgets/back_button.dart';
import 'widgets/checklist_item.dart';
import 'widgets/primary_button.dart';


class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key, required this.appData});

  final AppData appData;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool _enabled;
  late bool _vibrate;

  @override
  void initState() {
    super.initState();
    _enabled = widget.appData.notificationsEnabled;
    _vibrate = widget.appData.vibrateOnReminder;
  }

  void _save() {
    widget.appData.updateNotificationSettings(
      enabled: _enabled,
      vibrate: _vibrate,
    );
    Navigator.of(context).pop();
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
              Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: kSpacingStandard),
                  Text('Notification Settings', style: textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: kSpacingStandard),
              Expanded(
                child: ListView(
                  children: [
                    ChecklistItem(
                      label: 'Enable Notifications',
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                    ChecklistItem(
                      label: 'Vibrate on Reminder',
                      value: _vibrate,
                      onChanged: (v) => setState(() => _vibrate = v),
                    ),
                    const SizedBox(height: kSpacingTight),
                    if (!_enabled)
                      Text(
                        "While this is off, reminders won't ring or pop up at all.",
                        style: textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
              PrimaryButton(label: 'Save', onPressed: _save),
              const SizedBox(height: kSpacingStandard),
            ],
          ),
        ),
      ),
    );
  }
}
