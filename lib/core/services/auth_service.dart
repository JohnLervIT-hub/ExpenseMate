import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const _pinKey = 'pin_hash_secure';
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  AuthService({FlutterSecureStorage? storage, LocalAuthentication? localAuth})
      : _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasPin() async {
    try {
      final v = await _storage.read(key: _pinKey);
      return v != null && v.isNotEmpty;
    } catch (e) {
      debugPrint('hasPin error: $e');
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    try {
      await _storage.write(key: _pinKey, value: _hash(pin));
    } catch (e) {
      debugPrint('setPin error: $e');
    }
  }

  Future<bool> verifyPin(String pin) async {
    try {
      final v = await _storage.read(key: _pinKey);
      if (v == null) return false;
      return v == _hash(pin);
    } catch (e) {
      debugPrint('verifyPin error: $e');
      return false;
    }
  }

  Future<void> clearPin() async {
    try {
      await _storage.delete(key: _pinKey);
    } catch (e) {
      debugPrint('clearPin error: $e');
    }
  }

  bool get _mobileOnly => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<bool> biometricAvailable() async {
    if (!_mobileOnly) return false;
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final can = await _localAuth.canCheckBiometrics;
      return can;
    } catch (e) {
      debugPrint('biometricAvailable error: $e');
      return false;
    }
  }

  Future<bool> authenticateBiometric() async {
    if (!_mobileOnly) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock ExpenseMate',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e) {
      debugPrint('authenticateBiometric error: $e');
      return false;
    }
  }
}
