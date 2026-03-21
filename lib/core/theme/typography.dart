import 'package:flutter/material.dart';
import 'colors.dart';

/// Vaulted typographic scale across three font families.
///
/// - **Display** (DM Serif Display) -- balances, hero numbers
/// - **Body** (Outfit) -- all UI text
/// - **Mono** (JetBrains Mono) -- amounts, card numbers, codes
abstract final class VaultedTypography {
  // ─────────────────────────────────────────────────────────────
  //  Display  --  DM Serif Display
  // ─────────────────────────────────────────────────────────────

  static const displayLarge = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: -0.5,
    color: VaultedColors.textPrimary,
  );

  static const displayMedium = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.3,
    color: VaultedColors.textPrimary,
  );

  // ─────────────────────────────────────────────────────────────
  //  Body  --  Outfit
  // ─────────────────────────────────────────────────────────────

  static const headlineLarge = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: VaultedColors.textPrimary,
  );

  static const headlineMedium = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: VaultedColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: VaultedColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: VaultedColors.textSecondary,
  );

  static const labelSmall = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.4,
    color: VaultedColors.textSecondary,
  );

  static const labelMicro = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: VaultedColors.textMuted,
  );

  // ─────────────────────────────────────────────────────────────
  //  Mono  --  JetBrains Mono
  // ─────────────────────────────────────────────────────────────

  static const monoHero = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.5,
    color: VaultedColors.textPrimary,
  );

  static const monoLarge = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 1.0,
    color: VaultedColors.textPrimary,
  );

  static const monoMedium = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.8,
    color: VaultedColors.textPrimary,
  );

  static const monoSmall = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.6,
    color: VaultedColors.textSecondary,
  );

  // ─────────────────────────────────────────────────────────────
  //  Convenience builders
  // ─────────────────────────────────────────────────────────────

  /// Body text styled as a button label (medium weight, uppercase optional).
  static TextStyle buttonLabel({bool uppercase = false}) => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: uppercase ? 1.2 : 0.3,
        color: VaultedColors.textPrimary,
      );

  /// Gold-tinted variant of any style.
  static TextStyle gold(TextStyle base) =>
      base.copyWith(color: VaultedColors.accentGold);

  /// Muted variant of any style.
  static TextStyle muted(TextStyle base) =>
      base.copyWith(color: VaultedColors.textMuted);

  /// Secondary variant of any style.
  static TextStyle secondary(TextStyle base) =>
      base.copyWith(color: VaultedColors.textSecondary);
}
