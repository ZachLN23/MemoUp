import 'package:flutter/material.dart';

import '../constants/spacing.dart';
import '../theme.dart';

/// Home / Completed / Settings navigation bar. Appears on every main
/// screen with the same three icons, only [currentIndex] changes.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<IconData> _icons = [
    Icons.home,
    Icons.check,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: kSpacingTight),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (i) {
          final bool active = i == currentIndex;
          return InkResponse(
            onTap: () => onTap(i),
            radius: 24,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: active ? kPrimary : Colors.transparent,
              child: Icon(
                _icons[i],
                color: active ? kOnPrimary : kOnSurface,
                size: 18,
              ),
            ),
          );
        }),
      ),
    );
  }
}
