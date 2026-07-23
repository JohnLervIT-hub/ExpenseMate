import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

class CurrencyNotifier extends StateNotifier<String> {
  final SettingsRepository _repo;
  CurrencyNotifier(this._repo) : super('\$') {
    _load();
  }

  Future<void> _load() async {
    final v = await _repo.get(AppConstants.kCurrencySymbol);
    if (v != null && v.isNotEmpty) state = v;
  }

  Future<void> set(String symbol) async {
    state = symbol;
    await _repo.set(AppConstants.kCurrencySymbol, symbol);
  }
}

final currencySymbolProvider = StateNotifierProvider<CurrencyNotifier, String>(
  (ref) => CurrencyNotifier(ref.watch(settingsRepositoryProvider)),
);
