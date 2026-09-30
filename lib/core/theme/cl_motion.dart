import 'package:flutter/material.dart';

/// Casa Lazzarini motion tokens.
///
/// Prefer [durationNormal] + [curveDefault] for most transitions.
/// Use [durationSlow] + [curveEntrance] for hero/section entrances.
abstract final class CLMotion {
  // ── Durations ─────────────────────────────────────────────────────────────

  /// 160ms — instant feedback: icon swaps, press states, toggles.
  static const Duration durationFast = Duration(milliseconds: 160);

  /// 260ms — standard transitions: fades, reveals, card state changes.
  static const Duration durationNormal = Duration(milliseconds: 260);

  /// 420ms — deliberate transitions: hero entrance, complex layout reveals.
  static const Duration durationSlow = Duration(milliseconds: 420);

  // ── Curves ────────────────────────────────────────────────────────────────

  /// Smooth in-out — default for most transitions.
  static const Curve curveDefault = Curves.easeInOut;

  /// Decelerates to rest — entering elements (slide-in, fade-in).
  static const Curve curveEntrance = Curves.easeOut;

  /// Accelerates away — exiting elements (slide-out, fade-out).
  static const Curve curveExit = Curves.easeIn;

  /// Elastic bounce — use sparingly for delightful micro-interactions.
  static const Curve curveSpring = Curves.elasticOut;
}
