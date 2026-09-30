import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_motion.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_spacing.dart';
import '../../core/theme/cl_typography.dart';

/// Visual variant for [CLActionCard].
enum CLActionCardVariant {
  /// Olive background — primary CTA (e.g. "Prenota una suite").
  primary,

  /// Soft white background with hairline border — secondary CTA.
  secondary,
}

/// Large editorial CTA card with press-scale feedback.
///
/// Pass [onTap] = null to render a visually intact placeholder
/// (no opacity reduction — the card is coming soon, not disabled).
class CLActionCard extends StatefulWidget {
  const CLActionCard({
    super.key,
    required this.label,
    this.icon,
    this.variant = CLActionCardVariant.secondary,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final CLActionCardVariant variant;

  /// Null = placeholder behavior (Phase 2/3 not yet implemented).
  final VoidCallback? onTap;

  @override
  State<CLActionCard> createState() => _CLActionCardState();
}

class _CLActionCardState extends State<CLActionCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == CLActionCardVariant.primary;
    final hasAction = widget.onTap != null;

    final bgColor = isPrimary ? CLColors.olive : CLColors.surface;
    final textColor = isPrimary ? CLColors.ivory : CLColors.textPrimary;
    final iconColor = isPrimary
        ? CLColors.ivory.withValues(alpha: 0.75)
        : CLColors.textSecondary;
    final chevronColor = isPrimary
        ? CLColors.ivory.withValues(alpha: 0.55)
        : CLColors.textMuted;

    return GestureDetector(
      onTapDown: hasAction ? _onTapDown : null,
      onTapUp: hasAction ? _onTapUp : null,
      onTapCancel: hasAction ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: CLMotion.durationFast,
        curve: CLMotion.curveDefault,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CLSpacing.xl,
            vertical: CLSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: CLRadius.lgAll,
            border: isPrimary
                ? null
                : Border.all(color: CLColors.divider, width: 0.5),
            boxShadow: isPrimary
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x09000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon!, size: 20, color: iconColor),
                const SizedBox(width: CLSpacing.md),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: CLTypography.label.copyWith(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}
