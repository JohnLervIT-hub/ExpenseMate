import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

class DateFormatNotifier extends StateNotifier<String> {
  final SettingsRepository _repo;
  DateFormatNotifier(this._repo) : super(AppFormat.datePattern) {
    _load();
  }

  Future<void> _load() async {
    final v = await _repo.get(AppConstants.kDateFormat);
    if (v != null && supportedDatePatterns.contains(v)) {
      state = v;
      AppFormat.datePattern = v;
    }
  }

  Future<void> set(String pattern) async {
    if (!supportedDatePatterns.contains(pattern)) return;
    state = pattern;
    AppFormat.datePattern = pattern;
    await _repo.set(AppConstants.kDateFormat, pattern);
  }
}

final dateFormatProvider = StateNotifierProvider<DateFormatNotifier, String>(
  (ref) => DateFormatNotifier(ref.watch(settingsRepositoryProvider)),
);

class FirstDayOfWeekNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  FirstDayOfWeekNotifier(this._repo) : super(AppFormat.firstDayOfWeek) {
    _load();
  }

  Future<void> _load() async {
    final v = await _repo.get(AppConstants.kFirstDayOfWeek);
    final parsed = int.tryParse(v ?? '');
    if (parsed != null && (parsed == 1 || parsed == 7)) {
      state = parsed;
      AppFormat.firstDayOfWeek = parsed;
    }
  }

  Future<void> set(int day) async {
    if (day != 1 && day != 7) return;
    state = day;
    AppFormat.firstDayOfWeek = day;
    await _repo.set(AppConstants.kFirstDayOfWeek, day.toString());
  }
}

final firstDayOfWeekProvider = StateNotifierProvider<FirstDayOfWeekNotifier, int>(
  (ref) => FirstDayOfWeekNotifier(ref.watch(settingsRepositoryProvider)),
);
