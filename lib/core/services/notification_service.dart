import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _mobileOnly => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (_initialized) return;
    if (!_mobileOnly) {
      _initialized = true;
      return;
    }
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(init);

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Notification permission request skipped: $e');
    }
    _initialized = true;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    await init();
    if (!_mobileOnly) return;
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'expensemate_reminders',
      'Reminders',
      channelDescription: 'Budget and shopping reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('scheduleReminder failed: $e');
    }
  }

  Future<void> showImmediate({required int id, required String title, required String body}) async {
    await init();
    if (!_mobileOnly) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'expensemate_reminders',
        'Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  // ---------- Daily / weekly / threshold reminders ----------

  static const int _dailyId = 900001;
  static const int _weeklyId = 900002;

  /// Schedule a daily reminder at [hour]:[minute] local time.
  /// If a reminder is already scheduled, replaces it.
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await init();
    if (!_mobileOnly) return;
    await cancel(_dailyId);
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    const android = AndroidNotificationDetails(
      'expensemate_daily',
      'Daily reminder',
      channelDescription: 'Nudge to log today\'s expenses',
      importance: Importance.high,
      priority: Priority.high,
    );
    try {
      await _plugin.zonedSchedule(
        _dailyId,
        'Any expenses today?',
        'Tap to log them in seconds.',
        next,
        const NotificationDetails(android: android, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleDailyReminder failed: $e');
    }
  }

  Future<void> cancelDailyReminder() => cancel(_dailyId);

  /// Weekly review reminder — Sunday 6 PM local, repeating.
  Future<void> scheduleWeeklyReview() async {
    await init();
    if (!_mobileOnly) return;
    await cancel(_weeklyId);
    final now = tz.TZDateTime.now(tz.local);
    // Sunday = weekday 7 in Dart's DateTime, but table_calendar uses different indices.
    // tz DateTime uses Dart's convention (mon=1..sun=7).
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);
    while (next.weekday != DateTime.sunday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    const android = AndroidNotificationDetails(
      'expensemate_weekly',
      'Weekly review',
      channelDescription: 'Sunday spending recap',
      importance: Importance.high,
      priority: Priority.high,
    );
    try {
      await _plugin.zonedSchedule(
        _weeklyId,
        'Weekly review',
        'Take 60 seconds to review the week and set next week\'s budget.',
        next,
        const NotificationDetails(android: android, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('scheduleWeeklyReview failed: $e');
    }
  }

  Future<void> cancelWeeklyReview() => cancel(_weeklyId);

  /// Fire immediately when a category crosses a spending threshold.
  Future<void> showBudgetThresholdAlert({
    required String categoryName,
    required int percent,
  }) async {
    await init();
    if (!_mobileOnly) return;
    final id = 900100 + categoryName.hashCode % 800;
    const android = AndroidNotificationDetails(
      'expensemate_budget',
      'Budget alerts',
      channelDescription: 'Category budget thresholds',
      importance: Importance.high,
      priority: Priority.high,
    );
    try {
      await _plugin.show(
        id,
        percent >= 100
            ? 'Over budget: $categoryName'
            : '$percent% of $categoryName budget used',
        percent >= 100
            ? 'You\'ve blown past your monthly limit.'
            : 'You\'re getting close — check where the money went.',
        const NotificationDetails(android: android, iOS: DarwinNotificationDetails()),
      );
    } catch (e) {
      debugPrint('showBudgetThresholdAlert failed: $e');
    }
  }
}
