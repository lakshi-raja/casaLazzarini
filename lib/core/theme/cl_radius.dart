import 'package:flutter/material.dart';

/// Casa Lazzarini border radius tokens.
///
/// Provides both [Radius] primitives and ready-made [BorderRadius] shortcuts.
abstract final class CLRadius {
  // ── Radius primitives ────────────────────────────────────────────────────

  /// 6px — subtle rounding for small chips, tags, inputs.
  static const Radius sm = Radius.circular(6);

  /// 12px — standard rounding for list tiles, form fields.
  static const Radius md = Radius.circular(12);

  /// 20px — generous rounding for cards and panels.
  static const Radius lg = Radius.circular(20);

  /// 28px — bold rounding for prominent containers.
  static const Radius xl = Radius.circular(28);

  /// 100px — pill/circle shapes for buttons and badges.
  static const Radius full = Radius.circular(100);

  // ── BorderRadius shortcuts ────────────────────────────────────────────────

  /// All corners at [sm] (6px).
  static const BorderRadius smAll = BorderRadius.all(sm);

  /// All corners at [md] (12px).
  static const BorderRadius mdAll = BorderRadius.all(md);

  /// All corners at [lg] (20px).
  static const BorderRadius lgAll = BorderRadius.all(lg);

  /// All corners at [xl] (28px).
  static const BorderRadius xlAll = BorderRadius.all(xl);

  /// Top corners only at [xl] — bottom sheets.
  static const BorderRadius xlTop = BorderRadius.only(
    topLeft: xl,
    topRight: xl,
  );

  /// Top corners only at [lg] — bottom sheets (standard).
  static const BorderRadius lgTop = BorderRadius.only(
    topLeft: lg,
    topRight: lg,
  );
}
