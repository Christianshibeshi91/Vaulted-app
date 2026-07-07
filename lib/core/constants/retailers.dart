import 'package:flutter/material.dart';

/// A known gift-card retailer with its brand color.
class Retailer {
  const Retailer({required this.name, required this.color});

  final String name;
  final Color color;

  /// Slug-safe lowercase identifier derived from [name].
  String get id => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
}

/// The 10 supported retailers in the Vaulted app.
///
/// Sorted alphabetically for quick look-up; use [byName] for O(1) access.
abstract final class Retailers {
  // ── Catalog ──────────────────────────────────────────────────

  static const amazon = Retailer(name: 'Amazon', color: Color(0xFFFF9900));
  static const apple = Retailer(name: 'Apple', color: Color(0xFFA2AAAD));
  static const bestBuy = Retailer(name: 'Best Buy', color: Color(0xFF0046BE));
  static const googlePlay =
      Retailer(name: 'Google Play', color: Color(0xFF4285F4));
  static const nike = Retailer(name: 'Nike', color: Color(0xFF111111));
  static const sephora = Retailer(name: 'Sephora', color: Color(0xFF000000));
  static const starbucks =
      Retailer(name: 'Starbucks', color: Color(0xFF00704A));
  static const target = Retailer(name: 'Target', color: Color(0xFFCC0000));
  static const visa = Retailer(name: 'Visa Prepaid', color: Color(0xFF1A1F71));
  static const walmart = Retailer(name: 'Walmart', color: Color(0xFF0071CE));

  /// All retailers as an unmodifiable list (alphabetical).
  static const List<Retailer> all = [
    amazon,
    apple,
    bestBuy,
    googlePlay,
    nike,
    sephora,
    starbucks,
    target,
    visa,
    walmart,
  ];

  /// O(1) look-up by case-insensitive name.
  static final Map<String, Retailer> _byName = {
    for (final r in all) r.name.toLowerCase(): r,
  };

  /// Find a retailer by name (case-insensitive). Returns `null` if not found.
  static Retailer? byName(String name) => _byName[name.toLowerCase()];

  /// Default brand color when retailer is unknown.
  static const fallbackColor = Color(0xFF8A8694);
}
