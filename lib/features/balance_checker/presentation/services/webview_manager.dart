import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/retailer_config.dart';
import 'javascript_bridge.dart';

/// Callback types for WebView events.
typedef OnMessageReceived = void Function(ChannelMessage message);
typedef OnPageLoaded = void Function(String url);
typedef OnPageError = void Function(String url, int errorCode);

/// Manages the lifecycle of a single WebView instance.
///
/// SECURITY INVARIANTS:
/// - A fresh WebView is created for every balance check.
/// - After extracting the balance, all data is cleared and controller disposed.
/// - URL domain is verified before any JavaScript injection.
/// - Never reuse WebViews across checks.
class WebViewManager {
  WebViewManager({
    required this.config,
    required this.onMessage,
    this.onPageLoaded,
    this.onPageError,
  });

  final RetailerConfig config;
  final OnMessageReceived onMessage;
  final OnPageLoaded? onPageLoaded;
  final OnPageError? onPageError;

  WebViewController? _controller;
  bool _isDisposed = false;

  /// The underlying controller, available after [initialize].
  WebViewController? get controller => _controller;

  /// Whether this manager has been disposed.
  bool get isDisposed => _isDisposed;

  /// Creates and configures a fresh WebView controller.
  void initialize() {
    if (_isDisposed) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        JavaScriptBridge.channelName,
        onMessageReceived: (message) {
          if (_isDisposed) return;
          final parsed = JavaScriptBridge.parseMessage(message.message);
          onMessage(parsed);
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (_isDisposed) return;
          onPageLoaded?.call(url);
        },
        onWebResourceError: (error) {
          if (_isDisposed) return;
          onPageError?.call(error.url ?? '', error.errorCode);
        },
        onNavigationRequest: (request) {
          // Allow navigation only within the retailer's domain
          // and common CAPTCHA domains.
          final url = request.url.toLowerCase();
          final allowed = url.startsWith(config.expectedDomain.toLowerCase()) ||
              url.contains('google.com/recaptcha') ||
              url.contains('cloudflare.com') ||
              url.contains('hcaptcha.com') ||
              url.contains('challenges.cloudflare.com');
          return allowed
              ? NavigationDecision.navigate
              : NavigationDecision.prevent;
        },
      ));
  }

  /// Loads the retailer's balance check page.
  Future<void> loadBalancePage() async {
    if (_isDisposed || _controller == null) return;
    await _controller!.loadRequest(Uri.parse(config.balanceCheckUrl));
  }

  /// Verifies that the current WebView URL matches the expected domain.
  ///
  /// Returns `true` if the domain matches, `false` if not (potential MITM).
  Future<bool> verifyDomain() async {
    if (_isDisposed || _controller == null) return false;

    final currentUrl = await _controller!.currentUrl();
    if (currentUrl == null) return false;

    return currentUrl
        .toLowerCase()
        .startsWith(config.expectedDomain.toLowerCase());
  }

  /// Injects JavaScript into the WebView.
  Future<void> runJavaScript(String js) async {
    if (_isDisposed || _controller == null) return;
    await _controller!.runJavaScript(js);
  }

  /// Disposes the WebView, clearing all data.
  ///
  /// After calling this, the manager cannot be reused.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    if (_controller != null) {
      try {
        await _controller!.clearCache();
        await _controller!.clearLocalStorage();
        // Load a blank page to stop any running scripts
        await _controller!.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        // Best-effort cleanup; controller may already be dead
      }
      _controller = null;
    }
  }
}
