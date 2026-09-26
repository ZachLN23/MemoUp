import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme.dart';

/// Rounded pill field with a small label above it and a chevron on the
/// right. Used for Task Detail's Date/Time pickers and Sound
/// Settings' Default Snooze Time.
///
/// This is a display shell only — wire [onTap] to whatever picker
/// (showDatePicker, a bottom sheet, etc.) actually sets [value].
class DropdownField extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.leadingIcon,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 14, color: kPrimary),
              const SizedBox(width: 4),
            ],
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: kSpacingTight / 2),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingStandard,
              vertical: kSpacingTight + 4,
            ),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
                const Icon(Icons.arrow_drop_down, color: kOnSurface),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
