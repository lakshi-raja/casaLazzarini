import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_spacing.dart';

/// A Casa Lazzarini surface card.
///
/// Wraps [child] in a rounded white container with a very subtle elevation.
/// Provide [onTap] to make the card interactive with an ink ripple.
class CLCard extends StatelessWidget {
  const CLCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(CLSpacing.base),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Defaults to [CLColors.surface]. Use [CLColors.surfaceElevated] for
  /// layered cards (e.g. a card inside another card).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? CLColors.surface;

    final container = Container(
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: CLRadius.lgAll,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: CLRadius.lgAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: CLRadius.lgAll,
        child: container,
      ),
    );
  }
}
