import 'package:flutter/material.dart';

/// Casa Lazzarini motion tokens.
///
/// Prefer [durationNormal] + [curveDefault] for most transitions.
/// Reserve [curveSpring] for delightful micro-interactions only.
abstract final class CLMotion {
  // ── Durations ─────────────────────────────────────────────────────────────

  /// 150ms — instant feedback: icon swaps, state toggles.
  static const Duration durationFast = Duration(milliseconds: 150);

  /// 250ms — standard transitions: page fades, reveal animations.
  static const Duration durationNormal = Duration(milliseconds: 250);

  /// 400ms — deliberate transitions: complex layouts, bottom sheets.
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ── Curves ────────────────────────────────────────────────────────────────

  /// Smooth in-out — the default for most transitions.
  static const Curve curveDefault = Curves.easeInOut;

  /// Decelerates to rest — entering elements (slide-in, fade-in).
  static const Curve curveEntrance = Curves.easeOut;

  /// Accelerates away — exiting elements (slide-out, fade-out).
  static const Curve curveExit = Curves.easeIn;

  /// Elastic bounce — use sparingly for delightful micro-interactions.
  static const Curve curveSpring = Curves.elasticOut;
}
