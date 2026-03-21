import 'package:intl/intl.dart';

/// Pure formatting utilities -- no side-effects, no state.
abstract final class Formatters {
  // ── Currency ─────────────────────────────────────────────────

  static final _usdFull = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _usdCompact = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 1,
  );

  static final _usdWhole = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  /// Formats [amount] as `$1,234.56`.
  static String currency(double amount) => _usdFull.format(amount);

  /// Formats [amount] without cents: `$1,235`.
  static String currencyWhole(double amount) => _usdWhole.format(amount);

  /// Compact format for large values: `$1.2K`, `$3.4M`.
  static String currencyCompact(double amount) => _usdCompact.format(amount);

  /// Formats cents integer (e.g. 12350) as `$123.50`.
  static String currencyFromCents(int cents) =>
      _usdFull.format(cents / 100.0);

  /// Sign-prefixed format: `+$50.00` or `-$12.34`.
  static String currencySigned(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_usdFull.format(amount)}';
  }

  // ── Dates ────────────────────────────────────────────────────

  static final _dateShort = DateFormat.MMMd(); // Jan 5
  static final _dateFull = DateFormat.yMMMd(); // Jan 5, 2025
  static final _time = DateFormat.jm(); // 3:45 PM
  static final _dateTime = DateFormat.yMMMd().add_jm(); // Jan 5, 2025 3:45 PM
  static final _monthYear = DateFormat.yMMM(); // Jan 2025
  static final _iso = DateFormat('yyyy-MM-dd');

  /// Short date: `Jan 5`.
  static String dateShort(DateTime d) => _dateShort.format(d);

  /// Full date: `Jan 5, 2025`.
  static String dateFull(DateTime d) => _dateFull.format(d);

  /// Time only: `3:45 PM`.
  static String time(DateTime d) => _time.format(d);

  /// Date + time: `Jan 5, 2025 3:45 PM`.
  static String dateTime(DateTime d) => _dateTime.format(d);

  /// Month + year: `Jan 2025`.
  static String monthYear(DateTime d) => _monthYear.format(d);

  /// ISO 8601 date: `2025-01-05`.
  static String iso(DateTime d) => _iso.format(d);

  // ── Relative Time ────────────────────────────────────────────

  /// Human-readable relative time string.
  ///
  /// Examples: `just now`, `2 min ago`, `3 hours ago`, `yesterday`, `Jan 5`.
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative) return _dateShort.format(dateTime);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    return _dateShort.format(dateTime);
  }

  // ── Card Number Masking ──────────────────────────────────────

  /// Masks a card number showing only the last 4 digits.
  ///
  /// `'5234567890123456'` -> `'**** **** **** 3456'`.
  /// Handles any length gracefully.
  static String maskCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;

    final lastFour = digits.substring(digits.length - 4);
    return '**** **** **** $lastFour';
  }

  /// Formats a raw digit string into groups of four.
  ///
  /// `'1234567890123456'` -> `'1234 5678 9012 3456'`.
  static String groupCardDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // ── Miscellaneous ────────────────────────────────────────────

  /// Truncate text with ellipsis if it exceeds [maxLength].
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 1)}\u2026'; // unicode ellipsis
  }

  /// Formats a percentage value: `0.142` -> `14.2%`.
  static String percentage(double value, {int decimals = 1}) =>
      '${(value * 100).toStringAsFixed(decimals)}%';

  /// Ordinal suffix: `1` -> `1st`, `22` -> `22nd`.
  static String ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }

  /// Formats a phone number from digits: `1234567890` -> `(123) 456-7890`.
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return raw; // return unformatted if unknown structure
  }
}
