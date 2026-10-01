import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_motion.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_spacing.dart';
import '../../core/theme/cl_typography.dart';

/// Editorial suite preview card.
///
/// Shows a left-side image slot and suite name. When [imageProvider] is null
/// renders a warm sand placeholder — replace with a real asset when available.
///
/// Metadata intentionally omitted: no invented dimensions, guests, or amenities.
class CLSuitePreviewCard extends StatefulWidget {
  const CLSuitePreviewCard({
    super.key,
    required this.name,
    this.imageProvider,
    this.onTap,
  });

  final String name;

  /// Optional real image. Null = warm placeholder (replace later).
  final ImageProvider? imageProvider;

  /// Null = no tap behavior (Phase 2 placeholder).
  final VoidCallback? onTap;

  @override
  State<CLSuitePreviewCard> createState() => _CLSuitePreviewCardState();
}

class _CLSuitePreviewCardState extends State<CLSuitePreviewCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null;

    return GestureDetector(
      onTapDown: hasAction ? (_) => setState(() => _pressed = true) : null,
      onTapUp: hasAction ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: hasAction ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: CLMotion.durationFast,
        curve: CLMotion.curveDefault,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: CLColors.surface,
            borderRadius: CLRadius.lgAll,
            border: Border.all(color: CLColors.divider, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image slot
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: CLRadius.lg,
                  bottomLeft: CLRadius.lg,
                ),
                child: SizedBox(
                  width: 88,
                  height: 96,
                  child: widget.imageProvider != null
                      ? Image(image: widget.imageProvider!, fit: BoxFit.cover)
                      : const _ImagePlaceholder(),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CLSpacing.base,
                    vertical: CLSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name,
                        style: CLTypography.label.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dettagli disponibili a breve',
                        style: CLTypography.caption,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: CLSpacing.base),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: CLColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CLColors.warmSand.withValues(alpha: 0.28),
      child: const Center(
        child: Icon(Icons.bed_outlined, size: 22, color: CLColors.warmSand),
      ),
    );
  }
}
