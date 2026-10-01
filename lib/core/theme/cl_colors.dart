import 'package:flutter/material.dart';

/// Casa Lazzarini color tokens.
///
/// Palette direction: Editorial Luxury — ivory backgrounds, warm charcoal,
/// olive accents, terracotta warmth. Nothing saturated or Material-default.
abstract final class CLColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Main scaffold background — warm ivory.
  static const Color background = Color(0xFFF7F3ED);

  /// Default surface (cards, sheets) — soft white with warm undertone.
  static const Color surface = Color(0xFFFFFDFC);

  /// Slightly elevated surface — a hair warmer than surface for layering.
  static const Color surfaceElevated = Color(0xFFF0EBE3);

  // ── Brand Palette ─────────────────────────────────────────────────────────
  /// Ivory — primary background tone.
  static const Color ivory = Color(0xFFF7F3ED);

  /// Soft White — surface tone.
  static const Color softWhite = Color(0xFFFFFDFC);

  /// Charcoal — deep warm near-black, primary anchor.
  static const Color charcoal = Color(0xFF1B1917);

  /// Warm Sand — warm mid-tone accent, decorative use.
  static const Color warmSand = Color(0xFFD8CBBE);

  /// Olive — primary CTA, selected states, active accents.
  static const Color olive = Color(0xFF6E7564);

  /// Terracotta — warm highlight, availability indicator.
  static const Color terracotta = Color(0xFFA7654A);

  // ── Primary ───────────────────────────────────────────────────────────────
  /// Deep warm charcoal — anchors the palette.
  static const Color primary = Color(0xFF1B1917);

  /// Lighter variant for pressed/focus states on primary.
  static const Color primaryVariant = Color(0xFF3D3835);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Near-black with a warm brown undertone.
  static const Color textPrimary = Color(0xFF1A1614);

  /// Mid-grey with warmth — secondary labels, meta text.
  static const Color textSecondary = Color(0xFF6B6560);

  /// Light warm grey — placeholders, muted captions.
  static const Color textMuted = Color(0xFFA49C95);

  /// Text on primary/dark backgrounds — white.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Ivory text on dark hero/charcoal backgrounds.
  static const Color textOnDark = Color(0xFFF7F3ED);

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
  static const Color divider = Color(0xFFE5DDD5);

  /// Subtle warm grey — input fills, surface overlays.
  static const Color inputFill = Color(0xFFEFE9E1);

  /// Scrim for dialogs and bottom sheets.
  static const Color scrim = Color(0x80000000);
}
