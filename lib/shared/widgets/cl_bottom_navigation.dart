import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_typography.dart';

/// Minimal editorial bottom navigation bar.
///
/// Fully custom — does not use Material [NavigationBar] to avoid the
/// standard gestional look. Selected state uses olive; unselected uses muted.
///
/// Items: Home (0), Prenota (1), Profilo (2).
/// Items 1 and 2 are Phase 2/3 placeholders — [onTap] is null until implemented.
class CLBottomNavigation extends StatelessWidget {
  const CLBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: CLColors.softWhite,
        border: Border(top: BorderSide(color: CLColors.divider, width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'Prenota',
                isSelected: currentIndex == 1,
                onTap: null, // Phase 2
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profilo',
                isSelected: currentIndex == 2,
                onTap: null, // Phase 3
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? CLColors.olive : CLColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: CLTypography.eyebrow.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
