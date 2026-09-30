import 'package:flutter/material.dart';

import '../../core/theme/cl_colors.dart';
import '../../core/theme/cl_radius.dart';
import '../../core/theme/cl_spacing.dart';
import '../../core/theme/cl_typography.dart';

/// Casa Lazzarini modal dialog.
///
/// Use the static [CLDialog.show] method rather than constructing this widget
/// directly.
///
/// ```dart
/// CLDialog.show(
///   context,
///   title: 'Confirm cancellation',
///   content: Text('This booking will be permanently cancelled.'),
///   actions: [
///     CLSecondaryButton(label: 'Keep booking', onPressed: () => Navigator.pop(context)),
///     CLPrimaryButton(label: 'Cancel booking', onPressed: _cancel),
///   ],
/// );
/// ```
abstract final class CLDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: CLColors.scrim,
      builder: (_) =>
          _CLDialogWidget(title: title, content: content, actions: actions),
    );
  }
}

class _CLDialogWidget extends StatelessWidget {
  const _CLDialogWidget({this.title, required this.content, this.actions});

  final String? title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CLColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: CLRadius.lgAll),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.xl,
        vertical: CLSpacing.xxl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CLSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: CLTypography.headline),
              const SizedBox(height: CLSpacing.md),
              const Divider(),
              const SizedBox(height: CLSpacing.md),
            ],
            DefaultTextStyle(style: CLTypography.body, child: content),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: CLSpacing.xl),
              ...actions!.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(top: CLSpacing.sm),
                  child: action,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
