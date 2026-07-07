import '../../../features/balance_checker/domain/entities/retailer_config.dart';

/// Validates card number and PIN formats per retailer.
abstract final class CardNumberValidator {
  /// Validates a card number for the given [config].
  ///
  /// Returns `null` if valid, or an error message string if invalid.
  static String? validateCardNumber(String cardNumber, RetailerConfig config) {
    final digits = _stripNonDigits(cardNumber);

    if (digits.isEmpty) {
      return 'Card number is required';
    }

    if (config.cardNumberLength > 0 && digits.length != config.cardNumberLength) {
      return 'Card number must be ${config.cardNumberLength} digits';
    }

    // Minimum length sanity check
    if (digits.length < 4) {
      return 'Card number is too short';
    }

    return null;
  }

  /// Validates a PIN for the given [config].
  ///
  /// Returns `null` if valid, or an error message string if invalid.
  static String? validatePin(String pin, RetailerConfig config) {
    if (!config.pinRequired && pin.isEmpty) {
      return null; // PIN not required and not provided
    }

    if (config.pinRequired && pin.isEmpty) {
      return 'PIN is required';
    }

    final digits = _stripNonDigits(pin);

    if (config.pinLength > 0 && digits.length != config.pinLength) {
      return 'PIN must be ${config.pinLength} digits';
    }

    return null;
  }

  /// Sanitizes a card number: strips non-digit characters.
  ///
  /// This MUST be called before passing to JavaScript injection
  /// to prevent XSS/injection attacks through the card number field.
  static String sanitize(String input) => _stripNonDigits(input);

  /// Returns the last 4 digits of a card number for display.
  static String maskCardNumber(String cardNumber) {
    final digits = _stripNonDigits(cardNumber);
    if (digits.length < 4) return '****';
    return '****${digits.substring(digits.length - 4)}';
  }

  static String _stripNonDigits(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');
}
