import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt_lib;

import '../errors/exceptions.dart';
import 'secure_storage.dart';

/// AES-256-CBC encryption service backed by [flutter_secure_storage].
///
/// Usage:
/// ```dart
/// final service = EncryptionService(SecureStorageService.instance);
/// await service.initialise(); // loads or creates key
/// final cipher = service.encrypt('sensitive data');
/// final plain  = service.decrypt(cipher);
/// ```
class EncryptionService {
  final SecureStorageService _storage;

  encrypt_lib.Key? _key;

  EncryptionService(this._storage);

  /// Must be called once before encrypt/decrypt.
  /// Loads an existing key from secure storage or generates a new one.
  Future<void> initialise() async {
    final stored = await _storage.read(StorageKey.encryptionKey);
    if (stored != null) {
      _key = encrypt_lib.Key(base64Decode(stored));
    } else {
      await generateKey();
    }
  }

  /// Generate a fresh AES-256 key and persist it in secure storage.
  Future<void> generateKey() async {
    _key = encrypt_lib.Key.fromSecureRandom(32);
    await _storage.write(
      StorageKey.encryptionKey,
      base64Encode(_key!.bytes),
    );
  }

  /// Encrypt [plaintext] and return a base-64 encoded string
  /// containing `iv:ciphertext`.
  String encrypt(String plaintext) {
    _assertReady();
    final iv = encrypt_lib.IV.fromSecureRandom(16);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(_key!, mode: encrypt_lib.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    // Store IV alongside ciphertext so decryption is self-contained.
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypt a value previously produced by [encrypt].
  String decrypt(String ciphertext) {
    _assertReady();
    final parts = ciphertext.split(':');
    if (parts.length != 2) {
      throw const EncryptionException(
        'Malformed ciphertext: expected iv:ciphertext',
      );
    }
    final iv = encrypt_lib.IV.fromBase64(parts[0]);
    final encrypted = encrypt_lib.Encrypted.fromBase64(parts[1]);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(_key!, mode: encrypt_lib.AESMode.cbc),
    );
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Verify the key has been loaded.
  void _assertReady() {
    if (_key == null) {
      throw const EncryptionException(
        'EncryptionService not initialised. Call initialise() first.',
      );
    }
  }
}
