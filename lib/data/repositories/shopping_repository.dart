import '../database/app_database.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

class ShoppingRepository {
  final AppDatabase _db;
  ShoppingRepository(this._db);

  Future<List<ShoppingList>> getAllLists({bool includeArchived = false}) async {
    final rows = await _db.db.query(
      'shopping_lists',
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'is_favorite DESC, updated_at DESC',
    );
    return rows.map(ShoppingList.fromMap).toList();
  }

  Future<ShoppingList?> getListById(int id) async {
    final rows = await _db.db.query('shopping_lists', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ShoppingList.fromMap(rows.first);
  }

  Future<int> insertList(ShoppingList l) async => _db.db.insert('shopping_lists', l.toMap());

  Future<void> updateList(ShoppingList l) async {
    final updated = l.copyWith(updatedAt: DateTime.now());
    await _db.db.update('shopping_lists', updated.toMap(), where: 'id = ?', whereArgs: [l.id]);
  }

  Future<void> deleteList(int id) async {
    await _db.db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> duplicateList(int id) async {
    return _db.db.transaction((txn) async {
      final listRows = await txn.query('shopping_lists', where: 'id = ?', whereArgs: [id], limit: 1);
      if (listRows.isEmpty) return 0;
      final orig = ShoppingList.fromMap(listRows.first);
      final now = DateTime.now();
      final newId = await txn.insert('shopping_lists', {
        'name': '${orig.name} (Copy)',
        'is_favorite': 0,
        'is_archived': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      final items = await txn.query('shopping_items', where: 'list_id = ?', whereArgs: [id]);
      for (final it in items) {
        final map = Map<String, dynamic>.from(it);
        map.remove('id');
        map['list_id'] = newId;
        map['is_purchased'] = 0;
        map['actual_price'] = 0;
        await txn.insert('shopping_items', map);
      }
      return newId;
    });
  }

  Future<void> toggleFavoriteList(int id) async {
    final list = await getListById(id);
    if (list == null) return;
    await updateList(list.copyWith(isFavorite: !list.isFavorite));
  }

  Future<void> archiveList(int id, bool archived) async {
    final list = await getListById(id);
    if (list == null) return;
    await updateList(list.copyWith(isArchived: archived));
  }

  Future<List<ShoppingItem>> getItems(int listId) async {
    final rows = await _db.db.query(
      'shopping_items',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<int> insertItem(ShoppingItem it) async {
    // Assign sort_order at end if 0
    if (it.sortOrder == 0) {
      final rows = await _db.db.rawQuery(
        'SELECT COALESCE(MAX(sort_order), 0) + 1 AS next FROM shopping_items WHERE list_id = ?',
        [it.listId],
      );
      final next = (rows.first['next'] as int?) ?? 1;
      return _db.db.insert('shopping_items', it.copyWith(sortOrder: next).toMap());
    }
    return _db.db.insert('shopping_items', it.toMap());
  }

  Future<void> updateItem(ShoppingItem it) async {
    await _db.db.update('shopping_items', it.toMap(), where: 'id = ?', whereArgs: [it.id]);
  }

  Future<void> deleteItem(int id) async {
    await _db.db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorderItems(int listId, List<int> orderedIds) async {
    await _db.db.transaction((txn) async {
      for (var i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'shopping_items',
          {'sort_order': i + 1},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
  }

  Future<double> totalActualForList(int listId) async {
    final rows = await _db.db.rawQuery(
      'SELECT COALESCE(SUM(actual_price * quantity), 0) AS total FROM shopping_items WHERE list_id = ?',
      [listId],
    );
    return (rows.first['total'] as num).toDouble();
  }

  Future<double> totalEstimatedForList(int listId) async {
    final rows = await _db.db.rawQuery(
      'SELECT COALESCE(SUM(estimated_price * quantity), 0) AS total FROM shopping_items WHERE list_id = ?',
      [listId],
    );
    return (rows.first['total'] as num).toDouble();
  }

  Future<int> purchasedCount(int listId) async {
    final rows = await _db.db.rawQuery(
      'SELECT COUNT(*) AS c FROM shopping_items WHERE list_id = ? AND is_purchased = 1',
      [listId],
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<int> totalCount(int listId) async {
    final rows = await _db.db.rawQuery(
      'SELECT COUNT(*) AS c FROM shopping_items WHERE list_id = ?',
      [listId],
    );
    return (rows.first['c'] as int?) ?? 0;
  }
}
