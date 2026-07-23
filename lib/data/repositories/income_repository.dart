import '../database/app_database.dart';
import '../models/income.dart';

class IncomeRepository {
  final AppDatabase _db;
  IncomeRepository(this._db);

  Future<List<Income>> getAll({int? year, int? month}) async {
    String? where;
    List<Object?>? args;
    if (year != null && month != null) {
      where = 'date >= ? AND date <= ?';
      args = [
        DateTime(year, month, 1).toIso8601String(),
        DateTime(year, month + 1, 0, 23, 59, 59, 999).toIso8601String(),
      ];
    } else if (year != null) {
      where = 'date >= ? AND date <= ?';
      args = [
        DateTime(year, 1, 1).toIso8601String(),
        DateTime(year, 12, 31, 23, 59, 59, 999).toIso8601String(),
      ];
    }
    final rows = await _db.db.query('income', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map(Income.fromMap).toList();
  }

  Future<double> totalForMonth(int year, int month) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).toIso8601String();
    final rows = await _db.db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM income WHERE date >= ? AND date <= ?',
      [start, end],
    );
    return (rows.first['total'] as num).toDouble();
  }

  Future<int> insert(Income i) async => _db.db.insert('income', i.toMap());

  Future<void> update(Income i) async {
    await _db.db.update('income', i.toMap(), where: 'id = ?', whereArgs: [i.id]);
  }

  Future<void> delete(int id) async {
    await _db.db.delete('income', where: 'id = ?', whereArgs: [id]);
  }
}
