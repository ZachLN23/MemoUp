import 'package:flutter/material.dart';

import '../theme.dart';

/// Circular back-arrow button, top-left on Task Detail, Notification
/// Settings, Sound Settings, and Completed.
///
/// Named [AppBackButton] to avoid clashing with Flutter's built-in
/// [BackButton].
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: kSurface,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: kOnSurface, size: 18),
        onPressed: onPressed,
        splashRadius: 18,
        tooltip: 'Back',
      ),
    );
  }
}
