import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Centralised theme factory for the Vaulted app.
///
/// Currently only exposes [dark] since the app is dark-mode-only.
/// If a light theme is added later, add a `light()` factory here.
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
}
