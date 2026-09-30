import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_spacing.dart';
import '../../core/theme/cl_typography.dart';

/// Casa Lazzarini modal bottom sheet.
///
/// Use the static [CLBottomSheet.show] method.
///
/// ```dart
/// CLBottomSheet.show(
///   context,
///   title: 'Select a date',
///   child: DatePickerWidget(),
/// );
/// ```
abstract final class CLBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: CLColors.surface,
      barrierColor: CLColors.scrim,
      shape: const RoundedRectangleBorder(borderRadius: CLRadius.xlTop),
      clipBehavior: Clip.antiAlias,
      builder: (_) => _CLBottomSheetContent(title: title, child: child),
    );
  }
}

class _CLBottomSheetContent extends StatelessWidget {
  const _CLBottomSheetContent({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(
            top: CLSpacing.md,
            bottom: CLSpacing.sm,
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CLColors.divider,
                borderRadius: CLRadius.smAll,
              ),
            ),
          ),
        ),

        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CLSpacing.xl,
              CLSpacing.sm,
              CLSpacing.xl,
              CLSpacing.base,
            ),
            child: Text(title!, style: CLTypography.headline),
          ),

        child,

        // Safe area bottom inset
        SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ],
    );
  }
}
