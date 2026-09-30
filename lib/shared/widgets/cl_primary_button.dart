import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_typography.dart';

/// Full-width primary action button.
///
/// Shows a loading indicator when [isLoading] is true and disables interaction.
/// Disabled when [onPressed] is null or [isLoading] is true.
class CLPrimaryButton extends StatelessWidget {
  const CLPrimaryButton({
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
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: CLColors.primary,
            foregroundColor: CLColors.textOnPrimary,
            disabledBackgroundColor: CLColors.primary,
            disabledForegroundColor: CLColors.textOnPrimary,
            shape: const RoundedRectangleBorder(borderRadius: CLRadius.mdAll),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CLColors.textOnPrimary,
                    ),
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: CLTypography.label.copyWith(
                    color: CLColors.textOnPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
