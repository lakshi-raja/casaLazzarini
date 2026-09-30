import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cl_colors.dart';

/// Casa Lazzarini typography tokens.
///
/// Playfair Display — editorial display headings only (sparingly).
/// Inter — all functional UI: buttons, labels, body, navigation.
abstract final class CLTypography {
  // ── Display — Playfair Display ────────────────────────────────────────────

  /// Hero headings — section titles, feature copy. 40sp, w600.
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: CLColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// Secondary display — modal titles, page headers. 32sp, w600.
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: CLColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  // ── Functional — Inter ────────────────────────────────────────────────────

  /// Screen headings, prominent section labels. 24sp, w600.
  static TextStyle get headline => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: CLColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.25,
  );

  /// Card titles, list item headings. 20sp, w500.
  static TextStyle get title => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: CLColors.textPrimary,
    letterSpacing: 0.0,
    height: 1.3,
  );

  /// Primary readable body copy. 16sp, w400.
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: CLColors.textPrimary,
    letterSpacing: 0.05,
    height: 1.5,
  );

  /// Standard body text. 15sp, w400.
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: CLColors.textPrimary,
    letterSpacing: 0.05,
    height: 1.5,
  );

  /// Buttons, tags, input labels, emphasized metadata. 14sp, w500.
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: CLColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// Supporting text, timestamps, fine print. 12sp, w400.
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CLColors.textSecondary,
    letterSpacing: 0.1,
    height: 1.4,
  );
}
