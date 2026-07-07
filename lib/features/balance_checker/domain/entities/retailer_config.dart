/// Configuration for a retailer's balance check page.
///
/// Stored in Firestore at `retailer_configs/{id}` and cached locally.
/// Phase 1 retailers use WebView auto-fill; Phase 2 use redirect fallback.
class RetailerConfig {
  const RetailerConfig({
    required this.id,
    required this.name,
    required this.brandColor,
    required this.balanceCheckUrl,
    required this.phase,
    required this.cardNumberLength,
    required this.pinLength,
    required this.pinRequired,
    this.cardNumberSelector,
    this.pinSelector,
    this.submitSelector,
    this.balanceResultSelector,
    this.captchaSelector,
    this.jsAutoFill,
    this.jsExtractBalance,
    this.jsCaptchaDetect,
    this.status = RetailerStatus.active,
    this.lastVerified,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String brandColor;
  final String balanceCheckUrl;
  final RetailerPhase phase;

  // CSS selectors for WebView injection (Phase 1 only)
  final String? cardNumberSelector;
  final String? pinSelector;
  final String? submitSelector;
  final String? balanceResultSelector;
  final String? captchaSelector;

  // Validation rules
  final int cardNumberLength;
  final int pinLength;
  final bool pinRequired;

  // Custom JavaScript templates (override defaults if set)
  final String? jsAutoFill;
  final String? jsExtractBalance;
  final String? jsCaptchaDetect;

  // Metadata
  final RetailerStatus status;
  final DateTime? lastVerified;
  final DateTime? updatedAt;

  /// The expected domain for URL verification before JS injection.
  String get expectedDomain {
    final uri = Uri.parse(balanceCheckUrl);
    return '${uri.scheme}://${uri.host}';
  }

  /// Whether this retailer supports WebView auto-fill.
  bool get supportsWebView => phase == RetailerPhase.webview;

  /// Whether this retailer requires redirect to external browser.
  bool get requiresRedirect => phase == RetailerPhase.redirect;
}

enum RetailerPhase {
  webview,
  redirect;

  static RetailerPhase fromString(String value) => switch (value) {
        'webview' => webview,
        'redirect' => redirect,
        _ => redirect,
      };
}

enum RetailerStatus {
  active,
  degraded,
  down;

  static RetailerStatus fromString(String value) => switch (value) {
        'active' => active,
        'degraded' => degraded,
        'down' => down,
        _ => down,
      };
}
