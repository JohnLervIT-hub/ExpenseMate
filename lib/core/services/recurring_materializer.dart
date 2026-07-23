import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/expense.dart';
import '../../data/models/recurring_expense.dart';
import 'notification_service.dart';

/// Turns due recurring rules into real expenses and schedules a reminder
/// one day before each rule's next occurrence.
class RecurringMaterializer {
  const RecurringMaterializer();

  /// Runs on every app launch. Returns the number of expenses materialized.
  static Future<int> materializeDue(Database db, {DateTime? now}) async {
    final nowLocal = now ?? DateTime.now();
    final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day, 23, 59, 59, 999);
    var count = 0;
    try {
      final rows = await db.query(
        'recurring_expenses',
        where: 'is_active = 1 AND next_due <= ?',
        whereArgs: [today.toIso8601String()],
      );
      if (rows.isEmpty) return 0;

      await db.transaction((txn) async {
        for (final r in rows) {
          final rule = RecurringExpense.fromMap(r);
          var due = rule.nextDue;
          // Materialize every past occurrence up to today. Safety cap of 24
          // catches misconfigured rules without runaway inserts.
          for (var i = 0; i < 24 && !due.isAfter(today); i++) {
            final expense = Expense(
              id: 0,
              amount: rule.amount,
              categoryId: rule.categoryId,
              merchant: rule.merchant,
              paymentMethod: 'Credit Card',
              notes: 'Recurring · ${rule.frequency.toLowerCase()}',
              receiptPath: null,
              isFavorite: false,
              date: due,
              createdAt: nowLocal,
              updatedAt: nowLocal,
            );
            await txn.insert('expenses', expense.toMap());
            due = _advance(due, rule.frequency);
            count++;
          }
          await txn.update(
            'recurring_expenses',
            {'next_due': due.toIso8601String()},
            where: 'id = ?',
            whereArgs: [rule.id],
          );
        }
      });

      await _scheduleUpcomingReminders(db);
    } catch (e) {
      debugPrint('RecurringMaterializer error: $e');
    }
    return count;
  }

  /// After bumping next_due, schedule a local notification 24h before each
  /// active rule's next occurrence.
  static Future<void> _scheduleUpcomingReminders(Database db) async {
    try {
      final rows = await db.query('recurring_expenses', where: 'is_active = 1');
      final notif = NotificationService.instance;
      for (final r in rows) {
        final rule = RecurringExpense.fromMap(r);
        final fireAt = rule.nextDue.subtract(const Duration(days: 1));
        if (fireAt.isBefore(DateTime.now())) continue;
        final notifId = 100000 + rule.id;
        await notif.cancel(notifId);
        await notif.scheduleReminder(
          id: notifId,
          title: 'Upcoming: ${rule.merchant}',
          body: 'Charging tomorrow · \$${rule.amount.toStringAsFixed(2)}',
          when: fireAt,
        );
      }
    } catch (e) {
      debugPrint('scheduleUpcomingReminders error: $e');
    }
  }

  static DateTime _advance(DateTime d, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return d.add(const Duration(days: 1));
      case 'weekly':
        return d.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(d.year + 1, d.month, d.day, d.hour, d.minute);
      case 'monthly':
      default:
        // Month math: preserve day-of-month where possible, otherwise clamp
        // to the last day of the destination month (e.g. Jan 31 → Feb 28/29).
        final targetYear = d.month == 12 ? d.year + 1 : d.year;
        final targetMonth = d.month == 12 ? 1 : d.month + 1;
        final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
        final day = d.day <= lastDay ? d.day : lastDay;
        return DateTime(targetYear, targetMonth, day, d.hour, d.minute);
    }
  }
}
