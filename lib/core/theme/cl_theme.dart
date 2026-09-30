import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cl_colors.dart';
import 'cl_radius.dart';
import 'cl_spacing.dart';
import 'cl_typography.dart';

/// Casa Lazzarini theme.
///
/// Use [CLTheme.light] as the [MaterialApp.theme].
abstract final class CLTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: CLColors.primary,
      onPrimary: CLColors.textOnPrimary,
      primaryContainer: CLColors.primaryVariant,
      onPrimaryContainer: CLColors.textOnPrimary,
      secondary: CLColors.olive,
      onSecondary: CLColors.textOnPrimary,
      secondaryContainer: CLColors.surfaceElevated,
      onSecondaryContainer: CLColors.textPrimary,
      tertiary: CLColors.terracotta,
      onTertiary: CLColors.textOnPrimary,
      error: CLColors.destructive,
      onError: CLColors.textOnPrimary,
      errorContainer: CLColors.destructiveContainer,
      onErrorContainer: CLColors.destructive,
      surface: CLColors.surface,
      onSurface: CLColors.textPrimary,
      onSurfaceVariant: CLColors.textSecondary,
      outline: CLColors.divider,
      outlineVariant: CLColors.inputFill,
      shadow: Colors.black12,
      scrim: CLColors.scrim,
      inverseSurface: CLColors.primary,
      onInverseSurface: CLColors.textOnPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CLColors.background,

      // ── Typography ──────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: CLTypography.displayLarge,
        displayMedium: CLTypography.displayMedium,
        displaySmall: CLTypography.displaySmall,
        headlineLarge: CLTypography.headline,
        headlineMedium: CLTypography.headline,
        headlineSmall: CLTypography.title,
        titleLarge: CLTypography.title,
        titleMedium: CLTypography.label,
        titleSmall: CLTypography.label,
        bodyLarge: CLTypography.bodyLarge,
        bodyMedium: CLTypography.body,
        bodySmall: CLTypography.caption,
        labelLarge: CLTypography.label,
        labelMedium: CLTypography.caption,
        labelSmall: CLTypography.eyebrow,
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: CLColors.background,
        foregroundColor: CLColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: CLTypography.headline,
        iconTheme: const IconThemeData(color: CLColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: CLColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // ── Buttons ─────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CLColors.primary,
          foregroundColor: CLColors.textOnPrimary,
          disabledBackgroundColor: CLColors.primary.withValues(alpha: 0.38),
          disabledForegroundColor: CLColors.textOnPrimary.withValues(
            alpha: 0.6,
          ),
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: CLSpacing.xl,
            vertical: CLSpacing.base,
          ),
          shape: const RoundedRectangleBorder(borderRadius: CLRadius.mdAll),
          elevation: 0,
          textStyle: CLTypography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CLColors.primary,
          disabledForegroundColor: CLColors.textMuted,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: CLSpacing.xl,
            vertical: CLSpacing.base,
          ),
          shape: const RoundedRectangleBorder(borderRadius: CLRadius.mdAll),
          side: const BorderSide(color: CLColors.primary, width: 1.5),
          elevation: 0,
          textStyle: CLTypography.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CLColors.primary,
          textStyle: CLTypography.label,
          padding: const EdgeInsets.symmetric(
            horizontal: CLSpacing.md,
            vertical: CLSpacing.sm,
          ),
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: CLColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: const RoundedRectangleBorder(borderRadius: CLRadius.lgAll),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Input / Forms ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CLColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.base,
          vertical: CLSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: CLRadius.smAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CLRadius.smAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CLRadius.smAll,
          borderSide: const BorderSide(color: CLColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: CLRadius.smAll,
          borderSide: const BorderSide(color: CLColors.destructive, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: CLRadius.smAll,
          borderSide: const BorderSide(color: CLColors.destructive, width: 1.5),
        ),
        hintStyle: CLTypography.body.copyWith(color: CLColors.textMuted),
        labelStyle: CLTypography.label.copyWith(color: CLColors.textSecondary),
        errorStyle: CLTypography.caption.copyWith(color: CLColors.destructive),
        floatingLabelStyle: CLTypography.caption.copyWith(
          color: CLColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Dialogs ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: CLColors.surface,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        shape: const RoundedRectangleBorder(borderRadius: CLRadius.lgAll),
        titleTextStyle: CLTypography.headline,
        contentTextStyle: CLTypography.body,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.xl,
          vertical: CLSpacing.xxl,
        ),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CLColors.surface,
        modalBackgroundColor: CLColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: CLRadius.xlTop),
        showDragHandle: false,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: CLColors.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Chips ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: CLColors.inputFill,
        selectedColor: CLColors.olive.withValues(alpha: 0.12),
        labelStyle: CLTypography.caption,
        padding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.md,
          vertical: CLSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: CLRadius.smAll),
        side: BorderSide.none,
      ),

      // ── List Tile ────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.base,
          vertical: CLSpacing.xs,
        ),
        titleTextStyle: CLTypography.body,
        subtitleTextStyle: CLTypography.caption,
        iconColor: CLColors.textSecondary,
        shape: const RoundedRectangleBorder(borderRadius: CLRadius.smAll),
      ),

      // ── Navigation Bar — kept for Material fallback, CLBottomNavigation is custom ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CLColors.softWhite,
        indicatorColor: CLColors.olive.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CLTypography.caption.copyWith(
              color: CLColors.olive,
              fontWeight: FontWeight.w600,
            );
          }
          return CLTypography.caption.copyWith(color: CLColors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: CLColors.olive, size: 22);
          }
          return const IconThemeData(color: CLColors.textMuted, size: 22);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      // ── Snack Bar ────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CLColors.primary,
        contentTextStyle: CLTypography.body.copyWith(
          color: CLColors.textOnPrimary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: CLRadius.smAll),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: CLColors.textPrimary, size: 24),
    );
  }
}
