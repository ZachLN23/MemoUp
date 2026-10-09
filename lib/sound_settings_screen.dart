import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'completed_screen.dart';
import 'constants/spacing.dart';
import 'notification_settings_screen.dart';
import 'theme.dart';
import 'widgets/back_button.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/checklist_item.dart';
import 'widgets/dropdown_field.dart';
import 'widgets/primary_button.dart';


class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key, required this.appData});

  final AppData appData;

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  static const List<Duration> _snoozeChoices = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
  ];

  String _formatSnooze(Duration d) => '${d.inMinutes} minutes';

  Future<void> _pickSnooze() async {
    final choice = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in _snoozeChoices)
              ListTile(
                title: Text(
                  _formatSnooze(d),
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                trailing: d == widget.appData.defaultSnooze
                    ? const Icon(Icons.check, color: kPrimary)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(d),
              ),
          ],
        ),
      ),
    );
    if (choice != null) {
      setState(() => widget.appData.setDefaultSnooze(choice));
    }
  }

  Future<void> _uploadAudio() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    if (result == null || result.files.isEmpty) return; 

    final fileName = result.files.first.name;
    setState(() => widget.appData.addCustomSound(fileName));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "$fileName"')),
    );
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompletedScreen(appData: widget.appData),
        ),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final appData = widget.appData;

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
                  Expanded(
                    child: Text('Sound Settings', style: textTheme.headlineSmall),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: kOnSurface),
                    tooltip: 'Notification Settings',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            NotificationSettingsScreen(appData: appData),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingStandard),
              Expanded(
                child: ListView(
                  children: [
                    Text('Reminder Option', style: textTheme.headlineSmall),
                    const SizedBox(height: kSpacingTight),
                    DropdownField(
                      label: 'Default Snooze Time',
                      leadingIcon: Icons.snooze,
                      value: _formatSnooze(appData.defaultSnooze),
                      onTap: _pickSnooze,
                    ),
                    const SizedBox(height: kSpacingStandard),
                    Text('Default Sounds', style: textTheme.headlineSmall),
                    const SizedBox(height: kSpacingTight),
                    for (final sound in appData.soundOptions)
                      ChecklistItem(
                        label: sound,
                        value: sound == appData.selectedSound,
                        onChanged: (_) =>
                            setState(() => appData.selectSound(sound)),
                      ),
                    const SizedBox(height: kSpacingStandard),
                    PrimaryButton(
                      label: 'Upload New Audio',
                      icon: Icons.upload_file,
                      onPressed: _uploadAudio,
                    ),
                    const SizedBox(height: kSpacingStandard),
                  ],
                ),
              ),
              BottomNavBar(currentIndex: 2, onTap: _handleNavTap),
              const SizedBox(height: kSpacingTight),
            ],
          ),
        ),
      ),
    );
  }
}
