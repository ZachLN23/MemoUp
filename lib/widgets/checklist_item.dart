import 'package:flutter/material.dart';

import '../constants/spacing.dart';

/// Checkbox + label row.
///
/// Used for Task Detail (subtasks), Notification Settings (alert
/// types), and Sound Settings (sound options). Takes data and a
/// callback only — the parent list owns the checked state.
class ChecklistItem extends StatelessWidget {
  const ChecklistItem({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTight / 2),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
          ),
          const SizedBox(width: kSpacingTight),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
