import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_typography.dart';

/// Editorial section header with an optional right-aligned action label.
///
/// Title uses [CLTypography.displaySmall] (Playfair Display 22sp) for strong
/// visual hierarchy. The action label is secondary — null hides it entirely.
class CLSectionHeader extends StatelessWidget {
  const CLSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Optional right-aligned label (e.g. "Vedi calendario").
  final String? actionLabel;

  /// Null = label is shown but not tappable (Phase 2/3 placeholder).
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: CLTypography.displaySmall)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: CLTypography.caption.copyWith(
                color: onAction != null ? CLColors.olive : CLColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
