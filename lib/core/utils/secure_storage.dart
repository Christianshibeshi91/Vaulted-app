import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used in secure storage. Centralised to prevent typo bugs.
enum StorageKey {
  authToken('vaulted_auth_token'),
  refreshToken('vaulted_refresh_token'),
  encryptionKey('vaulted_encryption_key'),
  biometricEnabled('vaulted_biometric_enabled'),
  userId('vaulted_user_id'),
  onboardingComplete('vaulted_onboarding_complete'),
  pinHash('vaulted_pin_hash'),
  lastActiveTimestamp('vaulted_last_active');

  final String value;
  const StorageKey(this.value);
}

/// Thin wrapper around [FlutterSecureStorage] providing typed key access
/// and a singleton instance so only one storage handle exists.
class SecureStorageService {
  SecureStorageService._();

  /// Test-only constructor so fakes can extend this class.
  @visibleForTesting
  SecureStorageService.forTest();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Write a value by [StorageKey].
  Future<void> write(StorageKey key, String value) async {
    await _storage.write(key: key.value, value: value);
  }

  /// Read a value by [StorageKey]. Returns `null` if absent.
  Future<String?> read(StorageKey key) async {
    return _storage.read(key: key.value);
  }

  /// Delete a single entry.
  Future<void> delete(StorageKey key) async {
    await _storage.delete(key: key.value);
  }

  /// Wipe all stored values (e.g. on logout).
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check whether a key exists without reading the value.
  Future<bool> containsKey(StorageKey key) async {
    return _storage.containsKey(key: key.value);
  }
}
