import 'package:flutter/services.dart';

/// Semantic haptic feedback presets for the Vaulted app.
///
/// Wraps [HapticFeedback] with intention-based names so call-sites
/// read as `Haptics.success()` rather than `HapticFeedback.mediumImpact()`.
///
/// All methods are fire-and-forget; they never throw.
abstract final class Haptics {
  /// Light tap -- toggles, checkbox changes, list item selection.
  static Future<void> lightTap() => HapticFeedback.lightImpact();

  /// Medium tap -- button presses, card flips.
  static Future<void> mediumTap() => HapticFeedback.mediumImpact();

  /// Heavy tap -- destructive confirmations, large state changes.
  static Future<void> heavyTap() => HapticFeedback.heavyImpact();

  /// Selection tick -- picker scroll, slider notch.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Success -- payment confirmed, card added, action completed.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error -- validation failure, declined transaction.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// Warning -- approaching limit, suspicious activity.
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
  }

  /// Toggle on/off -- switch, biometric toggle.
  static Future<void> toggle() => HapticFeedback.lightImpact();

  /// Notification received.
  static Future<void> notification() => HapticFeedback.vibrate();

  /// Long press activated -- context menu, drag start.
  static Future<void> longPress() => HapticFeedback.heavyImpact();
}
