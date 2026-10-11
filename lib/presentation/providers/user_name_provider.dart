import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'repository_providers.dart';

class UserNameNotifier extends StateNotifier<String> {
  final Ref _ref;
  UserNameNotifier(this._ref) : super('') {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(settingsRepositoryProvider);
    state = (await repo.get(AppConstants.kUserName)) ?? '';
  }

  Future<void> setName(String name) async {
    final trimmed = name.trim();
    final repo = _ref.read(settingsRepositoryProvider);
    if (trimmed.isEmpty) {
      await repo.remove(AppConstants.kUserName);
    } else {
      await repo.set(AppConstants.kUserName, trimmed);
    }
    state = trimmed;
  }
}

final userNameProvider =
    StateNotifierProvider<UserNameNotifier, String>((ref) => UserNameNotifier(ref));
