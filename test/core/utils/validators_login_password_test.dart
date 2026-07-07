import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/utils/validators.dart';

void main() {
  group('Validators.loginPassword', () {
    test('returns null for any non-empty value', () {
      expect(Validators.loginPassword('a'), isNull);
      expect(Validators.loginPassword('password'), isNull);
      expect(Validators.loginPassword('12345678'), isNull);
      expect(Validators.loginPassword('P@ss!'), isNull);
      expect(Validators.loginPassword(' '), isNull);
      expect(Validators.loginPassword('a very long password with spaces and symbols!@#'),
          isNull);
    });

    test('returns error for null', () {
      expect(Validators.loginPassword(null), 'Password is required');
    });

    test('returns error for empty string', () {
      expect(Validators.loginPassword(''), 'Password is required');
    });
  });
}
