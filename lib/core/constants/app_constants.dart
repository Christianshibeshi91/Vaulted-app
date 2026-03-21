/// Application-wide constant values.
///
/// Centralised here so magic numbers never appear in feature code.
abstract final class AppConstants {
  // ── Timeouts (Duration) ──────────────────────────────────────

  /// HTTP request timeout.
  static const httpTimeout = Duration(seconds: 15);

  /// Firebase Firestore operation timeout.
  static const firestoreTimeout = Duration(seconds: 10);

  /// Image upload timeout (larger payloads).
  static const uploadTimeout = Duration(seconds: 30);

  /// Biometric prompt timeout.
  static const biometricTimeout = Duration(seconds: 60);

  /// Debounce delay for search inputs.
  static const searchDebounce = Duration(milliseconds: 400);

  /// Throttle interval for analytics events.
  static const analyticsThrottle = Duration(seconds: 2);

  /// Auto-lock after inactivity.
  static const autoLockTimeout = Duration(minutes: 5);

  /// Token refresh buffer -- refresh this far before expiry.
  static const tokenRefreshBuffer = Duration(minutes: 5);

  // ── Limits ───────────────────────────────────────────────────

  /// Maximum gift cards a user may store.
  static const maxCards = 100;

  /// Maximum image size for card photo (bytes = 5 MB).
  static const maxImageBytes = 5 * 1024 * 1024;

  /// Maximum characters in a gift card note.
  static const maxNoteLength = 250;

  /// Pin code length.
  static const pinLength = 6;

  /// OTP code length.
  static const otpLength = 6;

  /// Minimum password length.
  static const minPasswordLength = 8;

  /// Maximum failed auth attempts before lockout.
  static const maxAuthAttempts = 5;

  /// Pagination page size for transaction history.
  static const pageSize = 20;

  /// Maximum number of recent searches to persist.
  static const maxRecentSearches = 10;

  // ── Defaults ─────────────────────────────────────────────────

  /// Default currency code.
  static const defaultCurrency = 'USD';

  /// Default locale for formatting.
  static const defaultLocale = 'en_US';

  /// Placeholder card last-four digits when unknown.
  static const placeholderLastFour = '****';

  /// App display name.
  static const appName = 'Vaulted';

  /// Support email address.
  static const supportEmail = 'support@vaulted.app';

  /// Terms of service URL.
  static const termsUrl = 'https://vaulted.app/terms';

  /// Privacy policy URL.
  static const privacyUrl = 'https://vaulted.app/privacy';

  // ── Animation Durations ──────────────────────────────────────

  /// Quick micro-interaction (button press, toggle).
  static const animFast = Duration(milliseconds: 150);

  /// Standard transition (page, card flip).
  static const animNormal = Duration(milliseconds: 300);

  /// Slow, cinematic transition (bottom sheet, hero).
  static const animSlow = Duration(milliseconds: 500);

  /// Stagger delay between list items.
  static const animStagger = Duration(milliseconds: 50);
}
