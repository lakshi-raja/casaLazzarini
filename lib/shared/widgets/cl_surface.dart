import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_radius.dart';

/// A plain Casa Lazzarini surface container.
///
/// Applies the brand surface treatment (color, rounding) without any
/// tap handling or elevation. Use [CLCard] when elevation or tap is needed.
class CLSurface extends StatelessWidget {
  const CLSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  /// Defaults to [CLColors.surface].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? CLColors.surface,
        borderRadius: borderRadius ?? CLRadius.lgAll,
      ),
      child: content,
    );
  }
}
