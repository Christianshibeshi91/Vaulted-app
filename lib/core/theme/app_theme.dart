import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';
import 'radii.dart';

/// Builds the single dark [ThemeData] for the Vaulted app.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: VaultedTheme.dark,
///   ...
/// )
/// ```
abstract final class VaultedTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: VaultedColors.accentGold,
      onPrimary: VaultedColors.bgPrimary,
      primaryContainer: VaultedColors.accentGoldDim,
      onPrimaryContainer: VaultedColors.accentGold,
      secondary: VaultedColors.accentGoldLight,
      onSecondary: VaultedColors.bgPrimary,
      secondaryContainer: VaultedColors.accentGoldDim,
      onSecondaryContainer: VaultedColors.accentGoldLight,
      surface: VaultedColors.bgPrimary,
      onSurface: VaultedColors.textPrimary,
      surfaceContainerHighest: VaultedColors.bgCard,
      onSurfaceVariant: VaultedColors.textSecondary,
      error: VaultedColors.danger,
      onError: VaultedColors.bgPrimary,
      outline: VaultedColors.border,
      outlineVariant: VaultedColors.borderStrong,
      shadow: Colors.black,
      scrim: VaultedColors.overlay,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: VaultedColors.bgPrimary,
      canvasColor: VaultedColors.bgSecondary,
      cardColor: VaultedColors.bgCard,
      dividerColor: VaultedColors.border,
      splashColor: VaultedColors.accentGoldDim,
      highlightColor: VaultedColors.accentGoldDim,

      // ── Typography ───────────────────────────────────────────
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

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: VaultedTypography.headlineMedium,
        iconTheme: IconThemeData(
          color: VaultedColors.accentGold,
          size: 22,
        ),
        actionsIconTheme: IconThemeData(
          color: VaultedColors.accentGold,
          size: 22,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: VaultedColors.bgPrimary,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Bottom Navigation ────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: VaultedColors.bgSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: VaultedColors.accentGold,
        unselectedItemColor: VaultedColors.textMuted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
      ),

      // ── Navigation Bar (M3) ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: VaultedColors.bgSecondary,
        elevation: 0,
        height: 64,
        indicatorColor: VaultedColors.accentGoldDim,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VaultedTypography.labelSmall
                .copyWith(color: VaultedColors.accentGold);
          }
          return VaultedTypography.labelSmall
              .copyWith(color: VaultedColors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: VaultedColors.accentGold,
              size: 22,
            );
          }
          return const IconThemeData(
            color: VaultedColors.textMuted,
            size: 22,
          );
        }),
      ),

      // ── Input Decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VaultedColors.bgInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.lg,
          vertical: VaultedSpacing.md,
        ),
        hintStyle: VaultedTypography.bodyLarge
            .copyWith(color: VaultedColors.textMuted),
        labelStyle: VaultedTypography.bodyMedium
            .copyWith(color: VaultedColors.textSecondary),
        prefixIconColor: VaultedColors.textSecondary,
        suffixIconColor: VaultedColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: VaultedRadii.brInput,
          borderSide: const BorderSide(color: VaultedColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VaultedRadii.brInput,
          borderSide: const BorderSide(color: VaultedColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VaultedRadii.brInput,
          borderSide: const BorderSide(
            color: VaultedColors.accentGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: VaultedRadii.brInput,
          borderSide: const BorderSide(color: VaultedColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: VaultedRadii.brInput,
          borderSide: const BorderSide(
            color: VaultedColors.danger,
            width: 1.5,
          ),
        ),
        errorStyle: VaultedTypography.labelSmall
            .copyWith(color: VaultedColors.danger),
      ),

      // ── Elevated Button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VaultedColors.accentGold,
          foregroundColor: VaultedColors.bgPrimary,
          disabledBackgroundColor: VaultedColors.accentGoldDim,
          disabledForegroundColor: VaultedColors.textMuted,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xxl,
            vertical: VaultedSpacing.md,
          ),
          shape: VaultedRadii.shapeButton,
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VaultedColors.textPrimary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: VaultedColors.textMuted,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xxl,
            vertical: VaultedSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: VaultedRadii.brButton,
            side: const BorderSide(color: VaultedColors.borderStrong),
          ),
          side: const BorderSide(color: VaultedColors.borderStrong),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VaultedColors.accentGold,
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: VaultedRadii.shapeButton,
        ),
      ),

      // ── Icon Button ──────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: VaultedColors.textSecondary,
          highlightColor: VaultedColors.accentGoldDim,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: VaultedColors.bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: VaultedRadii.brCard,
          side: const BorderSide(color: VaultedColors.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: VaultedColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom Sheet ─────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: VaultedColors.bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: VaultedRadii.brBottomSheet,
        ),
        dragHandleColor: VaultedColors.textMuted,
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
        modalBarrierColor: VaultedColors.overlay,
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: VaultedColors.bgSecondary,
        elevation: 0,
        shape: VaultedRadii.shapeCard,
        titleTextStyle: VaultedTypography.headlineMedium,
        contentTextStyle: VaultedTypography.bodyLarge,
      ),

      // ── Snackbar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: VaultedColors.bgCard,
        contentTextStyle: VaultedTypography.bodyMedium
            .copyWith(color: VaultedColors.textPrimary),
        shape: VaultedRadii.shapeButton,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        insetPadding: VaultedSpacing.screenH,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: VaultedColors.bgInput,
        selectedColor: VaultedColors.accentGoldDim,
        disabledColor: VaultedColors.bgCard,
        labelStyle: VaultedTypography.bodyMedium,
        side: const BorderSide(color: VaultedColors.border),
        shape: VaultedRadii.shapePill,
        padding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.md,
          vertical: VaultedSpacing.xs,
        ),
      ),

      // ── List Tile ────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: VaultedSpacing.xl,
          vertical: VaultedSpacing.xs,
        ),
        iconColor: VaultedColors.textSecondary,
        textColor: VaultedColors.textPrimary,
        titleTextStyle: VaultedTypography.bodyLarge,
        subtitleTextStyle: VaultedTypography.bodyMedium,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        minLeadingWidth: 24,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VaultedColors.bgPrimary;
          }
          return VaultedColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VaultedColors.accentGold;
          }
          return VaultedColors.bgInput;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VaultedColors.accentGold;
          }
          return VaultedColors.borderStrong;
        }),
      ),

      // ── Progress Indicator ───────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VaultedColors.accentGold,
        linearTrackColor: VaultedColors.bgInput,
        circularTrackColor: VaultedColors.bgInput,
      ),

      // ── Tooltip ──────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brBadge,
          border: Border.all(color: VaultedColors.borderStrong),
        ),
        textStyle: VaultedTypography.bodyMedium
            .copyWith(color: VaultedColors.textPrimary),
      ),

      // ── Tab Bar ──────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: VaultedColors.accentGold,
        unselectedLabelColor: VaultedColors.textMuted,
        indicatorColor: VaultedColors.accentGold,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: VaultedTypography.bodyLarge
            .copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: VaultedTypography.bodyLarge,
        dividerColor: VaultedColors.border,
      ),
    );
  }
}
