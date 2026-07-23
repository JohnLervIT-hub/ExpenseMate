import '../database/app_database.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final AppDatabase _db;
  ExpenseRepository(this._db);

  Future<List<Expense>> getAll({
    DateTime? start,
    DateTime? end,
    int? categoryId,
    String? query,
    bool? favoritesOnly,
    int? limit,
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (start != null) {
      where.add('date >= ?');
      args.add(start.toIso8601String());
    }
    if (end != null) {
      where.add('date <= ?');
      args.add(end.toIso8601String());
    }
    if (categoryId != null) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    if (query != null && query.trim().isNotEmpty) {
      // Match merchant, notes, or the linked category name so users can
      // search by category label (e.g. "utilities") even though the column
      // itself only holds a foreign key.
      where.add(
        '(merchant LIKE ? OR notes LIKE ? OR category_id IN (SELECT id FROM categories WHERE name LIKE ?))',
      );
      final q = '%${query.trim()}%';
      args.add(q);
      args.add(q);
      args.add(q);
    }
    if (favoritesOnly == true) {
      where.add('is_favorite = 1');
    }
    final rows = await _db.db.query(
      'expenses',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC',
      limit: limit,
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<Expense?> getById(int id) async {
    final rows = await _db.db.query('expenses', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Expense.fromMap(rows.first);
  }

  Future<int> insert(Expense e) async {
    return _db.db.insert('expenses', e.toMap());
  }

  Future<void> update(Expense e) async {
    final updated = e.copyWith(updatedAt: DateTime.now());
    await _db.db.update('expenses', updated.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> delete(int id) async {
    await _db.db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> duplicate(int id) async {
    final orig = await getById(id);
    if (orig == null) return 0;
    return insert(orig.copyWith(
      id: 0,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> toggleFavorite(int id) async {
    final e = await getById(id);
    if (e == null) return;
    await update(e.copyWith(isFavorite: !e.isFavorite));
  }

  Future<double> totalForMonth(int year, int month) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).toIso8601String();
    final rows = await _db.db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE date >= ? AND date <= ?',
      [start, end],
    );
    return (rows.first['total'] as num).toDouble();
  }

  Future<Map<int, double>> totalsByCategoryForMonth(int year, int month) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).toIso8601String();
    final rows = await _db.db.rawQuery(
      'SELECT category_id, SUM(amount) AS total FROM expenses WHERE date >= ? AND date <= ? GROUP BY category_id',
      [start, end],
    );
    return {
      for (final r in rows) r['category_id'] as int: (r['total'] as num).toDouble(),
    };
  }

  Future<List<Expense>> recent({int limit = 5}) async {
    final rows = await _db.db.query('expenses', orderBy: 'date DESC', limit: limit);
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> favorites() async {
    final rows = await _db.db.query('expenses', where: 'is_favorite = 1', orderBy: 'date DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<double> totalForRange(DateTime start, DateTime end) async {
    final rows = await _db.db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE date >= ? AND date <= ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (rows.first['total'] as num).toDouble();
  }
}
