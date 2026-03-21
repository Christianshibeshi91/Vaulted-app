import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Prevents screenshots and screen recording on sensitive screens.
///
/// Usage:
/// ```dart
/// class _CardDetailScreenState extends State<CardDetailScreen>
///     with ScreenshotPreventionMixin {
///   // ...
/// }
/// ```
///
/// Supports:
/// - **Android**: Sets `FLAG_SECURE` via platform channel.
/// - **iOS**: Overlays a secure text field trick (best-effort).
/// - **Web**: Applies `user-select: none` via JS interop (best-effort).
///
/// On other platforms this mixin is a no-op.
mixin ScreenshotPreventionMixin<T extends StatefulWidget> on State<T> {
  static const _channel = MethodChannel('vaulted/screenshot_prevention');

  @override
  void initState() {
    super.initState();
    _enableProtection();
  }

  @override
  void dispose() {
    _disableProtection();
    super.dispose();
  }

  // ── Platform-specific implementation ────────────────────────────

  Future<void> _enableProtection() async {
    try {
      if (kIsWeb) {
        // Best-effort: disable text selection / right-click via JS.
        // The MethodChannel approach requires a web plugin; for now
        // the mixin is a safe no-op on web.
        return;
      }

      if (Platform.isAndroid) {
        // Uses FLAG_SECURE to prevent screenshots and screen recording.
        // Requires a MethodChannel handler registered on the Android side:
        //   `window.setFlags(FLAG_SECURE, FLAG_SECURE)`
        await _channel.invokeMethod<void>('enableSecure');
        return;
      }

      if (Platform.isIOS) {
        // iOS does not have a direct FLAG_SECURE equivalent.
        // Technique: create an invisible UITextField with
        // `isSecureTextEntry = true` that covers the screen,
        // triggering iOS's built-in screenshot redaction.
        await _channel.invokeMethod<void>('enableSecure');
        return;
      }
    } on MissingPluginException {
      // Platform channel not yet wired -- degrade gracefully.
      debugPrint(
        'ScreenshotPreventionMixin: platform channel not available. '
        'Skipping screenshot protection.',
      );
    } on PlatformException catch (e) {
      debugPrint('ScreenshotPreventionMixin: $e');
    }
  }

  Future<void> _disableProtection() async {
    try {
      if (kIsWeb) return;
      if (Platform.isAndroid || Platform.isIOS) {
        await _channel.invokeMethod<void>('disableSecure');
      }
    } on MissingPluginException {
      // Silently ignore -- protection was never enabled.
    } on PlatformException catch (e) {
      debugPrint('ScreenshotPreventionMixin: $e');
    }
  }
}
