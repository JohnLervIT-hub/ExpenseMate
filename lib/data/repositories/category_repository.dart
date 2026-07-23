import '../database/app_database.dart';
import '../models/category.dart';

class CategoryRepository {
  final AppDatabase _db;
  CategoryRepository(this._db);

  Future<List<Category>> getAll() async {
    final rows = await _db.db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getById(int id) async {
    final rows = await _db.db.query('categories', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Category.fromMap(rows.first);
  }

  Future<int> insert(Category c) async {
    return _db.db.insert('categories', c.toMap());
  }

  Future<void> update(Category c) async {
    await _db.db.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> delete(int id) async {
    await _db.db.delete('categories', where: 'id = ? AND is_default = 0', whereArgs: [id]);
  }

  Future<Map<int, Category>> mapById() async {
    final all = await getAll();
    return {for (final c in all) c.id: c};
  }
}
