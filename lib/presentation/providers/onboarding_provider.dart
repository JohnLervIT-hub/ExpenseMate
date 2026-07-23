import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

/// Overridden in main() with the value loaded from the settings table before
/// runApp() so the router's redirect can read it synchronously on first frame.
final initialHasOnboardedProvider = Provider<bool>((ref) {
  throw UnimplementedError('initialHasOnboardedProvider must be overridden in ProviderScope');
});

class HasOnboardedNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  HasOnboardedNotifier(this._repo, bool initial) : super(initial);

  Future<void> markComplete() async {
    if (state) return;
    await _repo.set(AppConstants.kHasOnboarded, 'true');
    state = true;
  }

  Future<void> reset() async {
    await _repo.set(AppConstants.kHasOnboarded, 'false');
    state = false;
  }
}

final hasOnboardedProvider = StateNotifierProvider<HasOnboardedNotifier, bool>((ref) {
  return HasOnboardedNotifier(
    ref.watch(settingsRepositoryProvider),
    ref.watch(initialHasOnboardedProvider),
  );
});
