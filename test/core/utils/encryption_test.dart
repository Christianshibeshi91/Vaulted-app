import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/errors/exceptions.dart';
import 'package:vaulted/core/utils/encryption.dart';
import 'package:vaulted/core/utils/secure_storage.dart';

/// Fake in-memory implementation of [SecureStorageService] for tests.
///
/// Avoids platform channel calls to flutter_secure_storage by storing
/// values in a plain [Map].
class FakeSecureStorage extends SecureStorageService {
  FakeSecureStorage() : super.forTest();

  final _store = <String, String>{};

  @override
  Future<void> write(StorageKey key, String value) async {
    _store[key.value] = value;
  }

  @override
  Future<String?> read(StorageKey key) async {
    return _store[key.value];
  }

  @override
  Future<void> delete(StorageKey key) async {
    _store.remove(key.value);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey(StorageKey key) async {
    return _store.containsKey(key.value);
  }
}

void main() {
  group('EncryptionService', () {
    late FakeSecureStorage fakeStorage;
    late EncryptionService service;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      service = EncryptionService(fakeStorage);
    });

    test('throws when encrypt is called before initialise', () {
      expect(
        () => service.encrypt('test'),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('throws when decrypt is called before initialise', () {
      expect(
        () => service.decrypt('fake:data'),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('encrypt then decrypt returns original plaintext', () async {
      await service.initialise();
      const plaintext = 'Hello, Vaulted!';
      final ciphertext = service.encrypt(plaintext);
      final decrypted = service.decrypt(ciphertext);
      expect(decrypted, plaintext);
    });

    test('encrypt produces iv:ciphertext:hmac format', () async {
      await service.initialise();
      final ciphertext = service.encrypt('test data');
      final parts = ciphertext.split(':');
      expect(parts.length, 3);
      // IV and ciphertext should be valid base64
      expect(() => base64Decode(parts[0]), returnsNormally);
      expect(() => base64Decode(parts[1]), returnsNormally);
      // HMAC should be a sha256 hex digest
      expect(parts[2], matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('different plaintexts produce different ciphertexts', () async {
      await service.initialise();
      final c1 = service.encrypt('message one');
      final c2 = service.encrypt('message two');
      expect(c1, isNot(equals(c2)));
    });

    test('same plaintext produces different ciphertexts (random IV)', () async {
      await service.initialise();
      final c1 = service.encrypt('same text');
      final c2 = service.encrypt('same text');
      expect(c1, isNot(equals(c2)));
      // But both decrypt to the same value
      expect(service.decrypt(c1), 'same text');
      expect(service.decrypt(c2), 'same text');
    });

    test('throws on empty string (AES-CBC PKCS7 limitation)', () async {
      await service.initialise();
      // The encrypt package's AES-CBC with PKCS7 padding does not support
      // encrypting an empty string -- this documents that known limitation.
      expect(() => service.encrypt(''), throwsA(isA<RangeError>()));
    });

    test('handles special characters and unicode', () async {
      await service.initialise();
      const special = 'P@ssw0rd!#\$%^&*() emoji: \u{1F512}';
      final ciphertext = service.encrypt(special);
      final decrypted = service.decrypt(ciphertext);
      expect(decrypted, special);
    });

    test('handles long strings', () async {
      await service.initialise();
      final longText = 'A' * 10000;
      final ciphertext = service.encrypt(longText);
      final decrypted = service.decrypt(ciphertext);
      expect(decrypted, longText);
    });

    test('throws on malformed ciphertext without colon separator', () async {
      await service.initialise();
      expect(
        () => service.decrypt('malformed_no_colon'),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('throws when ciphertext HMAC has been tampered with', () async {
      await service.initialise();
      final ciphertext = service.encrypt('sensitive');
      final parts = ciphertext.split(':');
      final tampered = '${parts[0]}:${parts[1]}:${'0' * 64}';

      expect(
        () => service.decrypt(tampered),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('persists key to secure storage on initialise', () async {
      await service.initialise();
      final storedKey = await fakeStorage.read(StorageKey.encryptionKey);
      expect(storedKey, isNotNull);
      expect(storedKey!.isNotEmpty, isTrue);
    });

    test('reuses existing key from storage across instances', () async {
      // Generate key with first service
      await service.initialise();
      final ciphertext = service.encrypt('roundtrip');

      // Create second service with same storage
      final service2 = EncryptionService(fakeStorage);
      await service2.initialise();

      // Should be able to decrypt with the same key
      expect(service2.decrypt(ciphertext), 'roundtrip');
    });

    test('generateKey creates a new key different from original', () async {
      await service.initialise();
      final key1 = await fakeStorage.read(StorageKey.encryptionKey);

      await service.generateKey();
      final key2 = await fakeStorage.read(StorageKey.encryptionKey);

      expect(key1, isNot(equals(key2)));
    });
  });
}
