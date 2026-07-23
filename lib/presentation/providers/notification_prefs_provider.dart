import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

@immutable
class NotificationPrefs {
  final bool dailyReminder;
  final int dailyHour;
  final int dailyMinute;
  final bool weeklyReview;
  final bool budgetThresholdAlerts;
  final bool billReminders;

  const NotificationPrefs({
    required this.dailyReminder,
    required this.dailyHour,
    required this.dailyMinute,
    required this.weeklyReview,
    required this.budgetThresholdAlerts,
    required this.billReminders,
  });

  NotificationPrefs copyWith({
    bool? dailyReminder,
    int? dailyHour,
    int? dailyMinute,
    bool? weeklyReview,
    bool? budgetThresholdAlerts,
    bool? billReminders,
  }) =>
      NotificationPrefs(
        dailyReminder: dailyReminder ?? this.dailyReminder,
        dailyHour: dailyHour ?? this.dailyHour,
        dailyMinute: dailyMinute ?? this.dailyMinute,
        weeklyReview: weeklyReview ?? this.weeklyReview,
        budgetThresholdAlerts: budgetThresholdAlerts ?? this.budgetThresholdAlerts,
        billReminders: billReminders ?? this.billReminders,
      );

  static const initial = NotificationPrefs(
    dailyReminder: false,
    dailyHour: 20,
    dailyMinute: 0,
    weeklyReview: false,
    budgetThresholdAlerts: true,
    billReminders: true,
  );
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  final SettingsRepository _settings;
  NotificationPrefsNotifier(this._settings) : super(NotificationPrefs.initial) {
    _load();
  }

  Future<void> _load() async {
    final daily = await _settings.get(AppConstants.kDailyReminder) == '1';
    final timeStr = await _settings.get(AppConstants.kDailyReminderTime);
    int hour = 20, minute = 0;
    if (timeStr != null && timeStr.contains(':')) {
      final parts = timeStr.split(':');
      hour = int.tryParse(parts[0]) ?? 20;
      minute = int.tryParse(parts[1]) ?? 0;
    }
    final weekly = await _settings.get(AppConstants.kWeeklyReview) == '1';
    final budget = (await _settings.get(AppConstants.kBudgetThresholdAlerts)) != '0';
    final bill = (await _settings.get(AppConstants.kBillReminders)) != '0';
    state = NotificationPrefs(
      dailyReminder: daily,
      dailyHour: hour,
      dailyMinute: minute,
      weeklyReview: weekly,
      budgetThresholdAlerts: budget,
      billReminders: bill,
    );
  }

  Future<void> setDailyReminder(bool enabled) async {
    state = state.copyWith(dailyReminder: enabled);
    await _settings.set(AppConstants.kDailyReminder, enabled ? '1' : '0');
    if (enabled) {
      await NotificationService.instance
          .scheduleDailyReminder(hour: state.dailyHour, minute: state.dailyMinute);
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
  }

  Future<void> setDailyTime(int hour, int minute) async {
    state = state.copyWith(dailyHour: hour, dailyMinute: minute);
    await _settings.set(AppConstants.kDailyReminderTime,
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    if (state.dailyReminder) {
      await NotificationService.instance.scheduleDailyReminder(hour: hour, minute: minute);
    }
  }

  Future<void> setWeeklyReview(bool enabled) async {
    state = state.copyWith(weeklyReview: enabled);
    await _settings.set(AppConstants.kWeeklyReview, enabled ? '1' : '0');
    if (enabled) {
      await NotificationService.instance.scheduleWeeklyReview();
    } else {
      await NotificationService.instance.cancelWeeklyReview();
    }
  }

  Future<void> setBudgetAlerts(bool enabled) async {
    state = state.copyWith(budgetThresholdAlerts: enabled);
    await _settings.set(AppConstants.kBudgetThresholdAlerts, enabled ? '1' : '0');
  }

  Future<void> setBillReminders(bool enabled) async {
    state = state.copyWith(billReminders: enabled);
    await _settings.set(AppConstants.kBillReminders, enabled ? '1' : '0');
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>((ref) {
  return NotificationPrefsNotifier(ref.watch(settingsRepositoryProvider));
});
