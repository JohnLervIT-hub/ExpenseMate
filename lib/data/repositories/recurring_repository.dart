import '../database/app_database.dart';
import '../models/recurring_expense.dart';

class RecurringRepository {
  final AppDatabase _db;
  RecurringRepository(this._db);

  Future<List<RecurringExpense>> getAll({bool activeOnly = false}) async {
    final rows = await _db.db.query(
      'recurring_expenses',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'is_active DESC, next_due ASC',
    );
    return rows.map(RecurringExpense.fromMap).toList();
  }

  Future<RecurringExpense?> getById(int id) async {
    final rows = await _db.db.query('recurring_expenses', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return RecurringExpense.fromMap(rows.first);
  }

  Future<int> insert(RecurringExpense r) async {
    return _db.db.insert('recurring_expenses', r.toMap());
  }

  Future<void> update(RecurringExpense r) async {
    await _db.db.update('recurring_expenses', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<void> delete(int id) async {
    await _db.db.delete('recurring_expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleActive(int id) async {
    final r = await getById(id);
    if (r == null) return;
    await update(r.copyWith(isActive: !r.isActive));
  }

  Future<List<RecurringExpense>> dueOnOrBefore(DateTime date) async {
    final rows = await _db.db.query(
      'recurring_expenses',
      where: 'is_active = 1 AND next_due <= ?',
      whereArgs: [date.toIso8601String()],
    );
    return rows.map(RecurringExpense.fromMap).toList();
  }
}
