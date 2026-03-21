import 'package:flutter/material.dart';

/// 8-point grid spacing scale for consistent rhythm.
abstract final class VaultedSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double section = 40;

  // ── EdgeInsets shortcuts ─────────────────────────────────────

  static const insetsNone = EdgeInsets.zero;
  static const insetsXs = EdgeInsets.all(xs);
  static const insetsSm = EdgeInsets.all(sm);
  static const insetsMd = EdgeInsets.all(md);
  static const insetsLg = EdgeInsets.all(lg);
  static const insetsXl = EdgeInsets.all(xl);
  static const insetsXxl = EdgeInsets.all(xxl);
  static const insetsXxxl = EdgeInsets.all(xxxl);

  /// Standard horizontal padding for screen content.
  static const screenH = EdgeInsets.symmetric(horizontal: xl);

  /// Standard card inner padding.
  static const cardInner = EdgeInsets.all(lg);

  /// Padding for bottom-sheet content.
  static const bottomSheet = EdgeInsets.fromLTRB(xl, md, xl, xxxl);

  // ── SizedBox shortcuts ───────────────────────────────────────

  static const gapXs = SizedBox(height: xs);
  static const gapSm = SizedBox(height: sm);
  static const gapMd = SizedBox(height: md);
  static const gapLg = SizedBox(height: lg);
  static const gapXl = SizedBox(height: xl);
  static const gapXxl = SizedBox(height: xxl);
  static const gapXxxl = SizedBox(height: xxxl);
  static const gapSection = SizedBox(height: section);

  static const gapHXs = SizedBox(width: xs);
  static const gapHSm = SizedBox(width: sm);
  static const gapHMd = SizedBox(width: md);
  static const gapHLg = SizedBox(width: lg);
  static const gapHXl = SizedBox(width: xl);
}
