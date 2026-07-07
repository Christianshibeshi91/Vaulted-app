import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;

import '../errors/exceptions.dart';
import 'secure_storage.dart';

/// AES-256-CBC + HMAC-SHA256 (Encrypt-then-MAC) encryption service.
///
/// Provides authenticated encryption to prevent padding oracle and
/// ciphertext tampering attacks. Keys are stored in platform-secure
/// storage via [SecureStorageService].
///
/// Ciphertext format: `iv_b64:ciphertext_b64:hmac_hex`
///
/// Backwards-compatible: decrypts legacy `iv:ciphertext` format from
/// the previous CBC-only implementation.
class EncryptionService {
  final SecureStorageService _storage;

  encrypt_lib.Key? _encKey;
  encrypt_lib.Key? _legacyKey;
  List<int>? _macKey;

  EncryptionService(this._storage);

  /// Must be called once before encrypt/decrypt.
  Future<void> initialise() async {
    final stored = await _storage.read(StorageKey.encryptionKey);
    if (stored != null) {
      final masterBytes = base64Decode(stored);
      _legacyKey = encrypt_lib.Key(Uint8List.fromList(masterBytes));
      _deriveKeys(masterBytes);
    } else {
      await generateKey();
    }
  }

  /// Generate a fresh AES-256 key and persist it in secure storage.
  Future<void> generateKey() async {
    final masterKey = encrypt_lib.Key.fromSecureRandom(32);
    await _storage.write(
      StorageKey.encryptionKey,
      base64Encode(masterKey.bytes),
    );
    _legacyKey = masterKey;
    _deriveKeys(Uint8List.fromList(masterKey.bytes));
  }

  /// Derive separate encryption and MAC keys from the master key.
  void _deriveKeys(List<int> masterKey) {
    final encKeyBytes =
        Hmac(sha256, masterKey).convert(utf8.encode('enc')).bytes;
    final macKeyBytes =
        Hmac(sha256, masterKey).convert(utf8.encode('mac')).bytes;
    _encKey = encrypt_lib.Key(Uint8List.fromList(encKeyBytes));
    _macKey = macKeyBytes;
  }

  /// Encrypt [plaintext] with AES-256-CBC then authenticate with HMAC-SHA256.
  ///
  /// Returns `iv_b64:ciphertext_b64:hmac_hex`.
  String encrypt(String plaintext) {
    _assertReady();
    final iv = encrypt_lib.IV.fromSecureRandom(16);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(_encKey!, mode: encrypt_lib.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    final ivB64 = iv.base64;
    final ctB64 = encrypted.base64;

    // Encrypt-then-MAC: HMAC covers both IV and ciphertext
    final mac = Hmac(sha256, _macKey!)
        .convert(utf8.encode('$ivB64:$ctB64'))
        .toString();

    return '$ivB64:$ctB64:$mac';
  }

  /// Decrypt a value produced by [encrypt].
  ///
  /// Also accepts legacy `iv:ciphertext` format (without MAC) for
  /// backwards compatibility with existing stored data.
  String decrypt(String ciphertext) {
    _assertReady();
    final parts = ciphertext.split(':');

    if (parts.length == 3) {
      // Authenticated format: iv:ciphertext:hmac
      final ivB64 = parts[0];
      final ctB64 = parts[1];
      final storedMac = parts[2];

      final expectedMac = Hmac(sha256, _macKey!)
          .convert(utf8.encode('$ivB64:$ctB64'))
          .toString();

      if (!_constantTimeEquals(storedMac, expectedMac)) {
        throw const EncryptionException(
          'HMAC verification failed: ciphertext may have been tampered with.',
        );
      }

      final iv = encrypt_lib.IV.fromBase64(ivB64);
      final encrypted = encrypt_lib.Encrypted.fromBase64(ctB64);
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(_encKey!, mode: encrypt_lib.AESMode.cbc),
      );
      return encrypter.decrypt(encrypted, iv: iv);
    } else if (parts.length == 2) {
      // Legacy format (no MAC) -- DEPRECATED.
      // Unauthenticated CBC is vulnerable to padding oracle attacks.
      // Data should be migrated to the authenticated format.
      // Log a warning and decrypt, but callers should re-encrypt immediately.
      final iv = encrypt_lib.IV.fromBase64(parts[0]);
      final encrypted = encrypt_lib.Encrypted.fromBase64(parts[1]);
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(_legacyKey!, mode: encrypt_lib.AESMode.cbc),
      );
      // ignore: avoid_print
      print('[EncryptionService] WARNING: Decrypting legacy unauthenticated '
          'ciphertext. Re-encrypt this data immediately.');
      return encrypter.decrypt(encrypted, iv: iv);
    } else {
      throw const EncryptionException(
        'Malformed ciphertext: expected iv:ciphertext:hmac',
      );
    }
  }

  /// Constant-time string comparison to prevent timing attacks on HMAC.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  void _assertReady() {
    if (_encKey == null || _macKey == null) {
      throw const EncryptionException(
        'EncryptionService not initialised. Call initialise() first.',
      );
    }
  }
}
