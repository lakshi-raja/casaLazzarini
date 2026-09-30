import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_typography.dart';

/// Full-width outlined secondary button.
///
/// Mirrors [CLPrimaryButton] dimensions with a transparent fill and
/// a [CLColors.primary] border.
class CLSecondaryButton extends StatelessWidget {
  const CLSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedOpacity(
        opacity: isDisabled && !isLoading ? 0.46 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: CLColors.primary,
            disabledForegroundColor: CLColors.primary,
            side: const BorderSide(color: CLColors.primary, width: 1.5),
            shape: const RoundedRectangleBorder(borderRadius: CLRadius.mdAll),
            padding: EdgeInsets.zero,
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(CLColors.primary),
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: CLTypography.label.copyWith(color: CLColors.primary),
                ),
        ),
      ),
    );
  }
}
