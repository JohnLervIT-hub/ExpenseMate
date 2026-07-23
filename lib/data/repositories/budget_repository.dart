import '../database/app_database.dart';
import '../models/budget.dart';

class BudgetRepository {
  final AppDatabase _db;
  BudgetRepository(this._db);

  Future<Budget?> forMonth(int year, int month) async {
    final rows = await _db.db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Budget.fromMap(rows.first);
  }

  Future<void> upsert(Budget b) async {
    final existing = await forMonth(b.year, b.month);
    if (existing == null) {
      await _db.db.insert('budgets', b.copyWith(id: 0, createdAt: DateTime.now()).toMap());
    } else {
      await _db.db.update(
        'budgets',
        b.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }

  Future<void> delete(int id) async {
    await _db.db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
