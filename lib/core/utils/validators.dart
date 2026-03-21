/// Input validation utilities.
///
/// Every method returns `null` on success or an error message [String] on failure,
/// matching Flutter's `TextFormField.validator` signature.
abstract final class Validators {
  // ── Email ────────────────────────────────────────────────────

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  // ── Password ─────────────────────────────────────────────────

  /// Validates password with minimum requirements.
  ///
  /// Requirements: 8+ chars, uppercase, lowercase, digit, special char.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must include an uppercase letter';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Must include a lowercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must include a number';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Must include a special character';
    }
    return null;
  }

  /// Checks password confirmation matches.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Returns a password strength score from 0 (worst) to 4 (best).
  ///
  /// 0 = too short, 1 = weak, 2 = fair, 3 = strong, 4 = very strong.
  static int passwordStrength(String value) {
    if (value.length < 8) return 0;

    var score = 0;
    if (value.length >= 12) score++;
    if (value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    return score;
  }

  /// Human-readable label for a [passwordStrength] score.
  static String passwordStrengthLabel(int score) => switch (score) {
        0 => 'Too short',
        1 => 'Weak',
        2 => 'Fair',
        3 => 'Strong',
        4 => 'Very strong',
        _ => '',
      };

  // ── Card Number ──────────────────────────────────────────────

  /// Validates a gift card / payment card number using Luhn algorithm.
  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Card number is required';

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) {
      return 'Card number must be 13-19 digits';
    }
    if (!_luhnCheck(digits)) return 'Invalid card number';
    return null;
  }

  /// Luhn algorithm check.
  static bool _luhnCheck(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  // ── General ──────────────────────────────────────────────────

  /// Non-empty required field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Minimum length check.
  static String? minLength(String? value, int min,
      [String fieldName = 'This field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Maximum length check.
  static String? maxLength(String? value, int max,
      [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Validates a PIN code (digits only, exact length).
  static String? pin(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length != length) return 'PIN must be $length digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'PIN must contain only digits';
    return null;
  }

  /// Validates a monetary amount string.
  static String? amount(String? value, {double min = 0.01, double? max}) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';

    final cleaned = value.replaceAll(RegExp(r'[,$\s]'), '');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return 'Enter a valid amount';
    if (parsed < min) return 'Minimum amount is \$${min.toStringAsFixed(2)}';
    if (max != null && parsed > max) {
      return 'Maximum amount is \$${max.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Validates a US phone number (10 digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 &&
        !(digits.length == 11 && digits.startsWith('1'))) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  /// URL validation.
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return 'URL is required';
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid URL';
    }
    return null;
  }
}
