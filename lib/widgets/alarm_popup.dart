import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme.dart';
import 'primary_button.dart';

/// Centered alarm/notification card: bold title, dashed subtitle, and
/// two side-by-side buttons (Snooze / Mark as Done).
class AlarmPopup extends StatelessWidget {
  const AlarmPopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSnooze,
    required this.onDone,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSnooze;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kScreenPadding),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kSpacingTight),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                ),
          ),
          const SizedBox(height: kSpacingStandard),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSnooze,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: const BorderSide(color: kPrimary),
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Snooze'),
                ),
              ),
              const SizedBox(width: kSpacingTight),
              Expanded(
                child: PrimaryButton(label: 'Mark as Done', onPressed: onDone),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
