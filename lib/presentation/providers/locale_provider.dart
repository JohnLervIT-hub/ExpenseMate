import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

@immutable
class AppLanguage {
  final String code; // ISO 639-1
  final String label; // native name shown in picker
  final String english; // english name for accessibility
  const AppLanguage({required this.code, required this.label, required this.english});
}

const supportedLanguages = <AppLanguage>[
  AppLanguage(code: 'en', label: 'English', english: 'English'),
  AppLanguage(code: 'es', label: 'Español', english: 'Spanish'),
  AppLanguage(code: 'pt', label: 'Português', english: 'Portuguese'),
  AppLanguage(code: 'fr', label: 'Français', english: 'French'),
  AppLanguage(code: 'ar', label: 'العربية', english: 'Arabic'),
  AppLanguage(code: 'hi', label: 'हिन्दी', english: 'Hindi'),
];

class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _repo;
  LocaleNotifier(this._repo) : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final code = await _repo.get(AppConstants.kLanguage);
    if (code != null && supportedLanguages.any((l) => l.code == code)) {
      state = Locale(code);
    }
  }

  Future<void> set(String code) async {
    state = Locale(code);
    await _repo.set(AppConstants.kLanguage, code);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(settingsRepositoryProvider)),
);
