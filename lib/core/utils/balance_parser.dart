/// Parses balance text extracted from retailer pages into a [double].
///
/// Handles formats: "$47.23", "47.23", "$1,247.23", "Balance: $47.23",
/// "Your balance is $100.00", etc.
abstract final class BalanceParser {
  /// Extracts a dollar amount from [rawText].
  ///
  /// Returns `null` if no valid amount can be parsed.
  static double? parse(String rawText) {
    if (rawText.isEmpty) return null;

    // Strip everything except digits, dots, commas, and minus sign.
    // First, try to find a dollar amount pattern in the text.
    final dollarPattern = RegExp(
      r'-?\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    );

    final match = dollarPattern.firstMatch(rawText);
    if (match == null) return null;

    final captured = match.group(1);
    if (captured == null) return null;

    // Remove commas and whitespace
    final cleaned = captured.replaceAll(',', '').trim();
    final value = double.tryParse(cleaned);

    if (value == null || value < 0) return null;

    // Round to 2 decimal places to avoid floating point issues
    return (value * 100).roundToDouble() / 100;
  }

  /// Formats a balance amount to a display string.
  static String format(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
