import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/utils/validators.dart';

void main() {
  // ── Email ────────────────────────────────────────────────────────

  group('Validators.email', () {
    test('returns null for valid standard email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain', () {
      expect(Validators.email('user@mail.example.com'), isNull);
    });

    test('returns null for email with plus addressing', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });

    test('returns null for email with dots in local part', () {
      expect(Validators.email('first.last@example.com'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.email(null), 'Email is required');
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns error for whitespace only', () {
      expect(Validators.email('   '), 'Email is required');
    });

    test('returns error for missing @', () {
      expect(Validators.email('userexample.com'), 'Enter a valid email');
    });

    test('returns error for missing domain', () {
      expect(Validators.email('user@'), 'Enter a valid email');
    });

    test('returns error for missing local part', () {
      expect(Validators.email('@example.com'), 'Enter a valid email');
    });

    test('returns error for double @', () {
      expect(Validators.email('user@@example.com'), 'Enter a valid email');
    });

    test('trims whitespace before validating', () {
      expect(Validators.email('  user@example.com  '), isNull);
    });
  });

  // ── Password ─────────────────────────────────────────────────────

  group('Validators.password', () {
    test('returns null for strong password meeting all requirements', () {
      expect(Validators.password('Abcdef1!'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.password(null), 'Password is required');
    });

    test('returns error for empty', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error for too short', () {
      expect(Validators.password('Ab1!'), 'Must be at least 8 characters');
    });

    test('returns error for missing uppercase', () {
      expect(
        Validators.password('abcdefg1!'),
        'Must include an uppercase letter',
      );
    });

    test('returns error for missing lowercase', () {
      expect(
        Validators.password('ABCDEFG1!'),
        'Must include a lowercase letter',
      );
    });

    test('returns error for missing digit', () {
      expect(Validators.password('Abcdefgh!'), 'Must include a number');
    });

    test('returns error for missing special character', () {
      expect(
        Validators.password('Abcdefg1'),
        'Must include a special character',
      );
    });
  });

  // ── Confirm Password ────────────────────────────────────────────

  group('Validators.confirmPassword', () {
    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('Abc123!@', 'Abc123!@'), isNull);
    });

    test('returns error for null', () {
      expect(
        Validators.confirmPassword(null, 'Abc123!@'),
        'Confirm your password',
      );
    });

    test('returns error for empty', () {
      expect(
        Validators.confirmPassword('', 'Abc123!@'),
        'Confirm your password',
      );
    });

    test('returns error when passwords differ', () {
      expect(
        Validators.confirmPassword('Different1!', 'Abc123!@'),
        'Passwords do not match',
      );
    });
  });

  // ── Password Strength ───────────────────────────────────────────

  group('Validators.passwordStrength', () {
    test('returns 0 for password shorter than 8 characters', () {
      expect(Validators.passwordStrength('Ab1!'), 0);
    });

    test('returns 0 for empty string', () {
      expect(Validators.passwordStrength(''), 0);
    });

    test('returns 1 for 8-char lowercase+uppercase only', () {
      // 8 chars, has upper+lower = 1 point, no digits, no special
      expect(Validators.passwordStrength('Abcdefgh'), 1);
    });

    test('returns 2 for 8-char with upper+lower+digit', () {
      // upper+lower = 1, digit = 1, no special, short = total 2
      expect(Validators.passwordStrength('Abcdefg1'), 2);
    });

    test('returns 3 for 8-char with upper+lower+digit+special', () {
      expect(Validators.passwordStrength('Abcdefg1!'), 3);
    });

    test('returns 4 for 12+ char with all criteria', () {
      // length>=12 = 1, upper+lower = 1, digit = 1, special = 1 = total 4
      expect(Validators.passwordStrength('Abcdefghij1!'), 4);
    });

    test('returns 1 for 12+ char lowercase only', () {
      // length>=12 = 1, no upper+lower pair, no digit, no special = 1
      expect(Validators.passwordStrength('abcdefghijkl'), 1);
    });
  });

  // ── Password Strength Label ─────────────────────────────────────

  group('Validators.passwordStrengthLabel', () {
    test('returns "Too short" for 0', () {
      expect(Validators.passwordStrengthLabel(0), 'Too short');
    });

    test('returns "Weak" for 1', () {
      expect(Validators.passwordStrengthLabel(1), 'Weak');
    });

    test('returns "Fair" for 2', () {
      expect(Validators.passwordStrengthLabel(2), 'Fair');
    });

    test('returns "Strong" for 3', () {
      expect(Validators.passwordStrengthLabel(3), 'Strong');
    });

    test('returns "Very strong" for 4', () {
      expect(Validators.passwordStrengthLabel(4), 'Very strong');
    });

    test('returns empty string for out-of-range value', () {
      expect(Validators.passwordStrengthLabel(5), '');
      expect(Validators.passwordStrengthLabel(-1), '');
    });
  });

  // ── Card Number ─────────────────────────────────────────────────

  group('Validators.cardNumber', () {
    test('returns null for valid Luhn number (Visa test card)', () {
      expect(Validators.cardNumber('4111111111111111'), isNull);
    });

    test('returns null for valid number with spaces', () {
      expect(Validators.cardNumber('4111 1111 1111 1111'), isNull);
    });

    test('returns null for valid number with dashes', () {
      expect(Validators.cardNumber('4111-1111-1111-1111'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.cardNumber(null), 'Card number is required');
    });

    test('returns error for empty', () {
      expect(Validators.cardNumber(''), 'Card number is required');
    });

    test('returns error for whitespace only', () {
      expect(Validators.cardNumber('   '), 'Card number is required');
    });

    test('returns error for too few digits', () {
      expect(
        Validators.cardNumber('123456789012'),
        'Card number must be 13-19 digits',
      );
    });

    test('returns error for too many digits', () {
      expect(
        Validators.cardNumber('12345678901234567890'),
        'Card number must be 13-19 digits',
      );
    });

    test('returns error for invalid Luhn check digit', () {
      expect(Validators.cardNumber('4111111111111112'), 'Invalid card number');
    });

    test('strips non-digit characters before validation', () {
      // Valid Luhn with embedded alpha -- only digits count
      expect(Validators.cardNumber('4111 1111 1111 1111'), isNull);
    });
  });

  // ── Required ────────────────────────────────────────────────────

  group('Validators.required', () {
    test('returns null for non-empty value', () {
      expect(Validators.required('hello'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.required(null), 'This field is required');
    });

    test('returns error for empty', () {
      expect(Validators.required(''), 'This field is required');
    });

    test('returns error for whitespace only', () {
      expect(Validators.required('   '), 'This field is required');
    });

    test('uses custom field name in error message', () {
      expect(Validators.required(null, 'Username'), 'Username is required');
    });
  });

  // ── Min / Max Length ────────────────────────────────────────────

  group('Validators.minLength', () {
    test('returns null when length meets minimum', () {
      expect(Validators.minLength('hello', 5), isNull);
    });

    test('returns null when length exceeds minimum', () {
      expect(Validators.minLength('hello world', 5), isNull);
    });

    test('returns error when too short', () {
      expect(
        Validators.minLength('hi', 5),
        'This field must be at least 5 characters',
      );
    });

    test('returns error for null', () {
      expect(
        Validators.minLength(null, 3),
        'This field must be at least 3 characters',
      );
    });

    test('uses custom field name', () {
      expect(
        Validators.minLength('ab', 3, 'Name'),
        'Name must be at least 3 characters',
      );
    });
  });

  group('Validators.maxLength', () {
    test('returns null when length within limit', () {
      expect(Validators.maxLength('hello', 10), isNull);
    });

    test('returns null for null value', () {
      expect(Validators.maxLength(null, 10), isNull);
    });

    test('returns error when too long', () {
      expect(
        Validators.maxLength('hello world', 5),
        'This field must be at most 5 characters',
      );
    });

    test('uses custom field name', () {
      expect(
        Validators.maxLength('toolong', 3, 'Bio'),
        'Bio must be at most 3 characters',
      );
    });
  });

  // ── PIN ─────────────────────────────────────────────────────────

  group('Validators.pin', () {
    test('returns null for valid 6-digit PIN (default)', () {
      expect(Validators.pin('123456'), isNull);
    });

    test('returns null for valid 4-digit PIN with custom length', () {
      expect(Validators.pin('1234', length: 4), isNull);
    });

    test('returns error for null', () {
      expect(Validators.pin(null), 'PIN is required');
    });

    test('returns error for empty', () {
      expect(Validators.pin(''), 'PIN is required');
    });

    test('returns error for wrong length', () {
      expect(Validators.pin('1234'), 'PIN must be 6 digits');
    });

    test('returns error for 4-digit PIN that is too short', () {
      expect(Validators.pin('12', length: 4), 'PIN must be 4 digits');
    });

    test('returns error for non-digit characters', () {
      expect(Validators.pin('12a456'), 'PIN must contain only digits');
    });

    test('returns error for letters only', () {
      expect(Validators.pin('abcdef'), 'PIN must contain only digits');
    });
  });

  // ── Amount ──────────────────────────────────────────────────────

  group('Validators.amount', () {
    test('returns null for valid positive amount', () {
      expect(Validators.amount('10.50'), isNull);
    });

    test('returns null for minimum amount (0.01)', () {
      expect(Validators.amount('0.01'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.amount(null), 'Amount is required');
    });

    test('returns error for empty', () {
      expect(Validators.amount(''), 'Amount is required');
    });

    test('returns error for non-numeric', () {
      expect(Validators.amount('abc'), 'Enter a valid amount');
    });

    test('returns error for zero when min is 0.01', () {
      expect(
        Validators.amount('0'),
        'Minimum amount is \$0.01',
      );
    });

    test('returns error for negative amount', () {
      expect(
        Validators.amount('-5'),
        'Minimum amount is \$0.01',
      );
    });

    test('returns error when exceeding max', () {
      expect(
        Validators.amount('500', max: 100),
        'Maximum amount is \$100.00',
      );
    });

    test('returns null at exact max boundary', () {
      expect(Validators.amount('100', max: 100), isNull);
    });

    test('strips dollar signs and commas', () {
      expect(Validators.amount('\$1,234.56'), isNull);
    });

    test('respects custom min', () {
      expect(
        Validators.amount('0.50', min: 1.0),
        'Minimum amount is \$1.00',
      );
    });
  });

  // ── Phone ───────────────────────────────────────────────────────

  group('Validators.phone', () {
    test('returns null for valid 10-digit number', () {
      expect(Validators.phone('5551234567'), isNull);
    });

    test('returns null for formatted 10-digit number', () {
      expect(Validators.phone('(555) 123-4567'), isNull);
    });

    test('returns null for 11-digit number starting with 1', () {
      expect(Validators.phone('15551234567'), isNull);
    });

    test('returns null for +1 formatted number', () {
      expect(Validators.phone('+1 (555) 123-4567'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.phone(null), 'Phone number is required');
    });

    test('returns error for empty', () {
      expect(Validators.phone(''), 'Phone number is required');
    });

    test('returns error for too few digits', () {
      expect(
        Validators.phone('12345'),
        'Enter a valid 10-digit phone number',
      );
    });

    test('returns error for 11 digits not starting with 1', () {
      expect(
        Validators.phone('25551234567'),
        'Enter a valid 10-digit phone number',
      );
    });
  });

  // ── URL ─────────────────────────────────────────────────────────

  group('Validators.url', () {
    test('returns null for valid HTTPS URL', () {
      expect(Validators.url('https://example.com'), isNull);
    });

    test('returns null for valid HTTP URL', () {
      expect(Validators.url('http://example.com'), isNull);
    });

    test('returns null for URL with path', () {
      expect(Validators.url('https://example.com/path/to/page'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.url(null), 'URL is required');
    });

    test('returns error for empty', () {
      expect(Validators.url(''), 'URL is required');
    });

    test('returns error for missing scheme', () {
      expect(Validators.url('example.com'), 'Enter a valid URL');
    });

    test('returns error for just a word', () {
      expect(Validators.url('notaurl'), 'Enter a valid URL');
    });

    test('trims whitespace', () {
      expect(Validators.url('  https://example.com  '), isNull);
    });
  });
}
