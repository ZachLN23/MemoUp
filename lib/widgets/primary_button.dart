import 'package:flutter/material.dart';

/// Full-width rounded pill button.
///
/// Used for Home (+ Add — icon only, empty [label]), Task Detail
/// (Save), Notification Settings (Save), and Sound Settings (Upload
/// New Audio) — same widget, only the label/icon change.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool iconOnly = label.isEmpty && icon != null;

    Widget child;
    if (iconOnly) {
      child = Icon(icon, size: 22);
    } else if (icon == null) {
      child = Text(label, style: const TextStyle(fontWeight: FontWeight.bold));
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
