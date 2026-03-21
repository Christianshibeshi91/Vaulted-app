import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/utils/formatters.dart';

void main() {
  // ── Currency ────────────────────────────────────────────────────

  group('Formatters.currency', () {
    test('formats positive amount with two decimals', () {
      expect(Formatters.currency(1234.56), '\$1,234.56');
    });

    test('formats zero', () {
      expect(Formatters.currency(0), '\$0.00');
    });

    test('formats negative amount', () {
      expect(Formatters.currency(-42.10), '-\$42.10');
    });

    test('formats small decimal', () {
      expect(Formatters.currency(0.99), '\$0.99');
    });

    test('formats large amount with commas', () {
      expect(Formatters.currency(1000000), '\$1,000,000.00');
    });
  });

  group('Formatters.currencyWhole', () {
    test('formats without decimal places', () {
      expect(Formatters.currencyWhole(1234.56), '\$1,235');
    });

    test('formats zero', () {
      expect(Formatters.currencyWhole(0), '\$0');
    });
  });

  group('Formatters.currencyCompact', () {
    test('formats thousands as K', () {
      final result = Formatters.currencyCompact(1200);
      expect(result, contains('\$'));
      expect(result, contains('K'));
    });

    test('formats millions as M', () {
      final result = Formatters.currencyCompact(3400000);
      expect(result, contains('\$'));
      expect(result, contains('M'));
    });

    test('formats small values without suffix', () {
      final result = Formatters.currencyCompact(50);
      expect(result, contains('\$'));
    });
  });

  group('Formatters.currencyFromCents', () {
    test('converts cents to dollar format', () {
      expect(Formatters.currencyFromCents(12350), '\$123.50');
    });

    test('converts zero cents', () {
      expect(Formatters.currencyFromCents(0), '\$0.00');
    });

    test('converts single cent', () {
      expect(Formatters.currencyFromCents(1), '\$0.01');
    });
  });

  group('Formatters.currencySigned', () {
    test('adds + prefix for positive amount', () {
      expect(Formatters.currencySigned(50.00), '+\$50.00');
    });

    test('shows - prefix for negative amount', () {
      expect(Formatters.currencySigned(-12.34), '-\$12.34');
    });

    test('adds + prefix for zero', () {
      expect(Formatters.currencySigned(0), '+\$0.00');
    });
  });

  // ── Dates ───────────────────────────────────────────────────────

  group('Formatters date methods', () {
    final testDate = DateTime(2025, 1, 5, 15, 45);

    test('dateShort formats as month abbreviation + day', () {
      final result = Formatters.dateShort(testDate);
      expect(result, contains('Jan'));
      expect(result, contains('5'));
    });

    test('dateFull formats with year', () {
      final result = Formatters.dateFull(testDate);
      expect(result, contains('Jan'));
      expect(result, contains('5'));
      expect(result, contains('2025'));
    });

    test('time formats as hour:minute AM/PM', () {
      final result = Formatters.time(testDate);
      expect(result, contains('3'));
      expect(result, contains('45'));
      expect(result, contains('PM'));
    });

    test('dateTime includes both date and time', () {
      final result = Formatters.dateTime(testDate);
      expect(result, contains('Jan'));
      expect(result, contains('2025'));
      expect(result, contains('PM'));
    });

    test('monthYear formats as month abbreviation + year', () {
      final result = Formatters.monthYear(testDate);
      expect(result, contains('Jan'));
      expect(result, contains('2025'));
    });

    test('iso formats as yyyy-MM-dd', () {
      expect(Formatters.iso(testDate), '2025-01-05');
    });
  });

  // ── Relative Time ──────────────────────────────────────────────

  group('Formatters.relativeTime', () {
    test('returns "just now" for less than 60 seconds ago', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 30));
      expect(Formatters.relativeTime(recent), 'just now');
    });

    test('returns minutes ago for 1-59 minutes', () {
      final minutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(Formatters.relativeTime(minutesAgo), '5 mins ago');
    });

    test('returns singular "min" for exactly 1 minute', () {
      final oneMin = DateTime.now().subtract(const Duration(minutes: 1));
      expect(Formatters.relativeTime(oneMin), '1 min ago');
    });

    test('returns hours ago for 1-23 hours', () {
      final hoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      expect(Formatters.relativeTime(hoursAgo), '3 hours ago');
    });

    test('returns singular "hour" for exactly 1 hour', () {
      final oneHour = DateTime.now().subtract(const Duration(hours: 1));
      expect(Formatters.relativeTime(oneHour), '1 hour ago');
    });

    test('returns "yesterday" for exactly 1 day ago', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(Formatters.relativeTime(yesterday), 'yesterday');
    });

    test('returns "X days ago" for 2-6 days', () {
      final threeDays = DateTime.now().subtract(const Duration(days: 3));
      expect(Formatters.relativeTime(threeDays), '3 days ago');
    });

    test('returns short date for 7+ days ago', () {
      final weekAgo = DateTime.now().subtract(const Duration(days: 10));
      final result = Formatters.relativeTime(weekAgo);
      // Should be a formatted date string, not a relative string
      expect(result, isNot(contains('ago')));
    });

    test('returns short date for future dates', () {
      final future = DateTime.now().add(const Duration(days: 5));
      final result = Formatters.relativeTime(future);
      expect(result, isNot(contains('ago')));
    });
  });

  // ── Card Number Masking ────────────────────────────────────────

  group('Formatters.maskCardNumber', () {
    test('masks 16-digit card showing last 4', () {
      expect(
        Formatters.maskCardNumber('5234567890123456'),
        '**** **** **** 3456',
      );
    });

    test('masks card with spaces', () {
      expect(
        Formatters.maskCardNumber('5234 5678 9012 3456'),
        '**** **** **** 3456',
      );
    });

    test('returns digits unchanged when 4 or fewer', () {
      expect(Formatters.maskCardNumber('1234'), '1234');
    });

    test('returns digits unchanged for empty string', () {
      expect(Formatters.maskCardNumber(''), '');
    });

    test('handles 13-digit cards', () {
      expect(
        Formatters.maskCardNumber('1234567890123'),
        '**** **** **** 0123',
      );
    });
  });

  group('Formatters.groupCardDigits', () {
    test('groups 16 digits into fours', () {
      expect(
        Formatters.groupCardDigits('1234567890123456'),
        '1234 5678 9012 3456',
      );
    });

    test('handles partial input', () {
      expect(Formatters.groupCardDigits('12345'), '1234 5');
    });

    test('strips non-digit input', () {
      expect(
        Formatters.groupCardDigits('1234-5678-9012-3456'),
        '1234 5678 9012 3456',
      );
    });

    test('handles empty string', () {
      expect(Formatters.groupCardDigits(''), '');
    });
  });

  // ── Miscellaneous ──────────────────────────────────────────────

  group('Formatters.truncate', () {
    test('returns original text when within limit', () {
      expect(Formatters.truncate('short', 10), 'short');
    });

    test('truncates and adds ellipsis when exceeding limit', () {
      final result = Formatters.truncate('this is a long string', 10);
      expect(result.length, 10);
      expect(result, endsWith('\u2026'));
    });

    test('returns original text at exact limit', () {
      expect(Formatters.truncate('exact', 5), 'exact');
    });
  });

  group('Formatters.percentage', () {
    test('formats decimal as percentage', () {
      expect(Formatters.percentage(0.142), '14.2%');
    });

    test('formats zero', () {
      expect(Formatters.percentage(0), '0.0%');
    });

    test('formats 100%', () {
      expect(Formatters.percentage(1.0), '100.0%');
    });

    test('respects custom decimal places', () {
      expect(Formatters.percentage(0.1234, decimals: 2), '12.34%');
    });
  });

  group('Formatters.ordinal', () {
    test('returns 1st for 1', () {
      expect(Formatters.ordinal(1), '1st');
    });

    test('returns 2nd for 2', () {
      expect(Formatters.ordinal(2), '2nd');
    });

    test('returns 3rd for 3', () {
      expect(Formatters.ordinal(3), '3rd');
    });

    test('returns 4th for 4', () {
      expect(Formatters.ordinal(4), '4th');
    });

    test('returns 11th for 11 (special case)', () {
      expect(Formatters.ordinal(11), '11th');
    });

    test('returns 12th for 12 (special case)', () {
      expect(Formatters.ordinal(12), '12th');
    });

    test('returns 13th for 13 (special case)', () {
      expect(Formatters.ordinal(13), '13th');
    });

    test('returns 21st for 21', () {
      expect(Formatters.ordinal(21), '21st');
    });

    test('returns 22nd for 22', () {
      expect(Formatters.ordinal(22), '22nd');
    });

    test('returns 111th for 111 (special case)', () {
      expect(Formatters.ordinal(111), '111th');
    });
  });

  group('Formatters.phone', () {
    test('formats 10-digit number with parens and dash', () {
      expect(Formatters.phone('1234567890'), '(123) 456-7890');
    });

    test('formats 11-digit number starting with 1', () {
      expect(Formatters.phone('11234567890'), '+1 (123) 456-7890');
    });

    test('strips non-digit characters before formatting', () {
      expect(Formatters.phone('(123) 456-7890'), '(123) 456-7890');
    });

    test('returns raw input for unrecognized format', () {
      expect(Formatters.phone('12345'), '12345');
    });
  });
}
