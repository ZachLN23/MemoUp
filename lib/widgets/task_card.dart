import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme.dart';

/// A single row on the Home task list.
///
/// Filled with [kPrimary] when [isUrgent] is true (due today / urgent),
/// filled with [kSurface] otherwise (upcoming). Takes data and a
/// callback only — no internal state.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.isUrgent,
    required this.onEdit,
  });

  final String title;
  final bool isUrgent;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final Color fill = isUrgent ? kPrimary : kSurface;
    final Color onFill = isUrgent ? kOnPrimary : kOnSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingStandard),
      padding: const EdgeInsets.symmetric(
        horizontal: kScreenPadding,
        vertical: kSpacingStandard,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: onFill),
            ),
          ),
          const SizedBox(width: kSpacingTight),
          IconButton(
            icon: Icon(Icons.edit, color: onFill, size: 18),
            onPressed: onEdit,
            splashRadius: 18,
            tooltip: 'Edit task',
          ),
        ],
      ),
    );
  }
}
