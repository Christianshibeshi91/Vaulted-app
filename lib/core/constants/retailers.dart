import 'package:flutter/material.dart';

/// A known gift-card retailer with its brand color.
class Retailer {
  const Retailer({required this.name, required this.color});

  final String name;
  final Color color;

  /// Slug-safe lowercase identifier derived from [name].
  String get id => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
}

/// Predefined retailer catalog used across the Vaulted app.
///
/// Sorted alphabetically for quick look-up; use [byName] for O(1) access.
abstract final class Retailers {
  // ── Catalog ──────────────────────────────────────────────────

  static const amazon = Retailer(name: 'Amazon', color: Color(0xFFFF9900));
  static const apple = Retailer(name: 'Apple', color: Color(0xFFA2AAAD));
  static const bestBuy = Retailer(name: 'Best Buy', color: Color(0xFF0046BE));
  static const chevron = Retailer(name: 'Chevron', color: Color(0xFF0054A6));
  static const chipotle = Retailer(name: 'Chipotle', color: Color(0xFFA81612));
  static const costco = Retailer(name: 'Costco', color: Color(0xFFE31837));
  static const deltaAirlines =
      Retailer(name: 'Delta Airlines', color: Color(0xFF003366));
  static const doordash = Retailer(name: 'DoorDash', color: Color(0xFFFF3008));
  static const dunkinDonuts =
      Retailer(name: 'Dunkin\' Donuts', color: Color(0xFFFF671F));
  static const ebay = Retailer(name: 'eBay', color: Color(0xFFE53238));
  static const exxonMobil =
      Retailer(name: 'ExxonMobil', color: Color(0xFFED1C24));
  static const google = Retailer(name: 'Google', color: Color(0xFF4285F4));
  static const grubhub = Retailer(name: 'Grubhub', color: Color(0xFFF63440));
  static const homeDepot =
      Retailer(name: 'Home Depot', color: Color(0xFFF96302));
  static const instacart =
      Retailer(name: 'Instacart', color: Color(0xFF43B02A));
  static const kohls = Retailer(name: 'Kohl\'s', color: Color(0xFF000000));
  static const lowes = Retailer(name: 'Lowe\'s', color: Color(0xFF004990));
  static const macys = Retailer(name: 'Macy\'s', color: Color(0xFFE21A2C));
  static const mastercard =
      Retailer(name: 'Mastercard', color: Color(0xFFEB001B));
  static const netflix = Retailer(name: 'Netflix', color: Color(0xFFE50914));
  static const nike = Retailer(name: 'Nike', color: Color(0xFF111111));
  static const nordstrom =
      Retailer(name: 'Nordstrom', color: Color(0xFF000000));
  static const playStation =
      Retailer(name: 'PlayStation', color: Color(0xFF003087));
  static const sephora = Retailer(name: 'Sephora', color: Color(0xFF000000));
  static const spotify = Retailer(name: 'Spotify', color: Color(0xFF1DB954));
  static const starbucks =
      Retailer(name: 'Starbucks', color: Color(0xFF00704A));
  static const steam = Retailer(name: 'Steam', color: Color(0xFF1B2838));
  static const target = Retailer(name: 'Target', color: Color(0xFFCC0000));
  static const uberEats =
      Retailer(name: 'Uber Eats', color: Color(0xFF06C167));
  static const visa = Retailer(name: 'Visa', color: Color(0xFF1A1F71));
  static const walmart = Retailer(name: 'Walmart', color: Color(0xFF0071CE));
  static const wholefoods =
      Retailer(name: 'Whole Foods', color: Color(0xFF00674B));
  static const xbox = Retailer(name: 'Xbox', color: Color(0xFF107C10));

  /// All retailers as an unmodifiable list (alphabetical).
  static const List<Retailer> all = [
    amazon,
    apple,
    bestBuy,
    chevron,
    chipotle,
    costco,
    deltaAirlines,
    doordash,
    dunkinDonuts,
    ebay,
    exxonMobil,
    google,
    grubhub,
    homeDepot,
    instacart,
    kohls,
    lowes,
    macys,
    mastercard,
    netflix,
    nike,
    nordstrom,
    playStation,
    sephora,
    spotify,
    starbucks,
    steam,
    target,
    uberEats,
    visa,
    walmart,
    wholefoods,
    xbox,
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
