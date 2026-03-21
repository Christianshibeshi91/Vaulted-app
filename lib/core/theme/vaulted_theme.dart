import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Centralised theme factory for the Vaulted app.
///
/// Exposes [dark] and [light] factories sharing the same typographic
/// scale, spacing, and structure while swapping the colour palette.
abstract final class VaultedTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VaultedColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: VaultedColors.accentGold,
        onPrimary: VaultedColors.bgPrimary,
        secondary: VaultedColors.accentGoldLight,
        onSecondary: VaultedColors.bgPrimary,
        surface: VaultedColors.bgSecondary,
        onSurface: VaultedColors.textPrimary,
        error: VaultedColors.danger,
        onError: Colors.white,
      ),
      fontFamily: 'Outfit',
      textTheme: const TextTheme(
        displayLarge: VaultedTypography.displayLarge,
        displayMedium: VaultedTypography.displayMedium,
        headlineLarge: VaultedTypography.headlineLarge,
        headlineMedium: VaultedTypography.headlineMedium,
        bodyLarge: VaultedTypography.bodyLarge,
        bodyMedium: VaultedTypography.bodyMedium,
        labelSmall: VaultedTypography.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: VaultedColors.bgSecondary,
        foregroundColor: VaultedColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: VaultedColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultedColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VaultedColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultedColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultedColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VaultedColors.accentGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultedColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: VaultedTypography.muted(VaultedTypography.bodyLarge),
        labelStyle: VaultedTypography.secondary(VaultedTypography.bodyMedium),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VaultedColors.accentGold,
          foregroundColor: VaultedColors.bgPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: VaultedTypography.buttonLabel(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VaultedColors.accentGold,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: VaultedColors.borderStrong),
          textStyle: VaultedTypography.buttonLabel(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VaultedColors.accentGold,
          textStyle: VaultedTypography.buttonLabel(),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: VaultedColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: VaultedColors.bgCard,
        contentTextStyle: VaultedTypography.bodyMedium.copyWith(
          color: VaultedColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: VaultedColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VaultedColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VaultedColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VaultedColors.border),
        ),
        titleTextStyle: VaultedTypography.headlineMedium,
        contentTextStyle: VaultedTypography.bodyLarge,
      ),
    );
  }

  /// Warm-cream light theme retaining the luxury gold accent.
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: VaultedColorsLight.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: VaultedColorsLight.accentGold,
        onPrimary: Colors.white,
        secondary: VaultedColorsLight.accentGoldLight,
        onSecondary: Colors.white,
        surface: VaultedColorsLight.bgSecondary,
        onSurface: VaultedColorsLight.textPrimary,
        error: VaultedColorsLight.danger,
        onError: Colors.white,
      ),
      fontFamily: 'Outfit',
      textTheme: TextTheme(
        displayLarge: VaultedTypography.displayLarge.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        displayMedium: VaultedTypography.displayMedium.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        headlineLarge: VaultedTypography.headlineLarge.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        headlineMedium: VaultedTypography.headlineMedium.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        bodyLarge: VaultedTypography.bodyLarge.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        bodyMedium: VaultedTypography.bodyMedium.copyWith(
          color: VaultedColorsLight.textSecondary,
        ),
        labelSmall: VaultedTypography.labelSmall.copyWith(
          color: VaultedColorsLight.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: VaultedColorsLight.bgSecondary,
        foregroundColor: VaultedColorsLight.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: VaultedColorsLight.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultedColorsLight.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VaultedColorsLight.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultedColorsLight.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultedColorsLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VaultedColorsLight.accentGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultedColorsLight.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: VaultedTypography.bodyLarge.copyWith(
          color: VaultedColorsLight.textMuted,
        ),
        labelStyle: VaultedTypography.bodyMedium.copyWith(
          color: VaultedColorsLight.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VaultedColorsLight.accentGold,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: VaultedTypography.buttonLabel(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VaultedColorsLight.accentGold,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: VaultedColorsLight.borderStrong),
          textStyle: VaultedTypography.buttonLabel(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VaultedColorsLight.accentGold,
          textStyle: VaultedTypography.buttonLabel(),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: VaultedColorsLight.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: VaultedColorsLight.bgCard,
        contentTextStyle: VaultedTypography.bodyMedium.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: VaultedColorsLight.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VaultedColorsLight.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VaultedColorsLight.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VaultedColorsLight.border),
        ),
        titleTextStyle: VaultedTypography.headlineMedium.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
        contentTextStyle: VaultedTypography.bodyLarge.copyWith(
          color: VaultedColorsLight.textPrimary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return VaultedColorsLight.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VaultedColorsLight.accentGold;
          }
          return VaultedColorsLight.bgInput;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VaultedColorsLight.accentGold;
          }
          return VaultedColorsLight.borderStrong;
        }),
      ),
    );
  }
}
