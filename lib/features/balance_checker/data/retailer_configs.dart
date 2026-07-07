import '../domain/entities/retailer_config.dart';

/// Hard-coded retailer configs for the 10 launch retailers.
///
/// These are the initial configs. In production, they're synced from
/// Firestore `retailer_configs/` collection and override these defaults.
/// This allows updating selectors without an app store release.
abstract final class RetailerConfigs {
  // ── Phase 1: WebView auto-fill (public balance check pages) ───

  static const visaPrepaid = RetailerConfig(
    id: 'visa_prepaid',
    name: 'Visa Prepaid',
    brandColor: '#1A1F71',
    balanceCheckUrl: 'https://www.vanillagift.com/check-balance',
    phase: RetailerPhase.webview,
    cardNumberLength: 16,
    pinLength: 3,
    pinRequired: true,
    cardNumberSelector: '#CardNumber, input[name="CardNumber"], input[id*="card" i]',
    pinSelector: '#Cvv, input[name="Cvv"], input[id*="cvv" i], input[id*="pin" i]',
    submitSelector: '#CheckBalance, button[type="submit"], input[type="submit"]',
    balanceResultSelector: '.balance-amount, .card-balance, [class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="recaptcha"], iframe[src*="captcha"]',
  );

  static const target = RetailerConfig(
    id: 'target',
    name: 'Target',
    brandColor: '#CC0000',
    balanceCheckUrl: 'https://www.target.com/guest/gift-card-balance',
    phase: RetailerPhase.webview,
    cardNumberLength: 15,
    pinLength: 8,
    pinRequired: true,
    cardNumberSelector: '#cardNumber, input[name="cardNumber"], input[data-test*="card-number"]',
    pinSelector: '#cardPin, input[name="accessNumber"], input[data-test*="access-number"]',
    submitSelector: 'button[type="submit"], button[data-test="check-balance-btn"], button[data-test*="submit"]',
    balanceResultSelector: '[data-test="balance-value"], [data-test*="balance"], .CardBalance, [class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="recaptcha"], iframe[src*="captcha"]',
  );

  static const nike = RetailerConfig(
    id: 'nike',
    name: 'Nike',
    brandColor: '#111111',
    balanceCheckUrl: 'https://www.nike.com/gift-cards',
    phase: RetailerPhase.webview,
    cardNumberLength: 16,
    pinLength: 4,
    pinRequired: true,
    cardNumberSelector: 'input[name="cardNumber"], input[id*="card" i], input[placeholder*="card" i]',
    pinSelector: 'input[name="pin"], input[id*="pin" i], input[placeholder*="pin" i]',
    submitSelector: 'button[type="submit"], button[class*="check" i], button[class*="balance" i]',
    balanceResultSelector: '.balance-result, .gift-card-balance, [data-testid="balance"], [class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="recaptcha"], iframe[src*="captcha"]',
  );

  static const sephora = RetailerConfig(
    id: 'sephora',
    name: 'Sephora',
    brandColor: '#000000',
    balanceCheckUrl: 'https://www.sephora.com/beauty/giftcards',
    phase: RetailerPhase.webview,
    cardNumberLength: 16,
    pinLength: 4,
    pinRequired: true,
    cardNumberSelector: 'input[name="giftCardNumber"], input[id*="giftCard" i], input[placeholder*="card" i]',
    pinSelector: 'input[name="giftCardPin"], input[id*="giftCardPin" i], input[placeholder*="pin" i]',
    submitSelector: 'button[type="submit"], button[class*="check" i], button[data-at*="check" i]',
    balanceResultSelector: '[data-comp="Balance"], [class*="balance" i], .gift-card-balance',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="recaptcha"], iframe[src*="captcha"]',
  );

  static const bestBuy = RetailerConfig(
    id: 'best_buy',
    name: 'Best Buy',
    brandColor: '#0046BE',
    balanceCheckUrl: 'https://www.bestbuy.com/gift-card-balance',
    phase: RetailerPhase.webview,
    cardNumberLength: 16,
    pinLength: 4,
    pinRequired: true,
    cardNumberSelector: '#cardNumber, input[name="cardNumber"], input[id*="card" i]',
    pinSelector: '#pin, input[name="pin"], input[id*="pin" i]',
    submitSelector: 'button[type="submit"], button[class*="check" i], .check-balance-button',
    balanceResultSelector: '.balance-value, .gift-card-balance, [data-testid="balance"], [class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="recaptcha"], iframe[src*="captcha"]',
  );

  // ── Phase 2: Login-required retailers ─────────────────────────
  // These have balance check pages but require authentication.
  // The WebView will attempt to load the page; if it hits a login
  // wall, the user gets a clear message + manual entry fallback.

  static const amazon = RetailerConfig(
    id: 'amazon',
    name: 'Amazon',
    brandColor: '#FF9900',
    balanceCheckUrl: 'https://www.amazon.com/gc/balance',
    phase: RetailerPhase.redirect,
    cardNumberLength: 0, // variable length
    pinLength: 0,
    pinRequired: false,
    cardNumberSelector: 'input[name="claimCode"], input[id*="claim" i], input[placeholder*="claim" i]',
    pinSelector: null,
    submitSelector: 'button[type="submit"], input[type="submit"]',
    balanceResultSelector: '[class*="balance" i], #gc-balance, .a-size-medium',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="captcha"], img[src*="captcha"]',
  );

  static const starbucks = RetailerConfig(
    id: 'starbucks',
    name: 'Starbucks',
    brandColor: '#00704A',
    balanceCheckUrl: 'https://www.starbucks.com/card',
    phase: RetailerPhase.redirect,
    cardNumberLength: 16,
    pinLength: 8,
    pinRequired: true,
    cardNumberSelector: 'input[name="cardNumber"], input[id*="card" i]',
    pinSelector: 'input[name="securityCode"], input[id*="security" i], input[id*="pin" i]',
    submitSelector: 'button[type="submit"]',
    balanceResultSelector: '[class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="captcha"]',
  );

  static const walmart = RetailerConfig(
    id: 'walmart',
    name: 'Walmart',
    brandColor: '#0071CE',
    balanceCheckUrl: 'https://www.walmart.com/account/gift-cards',
    phase: RetailerPhase.redirect,
    cardNumberLength: 16,
    pinLength: 4,
    pinRequired: true,
    cardNumberSelector: 'input[name="cardNumber"], input[id*="card" i]',
    pinSelector: 'input[name="pin"], input[id*="pin" i]',
    submitSelector: 'button[type="submit"]',
    balanceResultSelector: '[class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="captcha"]',
  );

  static const apple = RetailerConfig(
    id: 'apple',
    name: 'Apple',
    brandColor: '#A2AAAD',
    balanceCheckUrl: 'https://checkcoverage.apple.com',
    phase: RetailerPhase.redirect,
    cardNumberLength: 0,
    pinLength: 0,
    pinRequired: false,
    cardNumberSelector: 'input[name="serialNumber"], input[id*="serial" i]',
    pinSelector: null,
    submitSelector: 'button[type="submit"], input[type="submit"]',
    balanceResultSelector: '[class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="captcha"]',
  );

  static const googlePlay = RetailerConfig(
    id: 'google_play',
    name: 'Google Play',
    brandColor: '#4285F4',
    balanceCheckUrl: 'https://play.google.com/store/account',
    phase: RetailerPhase.redirect,
    cardNumberLength: 0,
    pinLength: 0,
    pinRequired: false,
    cardNumberSelector: 'input[name="code"], input[id*="code" i]',
    pinSelector: null,
    submitSelector: 'button[type="submit"]',
    balanceResultSelector: '[class*="balance" i]',
    captchaSelector: '.g-recaptcha, .cf-turnstile, iframe[src*="captcha"]',
  );

  /// All supported retailers.
  static const List<RetailerConfig> all = [
    visaPrepaid,
    target,
    nike,
    sephora,
    bestBuy,
    amazon,
    starbucks,
    walmart,
    apple,
    googlePlay,
  ];

  /// Phase 1 retailers that support WebView auto-fill.
  static List<RetailerConfig> get webviewRetailers =>
      all.where((c) => c.supportsWebView).toList();

  /// Phase 2 retailers that require login.
  static List<RetailerConfig> get loginRequiredRetailers =>
      all.where((c) => c.requiresRedirect).toList();

  /// Look up a config by retailer ID. Returns `null` if not found.
  static RetailerConfig? byId(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Look up a config by retailer name (case-insensitive).
  static RetailerConfig? byName(String name) {
    final lower = name.toLowerCase();
    try {
      return all.firstWhere((c) => c.name.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }
}
