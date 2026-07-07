import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/balance_parser.dart';
import '../../domain/entities/balance_result.dart';
import '../../domain/entities/retailer_config.dart';
import 'javascript_bridge.dart';
import 'webview_manager.dart';

/// Orchestrates the hidden WebView balance-checking lifecycle.
///
/// This is the core engine of the balance checker feature. It:
/// 1. Creates a hidden WebView via [WebViewManager]
/// 2. Loads the retailer's balance check page
/// 3. Verifies the URL domain (security check)
/// 4. Injects JavaScript to auto-fill credentials and submit
/// 5. Listens for the result via JavaScriptChannel
/// 6. Returns a [BalanceResult] and disposes the WebView
///
/// SECURITY:
/// - Domain verification before any JS injection
/// - Fresh WebView for every check, disposed immediately after
/// - Card credentials sanitized to digits-only before injection
/// - 20-second timeout on the entire operation
class BalanceCheckerService {
  BalanceCheckerService({
    required this.config,
    this.onCaptchaRequired,
    this.timeoutDuration = const Duration(seconds: 20),
  });

  final RetailerConfig config;
  final Duration timeoutDuration;

  /// Called when a CAPTCHA is detected. The UI should show the WebView
  /// and wait for the user to solve it. Call [resumeAfterCaptcha] when done.
  final VoidCallback? onCaptchaRequired;

  WebViewManager? _webViewManager;
  Completer<BalanceResult>? _resultCompleter;
  Timer? _timeoutTimer;
  Stopwatch? _stopwatch;

  /// The WebView controller, exposed for the CAPTCHA overlay to display.
  WebViewManager? get webViewManager => _webViewManager;

  /// Whether a balance check is currently in progress.
  bool get isChecking => _resultCompleter != null && !_resultCompleter!.isCompleted;

  /// Whether the current platform supports WebView-based balance checking.
  ///
  /// On Flutter web, `webview_flutter` renders as an iframe. Cross-origin
  /// iframes cannot have JavaScript injected (same-origin policy) and most
  /// retailer sites send X-Frame-Options: DENY, blocking loading entirely.
  bool get isWebViewSupported => !kIsWeb;

  /// Performs a balance check for the given card credentials.
  ///
  /// Returns a [BalanceResult] sealed class with one of:
  /// - [BalanceSuccess] with the extracted amount
  /// - [BalanceCaptchaRequired] if CAPTCHA intervention needed
  /// - [BalanceError] with an error message
  /// - [BalanceTimeout] if the operation exceeded [timeoutDuration]
  ///
  /// On web, returns [BalanceError] with [BalanceErrorCode.webUnsupported]
  /// immediately, signalling the UI to show manual balance entry.
  Future<BalanceResult> checkBalance({
    required String cardNumber,
    required String pin,
  }) async {
    // On web, WebView-based scraping is impossible due to iframe
    // same-origin restrictions and X-Frame-Options headers.
    if (!isWebViewSupported) {
      return const BalanceError(
        message: 'WEB_UNSUPPORTED',
        code: BalanceErrorCode.webUnsupported,
      );
    }

    _resultCompleter = Completer<BalanceResult>();
    _stopwatch = Stopwatch()..start();

    // Start timeout timer
    _timeoutTimer = Timer(timeoutDuration, () {
      if (!_resultCompleter!.isCompleted) {
        _stopwatch?.stop();
        _resultCompleter!.complete(BalanceTimeout(
          durationMs: _stopwatch?.elapsedMilliseconds ?? 20000,
        ));
        _cleanup();
      }
    });

    // Create and initialize WebView
    _webViewManager = WebViewManager(
      config: config,
      onMessage: _handleChannelMessage,
      onPageLoaded: (url) => _onPageLoaded(url, cardNumber, pin),
      onPageError: _onPageError,
    );
    _webViewManager!.initialize();

    // Load the retailer's balance check page
    await _webViewManager!.loadBalancePage();

    return _resultCompleter!.future;
  }

  void _onPageLoaded(String url, String cardNumber, String pin) async {
    if (_resultCompleter == null || _resultCompleter!.isCompleted) return;

    // SECURITY: Verify domain before injecting credentials
    final domainValid = await _webViewManager?.verifyDomain();
    if (domainValid != true) {
      _complete(const BalanceError(
        message: 'Security check failed: unexpected domain',
        code: BalanceErrorCode.domainMismatch,
      ));
      return;
    }

    // Generate and inject the auto-fill script
    final script = JavaScriptBridge.buildAutoFillScript(
      config: config,
      cardNumber: cardNumber,
      pin: pin,
    );

    try {
      await _webViewManager?.runJavaScript(script);
    } catch (e) {
      _complete(BalanceError(
        message: 'Failed to inject script: $e',
        code: BalanceErrorCode.selectorNotFound,
      ));
    }
  }

  void _onPageError(String url, int errorCode) {
    if (_resultCompleter == null || _resultCompleter!.isCompleted) return;
    _complete(BalanceError(
      message: 'Page load error ($errorCode)',
      code: BalanceErrorCode.pageLoadFailed,
    ));
  }

  void _handleChannelMessage(ChannelMessage message) {
    if (_resultCompleter == null || _resultCompleter!.isCompleted) return;

    switch (message) {
      case BalanceMessage(rawText: final rawText):
        _stopwatch?.stop();
        final amount = BalanceParser.parse(rawText);
        if (amount != null) {
          _complete(BalanceSuccess(
            amount: amount,
            rawText: rawText,
            durationMs: _stopwatch?.elapsedMilliseconds ?? 0,
          ));
        } else {
          _complete(BalanceError(
            message: 'Could not parse balance from: $rawText',
            code: BalanceErrorCode.parseError,
          ));
        }

      case CaptchaMessage():
        // Notify the UI to show the WebView for CAPTCHA solving
        onCaptchaRequired?.call();
        // Don't complete — wait for the balance to arrive after CAPTCHA

      case ErrorMessage(code: final code):
        _stopwatch?.stop();
        final errorCode = switch (code) {
          'CARD_FIELD_NOT_FOUND' => BalanceErrorCode.cardFieldNotFound,
          'INVALID_CARD' => BalanceErrorCode.invalidCard,
          'TIMEOUT' => BalanceErrorCode.selectorNotFound,
          'CAPTCHA_TIMEOUT' => BalanceErrorCode.captchaTimeout,
          _ => BalanceErrorCode.networkError,
        };
        _complete(BalanceError(message: code, code: errorCode));
    }
  }

  /// Injects the hide-chrome script after CAPTCHA is shown.
  Future<void> hideChromeForCaptcha() async {
    await _webViewManager?.runJavaScript(
      JavaScriptBridge.hideRetailerChromeScript,
    );
  }

  void _complete(BalanceResult result) {
    if (_resultCompleter != null && !_resultCompleter!.isCompleted) {
      _resultCompleter!.complete(result);
    }
    _cleanup();
  }

  Future<void> _cleanup() async {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    // Don't dispose WebView immediately if CAPTCHA is in progress
    // The UI will call dispose() when the overlay is dismissed
  }

  /// Disposes all resources. Call this when the balance check
  /// is complete or the widget is being torn down.
  Future<void> dispose() async {
    _timeoutTimer?.cancel();
    _stopwatch?.stop();
    if (_resultCompleter != null && !_resultCompleter!.isCompleted) {
      _resultCompleter!.complete(const BalanceError(
        message: 'Balance check cancelled',
        code: BalanceErrorCode.networkError,
      ));
    }
    await _webViewManager?.dispose();
    _webViewManager = null;
  }
}
