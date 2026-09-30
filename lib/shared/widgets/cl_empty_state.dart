import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_spacing.dart';
import '../../core/theme/cl_typography.dart';

/// A tasteful empty state for lists and screens with no content.
///
/// All parameters are optional. At minimum provide [message].
///
/// ```dart
/// CLEmptyState(
///   icon: Icons.calendar_today_outlined,
///   message: 'No bookings yet',
///   action: CLPrimaryButton(
///     label: 'Make a booking',
///     onPressed: _openBookingFlow,
///   ),
/// )
/// ```
class CLEmptyState extends StatelessWidget {
  const CLEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.action,
  });

  final String message;
  final IconData? icon;

  /// Optional action widget — typically a [CLPrimaryButton] or [CLSecondaryButton].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CLSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48, color: CLColors.textMuted),
              const SizedBox(height: CLSpacing.base),
            ],
            Text(
              message,
              style: CLTypography.body.copyWith(color: CLColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: CLSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
