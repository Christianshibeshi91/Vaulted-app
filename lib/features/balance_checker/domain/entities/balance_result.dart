/// Result of a balance check operation.
///
/// Sealed class with four variants covering all possible outcomes
/// of the WebView-based balance checking flow.
sealed class BalanceResult {
  const BalanceResult();
}

/// Balance was successfully extracted from the retailer's page.
final class BalanceSuccess extends BalanceResult {
  const BalanceSuccess({
    required this.amount,
    required this.rawText,
    required this.durationMs,
    this.captchaWasRequired = false,
  });

  final double amount;
  final String rawText;
  final int durationMs;
  final bool captchaWasRequired;
}

/// A CAPTCHA was detected and the WebView needs to be shown to the user.
final class BalanceCaptchaRequired extends BalanceResult {
  const BalanceCaptchaRequired();
}

/// An error occurred during the balance check.
final class BalanceError extends BalanceResult {
  const BalanceError({required this.message, this.code});

  final String message;
  final BalanceErrorCode? code;
}

/// The balance check timed out.
final class BalanceTimeout extends BalanceResult {
  const BalanceTimeout({this.durationMs = 20000});

  final int durationMs;
}

/// Error codes for categorizing balance check failures.
enum BalanceErrorCode {
  cardFieldNotFound,
  invalidCard,
  domainMismatch,
  pageLoadFailed,
  selectorNotFound,
  parseError,
  networkError,
  captchaTimeout,
  rateLimited,
  retailerDown,

  /// WebView-based balance checking is not supported on this platform
  /// (e.g., Flutter web where iframes are blocked by same-origin policy).
  webUnsupported,
}
