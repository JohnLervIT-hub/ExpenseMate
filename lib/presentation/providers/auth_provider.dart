import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

@immutable
class AuthState {
  final bool isUnlocked;
  final bool hasPin;
  final bool biometricEnabled;
  final bool biometricAvailable;

  const AuthState({
    required this.isUnlocked,
    required this.hasPin,
    required this.biometricEnabled,
    required this.biometricAvailable,
  });

  AuthState copyWith({bool? isUnlocked, bool? hasPin, bool? biometricEnabled, bool? biometricAvailable}) =>
      AuthState(
        isUnlocked: isUnlocked ?? this.isUnlocked,
        hasPin: hasPin ?? this.hasPin,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      );

  static const initial = AuthState(
    isUnlocked: true,
    hasPin: false,
    biometricEnabled: false,
    biometricAvailable: false,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _auth;
  final SettingsRepository _settings;

  AuthNotifier(this._auth, this._settings) : super(AuthState.initial) {
    _init();
  }

  Future<void> _init() async {
    final hasPin = await _auth.hasPin();
    final bioEnabled = (await _settings.get(AppConstants.kBiometricEnabled)) == 'true';
    final bioAvail = await _auth.biometricAvailable();
    state = AuthState(
      isUnlocked: !hasPin,
      hasPin: hasPin,
      biometricEnabled: bioEnabled,
      biometricAvailable: bioAvail,
    );
  }

  Future<bool> verifyPin(String pin) async {
    final ok = await _auth.verifyPin(pin);
    if (ok) state = state.copyWith(isUnlocked: true);
    return ok;
  }

  Future<bool> authenticateBiometric() async {
    if (!state.biometricEnabled || !state.biometricAvailable) return false;
    final ok = await _auth.authenticateBiometric();
    if (ok) state = state.copyWith(isUnlocked: true);
    return ok;
  }

  Future<void> setPin(String pin) async {
    await _auth.setPin(pin);
    state = state.copyWith(hasPin: true, isUnlocked: true);
  }

  Future<void> clearPin() async {
    await _auth.clearPin();
    state = state.copyWith(hasPin: false, isUnlocked: true, biometricEnabled: false);
    await _settings.set(AppConstants.kBiometricEnabled, 'false');
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _settings.set(AppConstants.kBiometricEnabled, enabled ? 'true' : 'false');
    state = state.copyWith(biometricEnabled: enabled);
  }

  void lock() {
    if (state.hasPin) state = state.copyWith(isUnlocked: false);
  }
}

final pinLockProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);
