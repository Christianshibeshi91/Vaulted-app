import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'haptics.dart';

/// Secure clipboard helper that auto-clears sensitive data.
///
/// ```dart
/// VaultedClipboard.copyAndClear(
///   context,
///   cardNumber,
///   label: 'Card number',
///   timeout: const Duration(seconds: 30),
/// );
/// ```
abstract final class VaultedClipboard {
  static Timer? _clearTimer;

  /// Copies [text] to the system clipboard, shows a toast via
  /// [ScaffoldMessenger], and schedules automatic clipboard clearing
  /// after [timeout] (default 60 seconds).
  ///
  /// Pass a [label] for the toast message, e.g. "Card number".
  /// If [label] is null the toast says "Copied -- auto-clears in Xs".
  static Future<void> copyAndClear(
    BuildContext context,
    String text, {
    String? label,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    // Copy to clipboard.
    await Clipboard.setData(ClipboardData(text: text));
    await Haptics.lightTap();

    // Cancel any previous pending clear so only the latest timer wins.
    _clearTimer?.cancel();

    // Schedule auto-clear.
    _clearTimer = Timer(timeout, () {
      Clipboard.setData(const ClipboardData(text: ''));
      _clearTimer = null;
    });

    // Show feedback toast.
    if (!context.mounted) return;

    final seconds = timeout.inSeconds;
    final message = label != null
        ? '$label copied \u2014 auto-clears in ${seconds}s'
        : 'Copied \u2014 auto-clears in ${seconds}s';

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Immediately clears the clipboard and cancels any pending timer.
  static Future<void> clearNow() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    await Clipboard.setData(const ClipboardData(text: ''));
  }
}
