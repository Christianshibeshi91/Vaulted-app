import 'package:flutter/material.dart';

/// Vaulted design system color palette.
///
/// Dark luxury aesthetic with gold accents on near-black surfaces.
/// All values are compile-time constants for tree-shaking.
abstract final class VaultedColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const bgPrimary = Color(0xFF07070B);
  static const bgSecondary = Color(0xFF0C0C14);
  static const bgCard = Color(0xFF0E0E18);
  static const bgCardPressed = Color(0xFF141420);
  static const bgInput = Color(0xFF16161F);

  // ── Accent ───────────────────────────────────────────────────
  static const accentGold = Color(0xFFC9A55A);
  static const accentGoldLight = Color(0xFFE4C97A);
  static const accentGoldDim = Color(0x1FC9A55A); // 12% opacity

  // ── Text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF0ECE4);
  static const textSecondary = Color(0xFF8A8694);
  static const textMuted = Color(0xFF5A5668);

  // ── Borders ──────────────────────────────────────────────────
  static const border = Color(0x14C9A55A); // 8% opacity
  static const borderStrong = Color(0x33C9A55A); // 20% opacity

  // ── Semantic ─────────────────────────────────────────────────
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF60A5FA);

  // ── Overlay ──────────────────────────────────────────────────
  static const overlay = Color(0x99000000);

  // ── Derived helpers ──────────────────────────────────────────

  /// Gold at a custom opacity (0.0 - 1.0).
  static Color goldWithOpacity(double opacity) =>
      accentGold.withValues(alpha: opacity);

  /// Suitable shimmer base on dark cards.
  static const shimmerBase = Color(0xFF12121C);

  /// Shimmer highlight streak.
  static const shimmerHighlight = Color(0xFF1E1E2C);
}

/// Light-mode palette for Vaulted.
///
/// Warm cream tones paired with the same gold accent to retain the
/// luxury feel without the sterile-white look of typical light modes.
abstract final class VaultedColorsLight {
  // ── Backgrounds ──────────────────────────────────────────────
  static const bgPrimary = Color(0xFFFAFAF7);
  static const bgSecondary = Color(0xFFF5F4F0);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgCardPressed = Color(0xFFF0EFE9);
  static const bgInput = Color(0xFFF0EFE9);

  // ── Accent ───────────────────────────────────────────────────
  static const accentGold = Color(0xFFB8943D);
  static const accentGoldLight = Color(0xFFD4B05A);
  static const accentGoldDim = Color(0x1FB8943D); // 12 % opacity

  // ── Text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A20);
  static const textSecondary = Color(0xFF6B6A72);
  static const textMuted = Color(0xFF9E9DA5);

  // ── Borders ──────────────────────────────────────────────────
  static const border = Color(0x26B8943D); // gold @ 15 % opacity
  static const borderStrong = Color(0x40B8943D); // gold @ 25 % opacity

  // ── Semantic ─────────────────────────────────────────────────
  static const success = Color(0xFF2E9E5A);
  static const warning = Color(0xFFD4960A);
  static const danger = Color(0xFFDC4444);
  static const info = Color(0xFF3B82F6);

  // ── Overlay ──────────────────────────────────────────────────
  static const overlay = Color(0x33000000);

  // ── Derived helpers ──────────────────────────────────────────

  /// Gold at a custom opacity (0.0 - 1.0).
  static Color goldWithOpacity(double opacity) =>
      accentGold.withValues(alpha: opacity);

  /// Shimmer base on light cards.
  static const shimmerBase = Color(0xFFF0EFE9);

  /// Shimmer highlight streak.
  static const shimmerHighlight = Color(0xFFFAFAF7);
}
