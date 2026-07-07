import '../../domain/entities/retailer_config.dart';
import '../../../../core/utils/card_number_validator.dart';

/// Generates JavaScript injection templates for balance checking.
///
/// SECURITY: All card credentials are sanitized (digits-only) before
/// interpolation into JS templates to prevent XSS/injection attacks.
abstract final class JavaScriptBridge {
  /// Channel name used to communicate results back to Flutter.
  static const channelName = 'BalanceChannel';

  /// Message prefixes for parsing channel messages.
  static const balancePrefix = 'BALANCE:';
  static const captchaMessage = 'CAPTCHA_REQUIRED';
  static const errorPrefix = 'ERROR:';

  /// Generates the auto-fill + submit + watch JavaScript for a retailer.
  ///
  /// [cardNumber] and [pin] are sanitized to digits-only before injection.
  static String buildAutoFillScript({
    required RetailerConfig config,
    required String cardNumber,
    required String pin,
  }) {
    // CRITICAL: Sanitize inputs to prevent JS injection
    final safeCardNumber = CardNumberValidator.sanitize(cardNumber);
    final safePin = CardNumberValidator.sanitize(pin);

    final cardSelector = _escapeJs(config.cardNumberSelector ?? '');
    final pinSelector = _escapeJs(config.pinSelector ?? '');
    final submitSelector = _escapeJs(config.submitSelector ?? '');
    final balanceSelector = _escapeJs(config.balanceResultSelector ?? '');
    final captchaSelector = _escapeJs(config.captchaSelector ?? '');

    return '''
(function() {
  'use strict';

  function postMessage(msg) {
    if (window.$channelName) {
      window.$channelName.postMessage(msg);
    }
  }

  var cardInput = document.querySelector('$cardSelector');
  var pinInput = document.querySelector('$pinSelector');
  var submitBtn = document.querySelector('$submitSelector');

  if (!cardInput) {
    postMessage('${errorPrefix}CARD_FIELD_NOT_FOUND');
    return;
  }

  var nativeSetter = Object.getOwnPropertyDescriptor(
    window.HTMLInputElement.prototype, 'value'
  ).set;

  nativeSetter.call(cardInput, '$safeCardNumber');
  cardInput.dispatchEvent(new Event('input', { bubbles: true }));
  cardInput.dispatchEvent(new Event('change', { bubbles: true }));
  cardInput.dispatchEvent(new Event('blur', { bubbles: true }));

  if (pinInput && '$safePin'.length > 0) {
    nativeSetter.call(pinInput, '$safePin');
    pinInput.dispatchEvent(new Event('input', { bubbles: true }));
    pinInput.dispatchEvent(new Event('change', { bubbles: true }));
    pinInput.dispatchEvent(new Event('blur', { bubbles: true }));
  }

  setTimeout(function() {
    if (submitBtn) {
      submitBtn.click();
    }
    startBalanceWatch();
  }, 500);

  function startBalanceWatch() {
    var attempts = 0;
    var maxAttempts = 40;
    var interval = setInterval(function() {
      attempts++;

      var captcha = document.querySelector('$captchaSelector');
      if (captcha && captcha.offsetParent !== null) {
        clearInterval(interval);
        postMessage('$captchaMessage');
        waitForBalanceAfterCaptcha();
        return;
      }

      var balanceEl = document.querySelector('$balanceSelector');
      if (balanceEl && balanceEl.innerText.trim().length > 0) {
        var text = balanceEl.innerText.trim();
        if (text.match(/\\d/)) {
          clearInterval(interval);
          postMessage('$balancePrefix' + text);
          return;
        }
      }

      var errorEl = document.querySelector('.error-message, .alert-danger, .alert-error, [class*="error"]');
      if (errorEl && errorEl.innerText.toLowerCase().indexOf('invalid') >= 0) {
        clearInterval(interval);
        postMessage('${errorPrefix}INVALID_CARD');
        return;
      }

      if (attempts >= maxAttempts) {
        clearInterval(interval);
        postMessage('${errorPrefix}TIMEOUT');
      }
    }, 500);
  }

  function waitForBalanceAfterCaptcha() {
    var attempts = 0;
    var interval = setInterval(function() {
      attempts++;
      var balanceEl = document.querySelector('$balanceSelector');
      if (balanceEl && balanceEl.innerText.trim().length > 0) {
        var text = balanceEl.innerText.trim();
        if (text.match(/\\d/)) {
          clearInterval(interval);
          postMessage('$balancePrefix' + text);
        }
      }
      if (attempts >= 60) {
        clearInterval(interval);
        postMessage('${errorPrefix}CAPTCHA_TIMEOUT');
      }
    }, 500);
  }
})();
''';
  }

  /// JavaScript to hide the retailer's chrome (header, footer, nav)
  /// when showing the CAPTCHA overlay.
  static String get hideRetailerChromeScript => '''
(function() {
  var selectors = ['header', 'footer', 'nav', '.navbar', '.site-header',
    '.site-footer', '.top-bar', '#header', '#footer', '.cookie-banner',
    '[class*="cookie"]', '[class*="banner"]'];
  selectors.forEach(function(sel) {
    var els = document.querySelectorAll(sel);
    els.forEach(function(el) { el.style.display = 'none'; });
  });
  document.body.style.paddingTop = '0';
  document.body.style.marginTop = '0';
})();
''';

  /// Parses a message from the BalanceChannel.
  static ChannelMessage parseMessage(String message) {
    if (message.startsWith(balancePrefix)) {
      return ChannelMessage.balance(message.substring(balancePrefix.length));
    }
    if (message == captchaMessage) {
      return ChannelMessage.captcha();
    }
    if (message.startsWith(errorPrefix)) {
      return ChannelMessage.error(message.substring(errorPrefix.length));
    }
    return ChannelMessage.error('UNKNOWN: $message');
  }

  /// Escapes a string for safe use inside JS single-quoted strings.
  static String _escapeJs(String value) =>
      value.replaceAll("'", "\\'").replaceAll('\n', '\\n');
}

/// Parsed message from the JavaScript balance channel.
sealed class ChannelMessage {
  const ChannelMessage();

  factory ChannelMessage.balance(String rawText) = BalanceMessage;
  factory ChannelMessage.captcha() = CaptchaMessage;
  factory ChannelMessage.error(String code) = ErrorMessage;
}

final class BalanceMessage extends ChannelMessage {
  const BalanceMessage(this.rawText);
  final String rawText;
}

final class CaptchaMessage extends ChannelMessage {
  const CaptchaMessage();
}

final class ErrorMessage extends ChannelMessage {
  const ErrorMessage(this.code);
  final String code;
}
