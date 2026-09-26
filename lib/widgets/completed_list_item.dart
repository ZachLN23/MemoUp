import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme.dart';

/// A single row on the Completed screen — checkmark, a dashed
/// strikethrough label, and the completion date.
class CompletedListItem extends StatelessWidget {
  const CompletedListItem({
    super.key,
    required this.label,
    required this.date,
  });

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingStandard),
      padding: const EdgeInsets.symmetric(
        horizontal: kScreenPadding,
        vertical: kSpacingStandard,
      ),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.check, color: kPrimary, size: 18),
          const SizedBox(width: kSpacingTight),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kMuted,
                    decoration: TextDecoration.lineThrough,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
            ),
          ),
          Text(date, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
