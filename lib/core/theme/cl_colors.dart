import 'package:flutter/material.dart';

/// Casa Lazzarini color tokens.
///
/// Palette direction: warm ivory backgrounds, deep warm charcoal primary,
/// muted sage/amber/terracotta for availability states — nothing saturated.
abstract final class CLColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Main scaffold background — warm ivory.
  static const Color background = Color(0xFFFAF8F5);

  /// Default surface (cards, sheets) — pure white with warm undertone.
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly elevated surface — a hair warmer than surface for layering.
  static const Color surfaceElevated = Color(0xFFF5F2EE);

  // ── Primary ───────────────────────────────────────────────────────────────
  /// Deep warm charcoal — anchors the palette, reads as near-black with
  /// warmth rather than cold grey.
  static const Color primary = Color(0xFF1C1917);

  /// Lighter variant for pressed/focus states on primary.
  static const Color primaryVariant = Color(0xFF3D3835);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Near-black with a warm brown undertone.
  static const Color textPrimary = Color(0xFF1A1614);

  /// Mid-grey with warmth — secondary labels, meta text.
  static const Color textSecondary = Color(0xFF6B6560);

  /// Light warm grey — placeholders, muted captions.
  static const Color textMuted = Color(0xFF9B9490);

  /// Text on primary/dark backgrounds — always white.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Availability ─────────────────────────────────────────────────────────
  /// Desaturated sage green — available state.
  static const Color available = Color(0xFF4A7C59);

  /// Warm amber — partially available / pending state.
  static const Color partiallyAvailable = Color(0xFFC97B2B);

  /// Muted terracotta — unavailable / blocked state.
  static const Color unavailable = Color(0xFF9B4B3F);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Refined deep red — errors and destructive actions.
  static const Color destructive = Color(0xFFC0392B);

  /// Soft tint of destructive for error containers.
  static const Color destructiveContainer = Color(0xFFFAEDEB);

  // ── Chrome ───────────────────────────────────────────────────────────────
  /// Very light warm grey — dividers and hairline borders.
  static const Color divider = Color(0xFFE8E4E0);

  /// Subtle warm grey — input fills, surface overlays.
  static const Color inputFill = Color(0xFFF2EFE9);

  /// Scrim for dialogs and bottom sheets.
  static const Color scrim = Color(0x80000000);
}
